#!/usr/bin/env python3
"""
Android Configuration Setup Script for Flutter Projects
========================================================
This script generates all required Android configuration files for a Flutter project.
Useful when building on CI/CD systems like GitHub Actions where Flutter create isn't available.

Usage:
    python setup_android.py

Run from the project root directory (where pubspec.yaml is located).
"""

import os
from pathlib import Path

# Configuration
APP_NAME = "Bilingual Kids"
PACKAGE_NAME = "com.example.bilingual_kids"
MIN_SDK = 21
TARGET_SDK = 34
COMPILE_SDK = 34
KOTLIN_VERSION = "1.9.22"
GRADLE_PLUGIN_VERSION = "8.1.0"
GRADLE_WRAPPER_VERSION = "8.3"

def get_project_root():
    """Get the project root directory (where this script is located)."""
    return Path(__file__).parent.resolve()

def create_directory(path):
    """Create directory if it doesn't exist."""
    Path(path).mkdir(parents=True, exist_ok=True)
    print(f"✓ Created directory: {path}")

def write_file(path, content):
    """Write content to file, creating parent directories if needed."""
    file_path = Path(path)
    file_path.parent.mkdir(parents=True, exist_ok=True)
    file_path.write_text(content, encoding='utf-8')
    print(f"✓ Created file: {path}")

def setup_android():
    """Main function to set up all Android configuration files."""
    root = get_project_root()
    android_dir = root / "android"
    app_dir = android_dir / "app"
    main_dir = app_dir / "src" / "main"
    kotlin_dir = main_dir / "kotlin" / PACKAGE_NAME.replace(".", "/")
    res_dir = main_dir / "res"

    print("\n" + "="*60)
    print("🚀 Setting up Android configuration for Flutter project")
    print("="*60 + "\n")

    # 1. Root build.gradle
    write_file(android_dir / "build.gradle", f'''buildscript {{
    ext.kotlin_version = '{KOTLIN_VERSION}'
    repositories {{
        google()
        mavenCentral()
    }}

    dependencies {{
        classpath 'com.android.tools.build:gradle:{GRADLE_PLUGIN_VERSION}'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }}
}}

allprojects {{
    repositories {{
        google()
        mavenCentral()
    }}
}}

rootProject.buildDir = '../build'
subprojects {{
    project.buildDir = "${{rootProject.buildDir}}/${{project.name}}"
}}
subprojects {{
    project.evaluationDependsOn(':app')
}}

tasks.register("clean", Delete) {{
    delete rootProject.buildDir
}}
''')

    # 2. settings.gradle
    write_file(android_dir / "settings.gradle", f'''pluginManagement {{
    def flutterSdkPath = {{
        def properties = new Properties()
        file("local.properties").withInputStream {{ properties.load(it) }}
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }}()

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {{
        google()
        mavenCentral()
        gradlePluginPortal()
    }}
}}

plugins {{
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "{GRADLE_PLUGIN_VERSION}" apply false
    id "org.jetbrains.kotlin.android" version "{KOTLIN_VERSION}" apply false
}}

include ":app"
''')

    # 3. gradle.properties
    write_file(android_dir / "gradle.properties", '''org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
''')

    # 4. Gradle wrapper properties
    write_file(android_dir / "gradle" / "wrapper" / "gradle-wrapper.properties", f'''distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\\://services.gradle.org/distributions/gradle-{GRADLE_WRAPPER_VERSION}-all.zip
''')

    # 5. App build.gradle
    write_file(app_dir / "build.gradle", f'''plugins {{
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {{
    localPropertiesFile.withReader('UTF-8') {{ reader ->
        localProperties.load(reader)
    }}
}}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {{
    flutterVersionCode = '1'
}}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {{
    flutterVersionName = '1.0'
}}

android {{
    namespace "{PACKAGE_NAME}"
    compileSdk {COMPILE_SDK}
    ndkVersion flutter.ndkVersion

    compileOptions {{
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }}

    kotlinOptions {{
        jvmTarget = '1.8'
    }}

    sourceSets {{
        main.java.srcDirs += 'src/main/kotlin'
    }}

    defaultConfig {{
        applicationId "{PACKAGE_NAME}"
        minSdk {MIN_SDK}
        targetSdk {TARGET_SDK}
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }}

    buildTypes {{
        release {{
            signingConfig signingConfigs.debug
        }}
    }}
}}

flutter {{
    source '../..'
}}

dependencies {{}}
''')

    # 6. AndroidManifest.xml
    write_file(main_dir / "AndroidManifest.xml", f'''<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="{APP_NAME}"
        android:name="${{applicationName}}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
''')

    # 7. MainActivity.kt
    write_file(kotlin_dir / "MainActivity.kt", f'''package {PACKAGE_NAME}

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
''')

    # 8. styles.xml
    write_file(res_dir / "values" / "styles.xml", '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
''')

    # 9. night styles.xml
    write_file(res_dir / "values-night" / "styles.xml", '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">?android:colorBackground</item>
    </style>
</resources>
''')

    # 10. launch_background.xml
    write_file(res_dir / "drawable" / "launch_background.xml", '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />
</layer-list>
''')

    # 11. launch_background.xml v21
    write_file(res_dir / "drawable-v21" / "launch_background.xml", '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
</layer-list>
''')

    # 12. Create placeholder mipmap directories and ic_launcher.xml
    mipmap_densities = ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']
    for density in mipmap_densities:
        create_directory(res_dir / f"mipmap-{density}")
    
    # Adaptive icon configuration
    write_file(res_dir / "mipmap-anydpi-v26" / "ic_launcher.xml", '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
''')

    # 13. ic_launcher colors
    write_file(res_dir / "values" / "colors.xml", '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#673AB7</color>
</resources>
''')

    # 14. Foreground drawable placeholder
    write_file(res_dir / "drawable" / "ic_launcher_foreground.xml", '''<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M54,54m-40,0a40,40 0,1 1,80 0a40,40 0,1 1,-80 0"/>
    <path
        android:fillColor="#673AB7"
        android:pathData="M54,30L54,78M30,54L78,54"
        android:strokeWidth="8"
        android:strokeColor="#673AB7"/>
</vector>
''')

    # 15. .gitignore for android
    write_file(android_dir / ".gitignore", '''gradle-wrapper.jar
/.gradle
/captures/
/gradlew
/gradlew.bat
/local.properties
GeneratedPluginRegistrant.java
''')

    print("\n" + "="*60)
    print("✅ Android configuration setup complete!")
    print("="*60)
    print(f"""
📱 App Configuration:
   • Package: {PACKAGE_NAME}
   • Name: {APP_NAME}
   • Min SDK: {MIN_SDK}
   • Target SDK: {TARGET_SDK}

📂 Files created in android/:
   • build.gradle
   • settings.gradle
   • gradle.properties
   • gradle/wrapper/gradle-wrapper.properties
   • app/build.gradle
   • app/src/main/AndroidManifest.xml
   • app/src/main/kotlin/.../MainActivity.kt
   • app/src/main/res/values/styles.xml
   • app/src/main/res/drawable/launch_background.xml
   • ... and more

🚀 Next steps:
   1. Commit these files to your repository
   2. Push to GitHub to trigger the CI build
   3. The GitHub Actions workflow will handle the rest!
""")

if __name__ == "__main__":
    setup_android()
