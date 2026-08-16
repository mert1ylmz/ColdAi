# ML Kit Text Recognition - All Optional Modules
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.android.gms.internal.mlkit_vision_text_common.**

# TensorFlow Lite
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# Google Play Services & Play Core
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.**
-keep class com.google.android.gms.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Suppress all missing class warnings (Production Safe for Flutter)
-dontwarn **
