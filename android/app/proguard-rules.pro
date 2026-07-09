# Regras para evitar R8 remover classes do androidx.window que são
# referenciadas por plugins (flutter_local_notifications, alarm, etc.)
-dontwarn androidx.window.extensions.**
-dontwarn androidx.window.sidecar.**

-keep class androidx.window.extensions.** { *; }
-keep class androidx.window.sidecar.** { *; }
