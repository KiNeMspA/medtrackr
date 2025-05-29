package com.kinemspa.medtrackr

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Binder
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
    private var isMethodChannelInitialized = false // Track initialization state
    private lateinit var handler: Handler
    private lateinit var timer: Timer
    private val dataRepository = DataRepository()
    private var counter = 0
    private val binder = LocalBinder()

    inner class LocalBinder : Binder() {
        fun getService(): DataCollectionService = this@DataCollectionService
    }

    companion object {
        const val CHANNEL_ID = "DataCollectionChannel"
        const val NOTIFICATION_ID = 1
        const val METHOD_CHANNEL = "com.kinemspa.medtrackr/data_collection"
    }

    override fun onCreate() {
        super.onCreate()
        handler = Handler(Looper.getMainLooper())
        timer = Timer()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Data Collection Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("MedTrackr Data Collection")
            .setContentText("Collecting data in the background")
            .setSmallIcon(android.R.drawable.ic_notification_overlay)
            .build()

        startForeground(NOTIFICATION_ID, notification)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                counter++
                val data = "Data point $counter at ${System.currentTimeMillis()}"
                dataRepository.addData(data)

                handler.post {
                    // Only invoke if methodChannel is initialized
                    if (isMethodChannelInitialized) {
                        methodChannel.invokeMethod("onDataCollected", data)
                    }
                }
            }
        }, 0, 15 * 60 * 1000)

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }

    override fun onDestroy() {
        super.onDestroy()
        timer.cancel()
        stopForeground(true)
    }

    fun setMethodChannel(channel: MethodChannel) {
        this.methodChannel = channel
        this.isMethodChannelInitialized = true
    }
}

class DataRepository {
    private val dataList = mutableListOf<String>()

    fun addData(data: String) {
        dataList.add(data)
    }

    fun getAllData(): List<String> {
        return dataList.toList()
    }
}

class DataCollectionPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var service: DataCollectionService? = null
    private val serviceConnection = object : android.content.ServiceConnection {
        override fun onServiceConnected(name: android.content.ComponentName?, service: IBinder?) {
            val binder = service as DataCollectionService.LocalBinder
            this@DataCollectionPlugin.service = binder.getService()
            this@DataCollectionPlugin.service?.setMethodChannel(channel)
        }

        override fun onServiceDisconnected(name: android.content.ComponentName?) {
            this@DataCollectionPlugin.service = null
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, DataCollectionService.METHOD_CHANNEL)
        channel.setMethodCallHandler(this)

        val intent = Intent(binding.applicationContext, DataCollectionService::class.java)
        binding.applicationContext.startForegroundService(intent)
        binding.applicationContext.bindService(intent, serviceConnection, BIND_AUTO_CREATE)
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
        binding.applicationContext.unbindService(serviceConnection)
        service = null
    }
}