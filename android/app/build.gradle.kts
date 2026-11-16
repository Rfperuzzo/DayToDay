plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadKeyPath = System.getenv("DAYTODAY_UPLOAD_KEY")
val uploadKeyAlias = System.getenv("DAYTODAY_UPLOAD_ALIAS")
val uploadKeyPassword = System.getenv("DAYTODAY_UPLOAD_PASSWORD")
val hasUploadSigning = !uploadKeyPath.isNullOrBlank() && !uploadKeyAlias.isNullOrBlank() && !uploadKeyPassword.isNullOrBlank()

gradle.taskGraph.whenReady {
    val releaseRequested = allTasks.any { it.project.path == ":app" && it.name.contains("Release") }
    if (releaseRequested && !hasUploadSigning && !project.hasProperty("daytoday.allowUnsigned")) {
        throw GradleException("Release exige a chave de upload DayToDay. Use PLAYSTORE/05_FONTES_E_FERRAMENTAS/Gerar-Producao.ps1. Nunca usa chave debug.")
    }
}

android {
    namespace = "com.senhoritajhenifer.rotina"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.senhoritajhenifer.rotina"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = providers.gradleProperty("daytoday.versionCode").orNull?.toInt() ?: flutter.versionCode
        versionName = providers.gradleProperty("daytoday.versionName").orNull ?: flutter.versionName
    }

    signingConfigs {
        if (hasUploadSigning) {
            create("upload") {
                storeFile = file(uploadKeyPath!!)
                storePassword = uploadKeyPassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasUploadSigning) signingConfigs.getByName("upload") else null
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
