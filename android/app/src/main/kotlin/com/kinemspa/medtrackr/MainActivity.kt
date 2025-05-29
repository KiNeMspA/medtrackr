package com.kinemspa.medtrackr

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // Register the DataCollectionPlugin
        flutterEngine?.plugins?.add(DataCollectionPlugin())
    }
}