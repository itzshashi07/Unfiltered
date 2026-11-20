import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload key for Google Play. It lives outside the repository; the path can be
// overridden with UNFILTERED_SIGNING=/path/to/key.properties. Never commit it.
val signingFile = file(
    System.getenv("UNFILTERED_SIGNING")
        ?: "${System.getProperty("user.home")}/.config/unfiltered-signing/key.properties",
)
val signing = Properties().apply {
    if (signingFile.exists()) FileInputStream(signingFile).use { load(it) }
}

android {
    namespace = "app.unfiltered.unfiltered"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "app.unfiltered.learn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingFile.exists()) {
            create("upload") {
                keyAlias = signing.getProperty("keyAlias")
                keyPassword = signing.getProperty("keyPassword")
                storeFile = file(signing.getProperty("storeFile"))
                storePassword = signing.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // A release must carry the upload key. Without it the build stops instead of
            // quietly signing with the debug key (Play rejects debug-signed bundles).
            signingConfig = signingConfigs.findByName("upload")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Stop any release build that would otherwise go out unsigned or debug-signed.
gradle.taskGraph.whenReady {
    if (!signingFile.exists() && allTasks.any { it.name.contains("Release") }) {
        throw GradleException(
            "Release signing key not found at $signingFile. See docs/PLAY_STORE_PACK.md section 7.",
        )
    }
}
