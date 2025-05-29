package com.kinemspa.medtrackr

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Timer
import java.util.TimerTask

class DataCollectionService : Service() {
    private lateinit var methodChannel: MethodChannel
    private lateinit var handler: Handler
    private lateinit var timer: Timer
    private val dataRepository = DataRepository()
    private var counter = 0

    companion object {
        const val CHANNEL_ID = "DataCollectionChannel"
        const val NOTIFICATION_ID = 1
        const val METHOD_CHANNEL = "com.kinemspa.medtrackr/data_collection"
    }

    override fun onCreate() {
        super.onCreate()
        handler = Handler(Looper.getMainLooper())
        timer = Timer()

        // Create notification channel for Android O and above
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Data Collection Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        // Start foreground service with a notification
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MedTrackr Data Collection")
            .setContentText("Collecting data in the background")
            .setSmallIcon(android.R.drawable.ic_notification_overlay)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Schedule periodic data collection every 15 minutes
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                counter++
                val data = "Data point $counter at ${System.currentTimeMillis()}"
                dataRepository.addData(data)

                // Send data to Flutter via MethodChannel
                handler.post {
                    methodChannel.invokeMethod("onDataCollected", data)
                }
            }
        }, 0, 15 * 60 * 1000) // 15 minutes in milliseconds

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        timer.cancel()
        stopForeground(true)
    }

    // Method to set the MethodChannel from Flutter
    fun setMethodChannel(channel: MethodChannel) {
        this.methodChannel = channel
    }
}

// Repository to store collected data
class DataRepository {
    private val dataList = mutableListOf<String>()

    fun addData(data: String) {
        dataList.add(data)
    }

    fun getAllData(): List<String> {
        return dataList.toList()
    }
}

// Flutter plugin to handle communication between Kotlin and Flutter
class DataCollectionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var service: DataCollectionService? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, DataCollectionService.METHOD_CHANNEL)
        channel.setMethodCallHandler(this)

        // Start the service
        val intent = Intent(binding.applicationContext, DataCollectionService::class.java)
        binding.applicationContext.startForegroundService(intent)

        // Set the MethodChannel on the service (requires service instance access)
        // For simplicity, we're assuming the service is already running; in a real app, you'd need a more robust way to bind to the service
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getCollectedData" -> {
                val data = DataRepository().getAllData()
                result.success(data)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}