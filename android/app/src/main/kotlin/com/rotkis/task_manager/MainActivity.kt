package com.rotkis.task_manager

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "task_manager/permissions"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        val granted =
                            NotificationManagerCompat.from(this).areNotificationsEnabled()
                        Log.d("PermissionHelper", "checkNotificationPermission -> $granted")
                        result.success(granted)
                    } else {
                        result.success(true) // Pré-Android 13, sempre concedida
                    }
                }
                "openAppSettings" -> {
                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                        data = android.net.Uri.fromParts("package", packageName, null)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("PermissionHelper", "openAppSettings failed: $e")
                        result.success(false)
                    }
                }
                "checkExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
                        val granted = alarmManager.canScheduleExactAlarms()
                        Log.d("PermissionHelper", "checkExactAlarmPermission (API ${Build.VERSION.SDK_INT}) -> $granted")
                        result.success(granted)
                    } else {
                        result.success(true)
                    }
                }
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                            data = android.net.Uri.fromParts("package", packageName, null)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        try {
                            startActivity(intent)
                            Log.d("PermissionHelper", "openExactAlarmSettings -> ACTION_REQUEST_SCHEDULE_EXACT_ALARM opened")
                            result.success(true)
                        } catch (e: ActivityNotFoundException) {
                            Log.w("PermissionHelper", "openExactAlarmSettings -> ACTION_REQUEST_SCHEDULE_EXACT_ALARM not available, falling back to app settings")
                            // Fallback: abre configurações do app (o usuário encontra "Alarmes e lembretes" manualmente)
                            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = android.net.Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            try {
                                startActivity(fallback)
                                result.success(true)
                            } catch (e2: Exception) {
                                Log.e("PermissionHelper", "openExactAlarmSettings fallback failed: $e2")
                                result.success(false)
                            }
                        }
                    } else {
                        result.success(true)
                    }
                }
                "getDeviceTimezone" -> {
                    val tz = java.util.TimeZone.getDefault()
                    result.success(tz.id)
                }
                "isBatteryOptimizationIgnored" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val ignored = powerManager.isIgnoringBatteryOptimizations(packageName)
                    Log.d("PermissionHelper", "isBatteryOptimizationIgnored -> $ignored")
                    result.success(ignored)
                }
                "requestIgnoreBatteryOptimization" -> {
                    val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                        data = android.net.Uri.fromParts("package", packageName, null)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("PermissionHelper", "requestIgnoreBatteryOptimization failed: $e")
                        result.success(false)
                    }
                }
                "checkInstallPackagesPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val granted = packageManager.canRequestPackageInstalls()
                        Log.d("PermissionHelper", "checkInstallPackagesPermission -> $granted")
                        result.success(granted)
                    } else {
                        result.success(true) // Pré-Android 8, sempre concedida
                    }
                }
                "openInstallPackagesSettings" -> {
                    val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                        data = Uri.fromParts("package", packageName, null)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("PermissionHelper", "openInstallPackagesSettings failed: $e")
                        result.success(false)
                    }
                }
                "installApk" -> {
                    val apkPath = call.argument<String>("apkPath")
                    if (apkPath == null) {
                        result.error("INVALID_ARG", "apkPath is null", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val file = File(apkPath)
                        val uri: Uri = FileProvider.getUriForFile(
                            this,
                            "$packageName.fileprovider",
                            file
                        )
                        val installIntent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(uri, "application/vnd.android.package-archive")
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(installIntent)
                        Log.d("PermissionHelper", "installApk -> Intent.ACTION_VIEW sent")
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e("PermissionHelper", "installApk failed: $e")
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
