plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
}

val flutterRoot = extra["flutterRoot"] as String

android {
    namespace = "com.example.graduation_project"
    compileSdk = (extra["flutter.compileSdkVersion"] as String).toInt()
    ndkVersion = extra["flutter.ndkVersion"] as String

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.graduation_project"
        minSdk = (extra["flutter.minSdkVersion"] as String).toInt()
        targetSdk = (extra["flutter.targetSdkVersion"] as String).toInt()
        versionCode = (extra["flutter.versionCode"] as String).toInt()
        versionName = extra["flutter.versionName"] as String
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.8.1"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-dynamic-links")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}