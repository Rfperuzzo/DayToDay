package com.senhoritaandriele.rotina

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class RotinaDayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { update(context, appWidgetManager, it) }
    }

    override fun onEnabled(context: Context) {
        updateAll(context)
    }

    companion object {
        const val ACTION_OPEN_TASK = "com.senhoritaandriele.rotina.OPEN_WIDGET_TASK"
        const val EXTRA_OCCURRENCE_ID = "occurrenceId"
        const val EXTRA_ACTIVITY_ID = "activityId"

        private val rowIds = intArrayOf(
            R.id.widget_task_1,
            R.id.widget_task_2,
            R.id.widget_task_3,
            R.id.widget_task_4,
        )
        private val titleIds = intArrayOf(
            R.id.widget_task_1_title,
            R.id.widget_task_2_title,
            R.id.widget_task_3_title,
            R.id.widget_task_4_title,
        )
        private val metaIds = intArrayOf(
            R.id.widget_task_1_meta,
            R.id.widget_task_2_meta,
            R.id.widget_task_3_meta,
            R.id.widget_task_4_meta,
        )

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, RotinaDayWidgetProvider::class.java)
            manager.getAppWidgetIds(component).forEach { update(context, manager, it) }
        }

        private fun update(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.rotina_day_widget)
            val snapshot = readSnapshot(context)
            val tasks = snapshot?.tasks.orEmpty()
            val total = snapshot?.totalCount ?: 0
            val completed = snapshot?.completedCount ?: 0

            views.setTextViewText(
                R.id.widget_date,
                snapshot?.dateLabel ?: "Hoje",
            )
            views.setTextViewText(
                R.id.widget_progress,
                if (total == 0) "Nenhuma tarefa planejada" else "$completed de $total concluídas",
            )
            views.setOnClickPendingIntent(
                R.id.widget_header,
                openAppIntent(context, widgetId),
            )

            rowIds.indices.forEach { index ->
                val task = tasks.getOrNull(index)
                if (task == null) {
                    views.setViewVisibility(rowIds[index], View.GONE)
                } else {
                    views.setViewVisibility(rowIds[index], View.VISIBLE)
                    views.setTextViewText(titleIds[index], decoratedTitle(task))
                    views.setTextViewText(
                        metaIds[index],
                        "${task.timeLabel} • ${task.durationMinutes} min • ${priorityLabel(task.priority)}",
                    )
                    views.setInt(
                        rowIds[index],
                        "setBackgroundResource",
                        when {
                            task.status == "completed" -> R.drawable.widget_task_completed_background
                            task.isLocked -> R.drawable.widget_task_locked_background
                            else -> R.drawable.widget_task_background
                        },
                    )
                    views.setOnClickPendingIntent(
                        rowIds[index],
                        openTaskIntent(context, task),
                    )
                }
            }

            views.setViewVisibility(
                R.id.widget_empty,
                if (total == 0) View.VISIBLE else View.GONE,
            )
            val remaining = total - rowIds.size
            views.setViewVisibility(
                R.id.widget_more,
                if (remaining > 0) View.VISIBLE else View.GONE,
            )
            if (remaining > 0) {
                views.setTextViewText(
                    R.id.widget_more,
                    "+$remaining ${if (remaining == 1) "tarefa" else "tarefas"} no app",
                )
                views.setOnClickPendingIntent(
                    R.id.widget_more,
                    openAppIntent(context, widgetId + 10_000),
                )
            }
            manager.updateAppWidget(widgetId, views)
        }

        private fun readSnapshot(context: Context): WidgetSnapshot? {
            val raw = context
                .getSharedPreferences(MainActivity.WIDGET_PREFERENCES, Context.MODE_PRIVATE)
                .getString(MainActivity.WIDGET_SNAPSHOT_KEY, null)
                ?: return null
            return try {
                val root = JSONObject(raw)
                val todayKey = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
                val days = root.optJSONArray("days") ?: JSONArray()
                var selected: JSONObject? = null
                for (index in 0 until days.length()) {
                    val candidate = days.optJSONObject(index) ?: continue
                    if (candidate.optString("dayKey") == todayKey) {
                        selected = candidate
                        break
                    }
                }
                val day = selected ?: return null
                val jsonTasks = day.optJSONArray("tasks")
                val tasks = buildList {
                    if (jsonTasks != null) {
                        for (index in 0 until jsonTasks.length()) {
                            val item = jsonTasks.optJSONObject(index) ?: continue
                            add(
                                WidgetTask(
                                    occurrenceId = item.optString("occurrenceId"),
                                    activityId = item.optString("activityId"),
                                    title = item.optString("title", "Atividade"),
                                    timeLabel = item.optString("timeLabel", "--:--"),
                                    durationMinutes = item.optInt("durationMinutes"),
                                    status = item.optString("status", "scheduled"),
                                    priority = item.optString("priority", "normal"),
                                    isLocked = item.optBoolean("isLocked"),
                                ),
                            )
                        }
                    }
                }
                WidgetSnapshot(
                    dateLabel = day.optString("dateLabel", "Hoje"),
                    completedCount = day.optInt("completedCount"),
                    totalCount = day.optInt("totalCount"),
                    tasks = tasks,
                )
            } catch (_: Exception) {
                null
            }
        }

        private fun decoratedTitle(task: WidgetTask): String = when {
            task.status == "completed" -> "✓ ${task.title}"
            task.status == "skipped" -> "— ${task.title}"
            task.isLocked -> "🔒 ${task.title}"
            else -> task.title
        }

        private fun priorityLabel(priority: String): String = when (priority) {
            "high" -> "importante"
            "low" -> "flexível"
            else -> "normal"
        }

        private fun openTaskIntent(context: Context, task: WidgetTask): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_OPEN_TASK
                data = Uri.parse(
                    "rotinaandriele://widget/task/${Uri.encode(task.occurrenceId)}",
                )
                putExtra(EXTRA_OCCURRENCE_ID, task.occurrenceId)
                putExtra(EXTRA_ACTIVITY_ID, task.activityId)
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            return PendingIntent.getActivity(
                context,
                task.occurrenceId.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun openAppIntent(context: Context, requestCode: Int): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = Intent.ACTION_MAIN
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}

private data class WidgetSnapshot(
    val dateLabel: String,
    val completedCount: Int,
    val totalCount: Int,
    val tasks: List<WidgetTask>,
)

private data class WidgetTask(
    val occurrenceId: String,
    val activityId: String,
    val title: String,
    val timeLabel: String,
    val durationMinutes: Int,
    val status: String,
    val priority: String,
    val isLocked: Boolean,
)
