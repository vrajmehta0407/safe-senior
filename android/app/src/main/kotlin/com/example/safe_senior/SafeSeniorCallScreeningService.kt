package com.example.safe_senior

import android.telecom.Call
import android.telecom.CallScreeningService
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.FlutterEngineCache

/**
 * CallScreeningService implementation.
 *
 * The OS calls onScreenCall() for every incoming call when this app holds the
 * ROLE_CALL_SCREENING role. We ask the Flutter engine (via MethodChannel) whether
 * this number is on the blocklist. If yes, we reject the call silently.
 *
 * Registration in AndroidManifest.xml:
 *   <service android:name=".SafeSeniorCallScreeningService"
 *            android:permission="android.permission.BIND_SCREENING_SERVICE"
 *            android:exported="true">
 *       <intent-filter>
 *           <action android:name="android.telecom.CallScreeningService"/>
 *       </intent-filter>
 *   </service>
 */
@RequiresApi(Build.VERSION_CODES.Q)
class SafeSeniorCallScreeningService : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneNumber = callDetails.handle?.schemeSpecificPart ?: ""
        val responseBuilder = CallResponse.Builder()

        // Ask Flutter engine if this number should be blocked
        val shouldBlock = queryFlutterBlocklist(phoneNumber)

        if (shouldBlock) {
            responseBuilder
                .setDisallowCall(true)
                .setRejectCall(true)
                .setSkipCallLog(false)   // Keep in call log so user sees it
                .setSkipNotification(true)
        } else {
            responseBuilder
                .setDisallowCall(false)
                .setRejectCall(false)
        }

        respondToCall(callDetails, responseBuilder.build())

        // Notify Flutter side for stats update
        notifyFlutter(phoneNumber, shouldBlock)
    }

    private fun queryFlutterBlocklist(phoneNumber: String): Boolean {
        return try {
            val engine = FlutterEngineCache.getInstance().get(CallBlockerPlugin.ENGINE_ID)
                ?: return false
            val channel = engine.dartExecutor.binaryMessenger
            var result = false
            io.flutter.plugin.common.MethodChannel(channel, CallBlockerPlugin.CHANNEL_NAME)
                .invokeMethod("checkBlocklist", phoneNumber,
                    object : io.flutter.plugin.common.MethodChannel.Result {
                        override fun success(r: Any?) { result = r as? Boolean ?: false }
                        override fun error(code: String, msg: String?, details: Any?) {}
                        override fun notImplemented() {}
                    })
            result
        } catch (e: Exception) {
            false
        }
    }

    private fun notifyFlutter(phoneNumber: String, blocked: Boolean) {
        try {
            val engine = FlutterEngineCache.getInstance().get(CallBlockerPlugin.ENGINE_ID)
                ?: return
            val channel = io.flutter.plugin.common.MethodChannel(
                engine.dartExecutor.binaryMessenger, CallBlockerPlugin.CHANNEL_NAME
            )
            channel.invokeMethod("onCallScreened", mapOf("phone" to phoneNumber, "blocked" to blocked))
        } catch (_: Exception) {}
    }
}
