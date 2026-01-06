import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// --- 1. CARGA DE PROPIEDADES (FUERA DEL BLOQUE ANDROID) ---
// Al ponerlo aquí arriba, evitamos el error "Unresolved reference"
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.somnolence_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // --- 2. CORRECCIÓN DEL ERROR DE JVMTARGET ---
        // Usamos "17" directamente como texto
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.somnolence_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Leemos las variables cargadas arriba de forma segura
            keyAlias = keystoreProperties["keyAlias"] as String? ?: "androiddebugkey"
            keyPassword = keystoreProperties["keyPassword"] as String? ?: "android"
            
            val storeFileName = keystoreProperties["storeFile"] as String?
            storeFile = if (storeFileName != null) file(storeFileName) else null
            
            storePassword = keystoreProperties["storePassword"] as String? ?: "android"
        }
    }

    buildTypes {
        release {
            // Usamos la firma release configurada
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}