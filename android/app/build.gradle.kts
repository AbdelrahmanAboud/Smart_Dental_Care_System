plugins {
    id("com.android.application")
    id("kotlin-android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart_dental_care_system"
    compileSdk = flutter.compileSdkVersion

    // 1. حل مشكلة الـ NDK المطلوبة من مكتبات Firebase
    ndkVersion = "27.0.12077973"

    compileOptions {
        // 2. تفعيل الـ Desugaring لحل مشكلة flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
        
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_dental_care_system"

        // رفع الـ minSdk ضروري لعمل الـ Desugaring و Firebase
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // استخدام الـ debug key مؤقتاً للتشغيل
            signingConfig = signingConfigs.getByName("debug")

            // تصحيح المسميات لصيغة Kotlin DSL
            isMinifyEnabled = false
            isShrinkResources = false
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 3. المكتبة الضرورية لعمل الـ Desugaring (Java 8 support)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    implementation("androidx.multidex:multidex:2.0.1")
}
