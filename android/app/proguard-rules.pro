# Regras para evitar R8 remover classes do androidx.window que são
# referenciadas por plugins (flutter_local_notifications, alarm, etc.)
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**

-keep class androidx.window.extensions.** { *; }
-keep class androidx.window.sidecar.** { *; }

# ─── flutter_local_notifications + Gson ──────────────────────────────
# R8 remove assinaturas genéricas que o Gson precisa para desserializar
# o cache interno de notificações agendadas. Causa crash no release com:
# "Missing type parameter" ao chamar loadScheduledNotifications().
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.gson.**
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }
