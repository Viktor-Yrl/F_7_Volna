package dev.viktoryarmarkin.music_player_full

import android.Manifest
import android.content.ContentUris
import android.content.Intent
import android.app.Activity
import android.net.Uri
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import android.provider.DocumentsContract
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// AudioServiceActivity connects the media service. This channel handles
// permissions and library queries; just_audio performs the actual decoding.
class MainActivity : AudioServiceActivity() {
    private val pending = mutableMapOf<Int, MethodChannel.Result>()
    private val audioPermission: String
        get() = if (Build.VERSION.SDK_INT >= 33) Manifest.permission.READ_MEDIA_AUDIO
                else Manifest.permission.READ_EXTERNAL_STORAGE

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "music_player_full/library")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFolder" -> {
                        if (pending.containsKey(303)) result.error("busy", "Выбор папки уже открыт", null)
                        else {
                            pending[303] = result
                            try {
                                startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or Intent.FLAG_GRANT_PREFIX_URI_PERMISSION)
                                }, 303)
                            } catch (_: Exception) { pending.remove(303); result.error("folder", "Выбор папки недоступен", null) }
                        }
                    }
                    "scanFolder" -> Thread {
                        try {
                            val uri = Uri.parse(call.argument<String>("uri") ?: throw IllegalArgumentException())
                            val tracks = scanFolder(uri)
                            runOnUiThread { result.success(tracks) }
                        } catch (_: Exception) { runOnUiThread { result.error("folder", "Нет доступа к папке. Выберите её заново", null) } }
                    }.start()
                    "requestNotifications" -> {
                        if (Build.VERSION.SDK_INT >= 33) request(Manifest.permission.POST_NOTIFICATIONS, 302, result)
                        else result.success(true)
                    }
                    "restoreLegacyTracks" -> Thread {
                        try {
                            val tracks = restoreLegacyTracks(call.argument<List<String>>("ids") ?: emptyList())
                            runOnUiThread { result.success(tracks) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("library", "Не удалось прочитать медиатеку", null) }
                        }
                    }.start()
                    else -> result.notImplemented()
                }
            }
    }

    private fun request(permission: String, code: Int, result: MethodChannel.Result) {
        if (checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
            result.success(true)
        } else if (pending.containsKey(code)) {
            result.error("busy", "Запрос разрешения уже открыт", null)
        } else {
            pending[code] = result
            requestPermissions(arrayOf(permission), code)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        // Persist read access so selected folders remain usable after restart.
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 303) return
        val result = pending.remove(303) ?: return
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) { result.success(null); return }
        try {
            contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
            val document = DocumentsContract.buildDocumentUriUsingTree(uri, DocumentsContract.getTreeDocumentId(uri))
            var name = DocumentsContract.getTreeDocumentId(uri).substringAfterLast(':').substringAfterLast('/')
            contentResolver.query(document, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use {
                if (it.moveToFirst()) name = it.getString(0) ?: name
            }
            result.success(mapOf("uri" to uri.toString(), "name" to name))
        } catch (_: Exception) { result.error("folder", "Не удалось сохранить доступ к папке", null) }
    }

    private fun scanFolder(tree: Uri): List<Map<String, Any>> {
        // Traverse document trees off the UI thread without copying audio files.
        val rows = mutableListOf<Map<String, Any>>()
        val remaining = java.util.ArrayDeque<String>()
        val visited = mutableSetOf<String>()
        remaining.add(DocumentsContract.getTreeDocumentId(tree))
        val columns = arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED)
        while (!remaining.isEmpty()) {
            val parent = remaining.removeFirst()
            if (!visited.add(parent)) continue
            val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, parent)
            val cursor = contentResolver.query(children, columns, null, null, null)
                ?: throw IllegalStateException("Folder unavailable")
            cursor.use {
                while (it.moveToNext()) {
                    val id = it.getString(0)
                    val name = it.getString(1) ?: "Audio"
                    val mime = it.getString(2) ?: ""
                    if (mime == DocumentsContract.Document.MIME_TYPE_DIR) { remaining.add(id); continue }
                    val extension = name.substringAfterLast('.', "").lowercase()
                    if (!mime.startsWith("audio/") && extension !in setOf("mp3", "m4a", "aac", "flac", "ogg", "wav", "opus")) continue
                    val uri = DocumentsContract.buildDocumentUriUsingTree(tree, id)
                    rows.add(mapOf("id" to "folder:${tree.authority}:$id", "uri" to uri.toString(),
                        "title" to name.substringBeforeLast('.', name), "origin" to "folder",
                        "addedAt" to it.getLong(3)))
                }
            }
        }
        return rows
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        pending.remove(requestCode)?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
    }

    private fun restoreLegacyTracks(ids: List<String>): List<Map<String, Any>> {
        // Read only saved IDs with an existing grant; never request broad access.
        if (checkSelfPermission(audioPermission) != PackageManager.PERMISSION_GRANTED) return emptyList()
        val keys = ids.filter { it.startsWith("media:") }.mapNotNull {
            it.removePrefix("media:").toLongOrNull()?.toString()
        }.distinct()
        if (keys.isEmpty()) return emptyList()
        val rows = mutableListOf<Map<String, Any>>()
        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val columns = arrayOf(MediaStore.Audio.Media._ID, MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST, MediaStore.Audio.Media.ALBUM, MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.DATE_ADDED)
        for (batch in keys.chunked(500)) {
        val selection = "${MediaStore.Audio.Media._ID} IN (${batch.joinToString(",") { "?" }})"
        contentResolver.query(collection, columns, selection, batch.toTypedArray(), null)?.use { cursor ->
            while (cursor.moveToNext()) {
                val id = cursor.getLong(0)
                val uri = ContentUris.withAppendedId(collection, id).toString()
                rows.add(mapOf("id" to "media:$id", "uri" to uri,
                    "title" to (cursor.getString(1) ?: ""),
                    "artist" to (cursor.getString(2)?.takeUnless { it == "<unknown>" } ?: "Unknown artist"),
                    "album" to (cursor.getString(3) ?: ""), "durationMs" to cursor.getLong(4),
                    "addedAt" to cursor.getLong(5) * 1000L, "origin" to "device"))
            }
        }
        }
        return rows
    }
}
