# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Dio / OkHttp (networking)
-dontwarn okhttp3.**
-dontwarn okio.**
-keepclasseswithmembers class okhttp3.** { *; }
