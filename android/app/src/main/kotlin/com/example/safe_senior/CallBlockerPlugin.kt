package com.example.safe_senior

import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

/**
 * Flutter ↔ Android MethodChannel bridge for call blocking.
 *
 * Exposes two methods to Flutter:
 *   - requestCallScreeningRole → triggers the system role-request dialog
 *   - isCallScreeningRoleHeld  → returns true/false
 *
 * Listens for:
 *   - checkBlocklist(phoneNumber: String) → Boolean  (called from CallScreeningService)
 *   - onCallScreened(data: Map)                      (event fired back to Flutter)
 */
object CallBlockerPlugin {
    const val CHANNEL_NAME = "com.safesenior/call_blocker"
    const val ENGINE_ID = "safe_senior_engine"
    const val ROLE_REQUEST_CODE = 1001

    fun register(activity: MainActivity, flutterEngine: FlutterEngine) {
        // Cache engine so CallScreeningService can reach it
        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestCallScreeningRole" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            requestRole(activity)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    }
                    "isCallScreeningRoleHeld" -> {
                        result.success(isRoleHeld(activity))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun requestRole(activity: MainActivity) {
        val roleManager = activity.getSystemService(Context.ROLE_SERVICE) as RoleManager
        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
        activity.startActivityForResult(intent, ROLE_REQUEST_CODE)
    }

    private fun isRoleHeld(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        val roleManager = context.getSystemService(Context.ROLE_SERVICE) as RoleManager
        return roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
    }
}
