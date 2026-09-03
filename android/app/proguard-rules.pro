# Flutter specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }

# Firebase Firestore
-keep class com.google.firebase.firestore.** { *; }

# Google Sign-In
-keep class com.google.android.gms.signin.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Dart/Flutter model classes — keep all fields for JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# General Android rules
-dontwarn sun.misc.**
-dontwarn java.lang.ClassValue
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
