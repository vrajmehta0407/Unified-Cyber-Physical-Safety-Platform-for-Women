package com.cybershield.cybershield

import android.Manifest
import android.content.pm.PackageManager
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.cybershield/sms"
    private val SMS_PERMISSION_REQUEST_CODE = 101

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    if (phoneNumber == null || message == null) {
                        result.error("INVALID_ARGS", "Phone number and message are required", null)
                        return@setMethodCallHandler
                    }
                    try {
                        if (ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS)
                            != PackageManager.PERMISSION_GRANTED) {
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.SEND_SMS),
                                SMS_PERMISSION_REQUEST_CODE
                            )
                            result.error("PERMISSION_DENIED", "SMS permission not granted. Please allow SMS permission and try again.", null)
                            return@setMethodCallHandler
                        }
                        val smsManager = SmsManager.getDefault()
                        val parts = smsManager.divideMessage(message)
                        smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SMS_FAILED", e.message, null)
                    }
                }
                "checkSmsPermission" -> {
                    val hasPermission = ContextCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED
                    result.success(hasPermission)
                }
                "requestSmsPermission" -> {
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.SEND_SMS),
                        SMS_PERMISSION_REQUEST_CODE
                    )
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
