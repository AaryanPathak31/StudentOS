# StudentOS - Dockerized Build Guide

**StudentOS** is a student productivity suite built with Flutter.
This guide explains how to build the **Android APK** using **Docker**. This method ensures you do **not** need to install Android Studio, the Flutter SDK, or Java on your local machine.

---

## 🛠 Prerequisites

1.  **Docker Desktop** (Installed and running).
    *   *Windows Users:* Ensure "Use WSL 2 based engine" is checked in Docker Settings.
2.  **Git** (To clone the repository).
3.  **VS Code** (Optional, for editing code).
4.  **An Android Phone** (To install the final APK).

---

## 🚀 Step 1: Create the Environment

We use a `Dockerfile.dev` to create a virtual Linux build server. Create a file named `Dockerfile.dev` in the project root with this content:

```dockerfile
# Use stable Flutter image (includes Android SDK & Java)
FROM ghcr.io/cirruslabs/flutter:stable

# Set working directory
WORKDIR /app

# Install necessary Linux tools for compiling plugins
RUN sudo apt-get update && sudo apt-get install -y \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev

# Accept Android Licenses
RUN yes | flutter doctor --android-licenses

# Copy pubspec files first to cache dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Expose ports
EXPOSE 8080 
```

---

## 🏗 Step 2: Build the Docker Image

Open your terminal (Terminal on Mac, **PowerShell** on Windows) and run the command for your OS.

### 🍎 macOS (Apple Silicon M1/M2/M3)
*Note: The `--platform` flag is crucial for Mac to ensure Android NDK compatibility.*
```bash
docker build --platform linux/amd64 -t studentos-dev -f Dockerfile.dev .
```

### 🪟 Windows / Linux (Intel/AMD)
```powershell
docker build -t studentos-dev -f Dockerfile.dev .
```

---

## 💻 Step 3: Run the Container

This command mounts your local folder into the container, so the APK generated inside appears on your computer automatically.

### 🍎 macOS / Linux
```bash
docker run --platform linux/amd64 -it --rm \
  -v "$(pwd):/app" \
  -p 8080:8080 \
  studentos-dev /bin/bash
```

### 🪟 Windows (PowerShell)
```powershell
docker run -it --rm `
  -v ${PWD}:/app `
  -p 8080:8080 `
  studentos-dev /bin/bash
```

*You are now inside the Linux container.*

---

## ⚙️ Step 4: Configure & Build (Inside Container)

**Note:** Regardless of whether you are on Windows or Mac, you are now inside a **Linux** environment. Run the following commands exactly as written.

### 1. Navigate to the code
```bash
cd studentos
```
*(Note: If your code is in the root mapped folder, this might not be needed. Use `ls` to check).*

### 2. Regenerate Android Config
If moving between Windows/Mac and Docker, run this to fix Gradle paths:
```bash
flutter create . --platforms android
```

### 3. Apply Build Fixes (Desugaring & Memory)
Execute this command block to overwrite `android/app/build.gradle.kts` with the necessary "Desugaring" fixes required for Notifications and File Picker:

```bash
cat <<EOF > android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.studentos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.studentos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
EOF
```

### 4. Build the APK
Run the build command.

```bash
flutter build apk --release
```

*If the build crashes due to memory, run `flutter clean` and try again.*

---

## 📲 Step 5: Install on Phone

Once the build finishes, the file is available on your **Computer** (outside Docker) at:

`studentos/build/app/outputs/flutter-apk/app-release.apk`

1.  Transfer this file to your Android phone (via USB, Drive, or Quick Share).
2.  Open it on your phone.
3.  Allow "Install from Unknown Sources".
4.  Enjoy StudentOS!

---

## 🐛 Troubleshooting

*   **"Gradle daemon disappeared"**: This is an Out of Memory error. Restart the container or run `flutter clean`.
*   **"Kanji/Chinese characters instead of Icons"**: Ensure `uses-material-design: true` is in `pubspec.yaml`.
*   **"Desugaring required"**: Re-run the `cat <<EOF ...` command in Step 4.3 to fix `build.gradle.kts`.
*   **Windows Volume Mounting Issues**: If the folder is empty inside Docker, ensure you accepted the Docker File Sharing prompt when you ran the container.
