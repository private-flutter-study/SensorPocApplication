package com.example.sensor_poc_application

import android.content.Context
import android.content.Context.SENSOR_SERVICE
import android.hardware.Sensor
import android.hardware.SensorEventListener
import android.hardware.SensorEvent
import android.hardware.SensorManager
import androidx.lifecycle.ReportFragment.Companion.reportFragment
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(){
    private lateinit var senserManager: SensorManager
    private  var sensor: Sensor? = null
    private  var sensorEventListener: SensorEventListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.sensor_poc_application"
        )

        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "startSensorUpdate") {
                startAccelerometer(methodChannel)
                result.success(true)
            }
        }
    }

        private fun startAccelerometer(methodChannel: MethodChannel){
            senserManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
            sensor = senserManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

            sensorEventListener = object : SensorEventListener{
                override fun onSensorChanged(event: SensorEvent?) {
                    if (event != null){
                        val x = event.values[0]
                        val y = event.values[1]
                        methodChannel.invokeMethod("sensorUpdate", listOf(x, y))
                        methodChannel.invokeMethod("a", listOf(x, y))
                    }
                }

                override fun onAccuracyChanged(p0: Sensor?, p1: Int) {}
            }
            senserManager.registerListener(sensorEventListener, sensor, SensorManager.SENSOR_DELAY_GAME)
        }

}
