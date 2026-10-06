package com.senhoritajhenifer.rotina

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var dayWidgetChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        captureWidgetTask(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.senhoritajhenifer.rotina/alarm_permissions",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "canUseFullScreenIntent" -> result.success(canUseFullScreenIntent())
                "canScheduleExactAlarms" -> result.success(canScheduleExactAlarms())
                "requestFullScreenIntent" -> {
                    requestFullScreenIntent()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        dayWidgetChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DAY_WIDGET_CHANNEL,
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateDayWidget" -> {
                        val snapshot = call.arguments as? String
                        if (snapshot == null) {
                            result.error("invalid_snapshot", "Resumo do widget inválido.", null)
                        } else {
                            getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE)
                                .edit()
                                .putString(WIDGET_SNAPSHOT_KEY, snapshot)
                                .apply()
                            RotinaDayWidgetProvider.updateAll(this)
                            result.success(null)
                        }
                    }
                    "takePendingTask" -> result.success(readPendingWidgetTask())
                    "acknowledgePendingTask" -> {
                        getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE)
                            .edit()
                            .remove(WIDGET_PENDING_TASK_KEY)
                            .apply()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val request = captureWidgetTask(intent)
        if (request != null) {
            dayWidgetChannel?.invokeMethod("openTask", request)
        }
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return true
        }
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return manager.canUseFullScreenIntent()
    }

    private fun canScheduleExactAlarms(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }
        val manager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        return manager.canScheduleExactAlarms()
    }

    private fun requestFullScreenIntent() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return
        }
        startActivity(
            Intent(
                Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                Uri.parse("package:$packageName"),
            ),
        )
    }

    private fun captureWidgetTask(intent: Intent?): Map<String, String>? {
        if (intent?.action != RotinaDayWidgetProvider.ACTION_OPEN_TASK) {
            return null
        }
        val occurrenceId = intent.getStringExtra(RotinaDayWidgetProvider.EXTRA_OCCURRENCE_ID)
        val activityId = intent.getStringExtra(RotinaDayWidgetProvider.EXTRA_ACTIVITY_ID)
        if (occurrenceId.isNullOrBlank() || activityId.isNullOrBlank()) {
            return null
        }
        val request = mapOf(
            "occurrenceId" to occurrenceId,
            "activityId" to activityId,
        )
        getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE)
            .edit()
            .putString(WIDGET_PENDING_TASK_KEY, JSONObject(request).toString())
            .apply()
        return request
    }

    private fun readPendingWidgetTask(): Map<String, String>? {
        val raw = getSharedPreferences(WIDGET_PREFERENCES, Context.MODE_PRIVATE)
            .getString(WIDGET_PENDING_TASK_KEY, null)
            ?: return null
        return try {
            val json = JSONObject(raw)
            val occurrenceId = json.optString("occurrenceId")
            val activityId = json.optString("activityId")
            if (occurrenceId.isBlank() || activityId.isBlank()) {
                null
            } else {
                mapOf(
                    "occurrenceId" to occurrenceId,
                    "activityId" to activityId,
                )
            }
        } catch (_: Exception) {
            null
        }
    }

    companion object {
        const val WIDGET_PREFERENCES = "rotina_day_widget"
        const val WIDGET_SNAPSHOT_KEY = "day_snapshot"
        const val WIDGET_PENDING_TASK_KEY = "pending_task"
        private const val DAY_WIDGET_CHANNEL = "com.senhoritajhenifer.rotina/day_widget"
    }
}
