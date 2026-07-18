package com.example.safe_senior

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the call-blocker plugin (MethodChannel bridge)
        CallBlockerPlugin.register(this, flutterEngine)
    }
}
