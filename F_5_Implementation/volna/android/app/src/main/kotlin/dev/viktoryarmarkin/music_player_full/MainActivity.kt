package dev.viktoryarmarkin.music_player_full

import android.Manifest
import android.content.Intent
import android.app.Activity
import android.net.Uri
import android.content.pm.PackageManager
import android.os.Build
import android.provider.DocumentsContract
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// AudioServiceActivity connects the media service. This channel handles
// permissions and library queries; just_audio performs the actual decoding.
class MainActivity : AudioServiceActivity() {
    private val pending = mutableMapOf<Int, MethodChannel.Result>()

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
                    "keepFolderGrants" -> {
                        val keep = call.argument<List<String>>("roots")?.toSet()
                        if (keep == null) {
                            result.error("folder", "Missing folder roots", null)
                        } else try {
                            for (grant in contentResolver.persistedUriPermissions) {
                                if (grant.isReadPermission && DocumentsContract.isTreeUri(grant.uri) &&
                                    grant.uri.toString() !in keep) {
                                    contentResolver.releasePersistableUriPermission(grant.uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                            }
                            result.success(null)
                        } catch (_: SecurityException) {
                            result.error("folder", "Could not release folder access", null)
                        }
                    }
                    "requestNotifications" -> {
                        if (Build.VERSION.SDK_INT >= 33) request(Manifest.permission.POST_NOTIFICATIONS, 302, result)
                        else result.success(true)
                    }
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
            val document = DocumentsContract.buildDocumentUriUsingTree(uri, DocumentsContract.getTreeDocumentId(uri))
            var name = DocumentsContract.getTreeDocumentId(uri).substringAfterLast(':').substringAfterLast('/')
            contentResolver.query(document, arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME), null, null, null)?.use {
                if (it.moveToFirst()) name = it.getString(0) ?: name
            }
            contentResolver.takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)
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
            DocumentsContract.Document.COLUMN_DISPLAY_NAME, DocumentsContract.Document.COLUMN_MIME_TYPE)
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
                        "title" to name.substringBeforeLast('.', name)))
                }
            }
        }
        return rows
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        pending.remove(requestCode)?.success(grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)
    }
}
