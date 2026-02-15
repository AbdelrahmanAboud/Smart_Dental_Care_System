plugins {
    id("com.android.application")
    // يجب أن يكون بلجن Kotlin قبل الفلاتر لضمان التوافق
    id("kotlin-android")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.smart_dental_care_system"
    compileSdk = flutter.compileSdkVersion

    // يفضل ترك إصدار الـ NDK للفلاتر إلا لو كنت تحتاج إصداراً محدداً جداً
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // تحديث إلى Java 17 إذا كنت تستخدم إصدارات Flutter حديثة (3.19+)
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // يجب أن يتطابق مع JavaVersion أعلاه
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.smart_dental_care_system"

        // رفع الـ minSdk لـ 23 ضروري جداً لتوافق Firebase و Exact Alarms
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // إضافة هذا السطر لحل مشاكل الـ Multidex في الإصدارات القديمة
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // تأكد من استبدال هذا لاحقاً بـ signingConfig حقيقي عند رفع التطبيق للمتجر
            signingConfig = signingConfigs.getByName("debug")

            // تحسينات إضافية للنسخة النهائية
            minifyEnabled = false
            shrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // إضافة دعم Multidex إذا واجهت خطأ عند كثرة المكتبات
    implementation("androidx.multidex:multidex:2.0.1")
}