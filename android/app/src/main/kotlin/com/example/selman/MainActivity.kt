package com.example.selman

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServicePlugin

class MainActivity: FlutterActivity() {
    // This is the required setup for audio_service.
    override fun provideFlutterEngine(context: android.content.Context): FlutterEngine? {
        return AudioServicePlugin.getFlutterEngine(context)
    }
}