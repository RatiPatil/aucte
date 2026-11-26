import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

if (file("google-services.json").isFile) {
    apply(plugin = "com.google.gms.google-services")
}

// ─── Release Signing Configuration ──────────────────────────────────────────
// To configure release signing:
// 1. Create a keystore:
//    keytool -genkey -v -keystore android/app/aucte-release.jks
//            -keyalg RSA -keysize 2048 -validity 10000 -alias aucte
// 2. Create android/key.properties (DO NOT commit this file to version control):
//    storeFile=aucte-release.jks
//    storePassword=YOUR_STORE_PASSWORD
//    keyAlias=aucte
//    keyPassword=YOUR_KEY_PASSWORD
// 3. Add android/key.properties to .gitignore
// ─────────────────────────────────────────────────────────────────────────────
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    // Application ID — update this to your real reverse-domain package name.
    // IMPORTANT: This must match the package_name in google-services.json
    // and must be registered in your Firebase project.
    namespace = "in.gov.ayush.aucte"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "in.gov.ayush.aucte"
        minSdk = flutter.minSdkVersion        // Required for Google Sign-In and modern Firebase APIs
        targetSdk = 35     // Target Android 15 (API 35)
        versionCode = 1
        versionName = "1.0.0"

        // Required for multidex support on older devices
        multiDexEnabled = true
    }

    signingConfigs {
        if (keyPropertiesFile.exists()) {
            create("release") {
                keyAlias = keyProperties["keyAlias"] as String
                keyPassword = keyProperties["keyPassword"] as String
                storeFile = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Use release signing if key.properties exists, otherwise debug
            // (Debug signing will NOT be accepted by the Play Store)
            signingConfig = if (keyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Enable R8 code shrinking and obfuscation for production
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
