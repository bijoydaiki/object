//package com.example.object_detection
//
//import android.graphics.Bitmap
//import android.graphics.BitmapFactory
//import android.graphics.Matrix
//import android.media.ExifInterface
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugin.common.MethodChannel
//import org.tensorflow.lite.DataType
//import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
//import com.example.object_detection.ml.Model
//import java.io.BufferedReader
//import java.io.File
//import java.io.InputStreamReader
//import java.nio.ByteBuffer
//import java.nio.ByteOrder
//
//class MainActivity : FlutterActivity() {
//    private val CHANNEL = "com.example.object_detection/classifier"
//    private val IMAGE_SIZE = 224 // Must match your model's expected input size
//    private lateinit var CLASSES: Array<String>
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//
//        loadLabels()
//
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
//            .setMethodCallHandler { call, result ->
//                when (call.method) {
//                    "classifyImage" -> {
//                        try {
//                            val imagePath = call.argument<String>("imagePath")
//                            if (imagePath != null) {
//                                val classification = classifyImage(imagePath)
//                                result.success(classification)
//                            } else {
//                                result.error("INVALID_INPUT", "Image path is null", null)
//                            }
//                        } catch (e: Exception) {
//                            result.error("CLASSIFICATION_ERROR", "Error classifying image: ${e.message}", e.stackTraceToString())
//                        }
//                    }
//                    else -> {
//                        result.notImplemented()
//                    }
//                }
//            }
//    }
//
//    private fun loadLabels() {
//        try {
//            val inputStream = assets.open("labels.txt")
//            val reader = BufferedReader(InputStreamReader(inputStream))
//            val labels = mutableListOf<String>()
//            reader.useLines { lines ->
//                lines.forEach { labels.add(it.trim()) }
//            }
//            CLASSES = labels.toTypedArray()
//            inputStream.close()
//        } catch (e: Exception) {
//            CLASSES = arrayOf("-----")
//            e.printStackTrace()
//        }
//    }
//
//    private fun classifyImage(imagePath: String): String {
//        val imageFile = File(imagePath)
//        if (!imageFile.exists()) {
//            throw Exception("Image file not found at path: $imagePath")
//        }
//
//        // Load and rotate image based on EXIF orientation
//        val bitmap = BitmapFactory.decodeFile(imagePath) ?: throw Exception("Could not decode image")
//        val rotatedBitmap = rotateBitmapIfNeeded(bitmap, imagePath)
//        val resizedBitmap = Bitmap.createScaledBitmap(rotatedBitmap, IMAGE_SIZE, IMAGE_SIZE, true)
//
//        val inputFeature0 = TensorBuffer.createFixedSize(intArrayOf(1, IMAGE_SIZE, IMAGE_SIZE, 3), DataType.FLOAT32)
//        val byteBuffer = ByteBuffer.allocateDirect(4 * IMAGE_SIZE * IMAGE_SIZE * 3)
//        byteBuffer.order(ByteOrder.nativeOrder())
//
//        val intValues = IntArray(IMAGE_SIZE * IMAGE_SIZE)
//        resizedBitmap.getPixels(intValues, 0, IMAGE_SIZE, 0, 0, IMAGE_SIZE, IMAGE_SIZE)
//
//        var pixel = 0
//        for (i in 0 until IMAGE_SIZE) {
//            for (j in 0 until IMAGE_SIZE) {
//                val value = intValues[pixel++]
//                byteBuffer.putFloat(((value shr 16) and 0xFF) * (1f / 255f)) // Red
//                byteBuffer.putFloat(((value shr 8) and 0xFF) * (1f / 255f))  // Green
//                byteBuffer.putFloat((value and 0xFF) * (1f / 255f))          // Blue
//            }
//        }
//
//        inputFeature0.loadBuffer(byteBuffer)
//
//        val model = Model.newInstance(applicationContext)
//        val outputs = model.process(inputFeature0)
//        val outputFeature0 = outputs.outputFeature0AsTensorBuffer
//
//        val confidences = outputFeature0.floatArray
//
//        // Debug output
//        println("Confidence scores: ${confidences.joinToString()}")
//        println("Model output size: ${confidences.size}, Label size: ${CLASSES.size}")
//
//        var maxPos = 0
//        var maxConfidence = 0f
//        for (i in confidences.indices) {
//            if (confidences[i] > maxConfidence) {
//                maxConfidence = confidences[i]
//                maxPos = i
//            }
//        }
//
//        model.close()
//        bitmap.recycle()
//        rotatedBitmap.recycle()
//        resizedBitmap.recycle()
//
//        return if (maxPos < CLASSES.size && maxConfidence > 0.5f) { // Lowered threshold to 0.5 for testing
//            "${CLASSES[maxPos]} (${String.format("%.2f", maxConfidence * 100)}%)"
//        } else {
//            if (maxPos >= CLASSES.size) {
//                "Unknown (Model output index $maxPos exceeds label count ${CLASSES.size})"
//            } else {
//                "Unknown (Confidence: ${String.format("%.2f", maxConfidence * 100)}%)"
//            }
//        }
//    }
//
//    private fun rotateBitmapIfNeeded(bitmap: Bitmap, imagePath: String): Bitmap {
//        val exif = ExifInterface(imagePath)
//        val orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
//        val matrix = Matrix()
//
//        when (orientation) {
//            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
//            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
//            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
//        }
//
//        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
//    }
//}

//  ============  ///


package com.example.object_detection

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.tensorflow.lite.DataType
import org.tensorflow.lite.support.tensorbuffer.TensorBuffer
import com.example.object_detection.ml.Model
import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import java.nio.ByteBuffer
import java.nio.ByteOrder

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.object_detection/classifier"
    private val IMAGE_SIZE = 224 // Must match your model's expected input size
    private lateinit var CLASSES: Array<String>

    // Increasing primary threshold for more strict classification
    private val PRIMARY_CONFIDENCE_THRESHOLD = 0.85f

    // Adding secondary threshold for detecting irrelevant images
    private val SECONDARY_CONFIDENCE_THRESHOLD = 0.65f

    // Adding a threshold for entropy to detect uncertain predictions
    private val ENTROPY_THRESHOLD = 0.5f

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        loadLabels()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "classifyImage" -> {
                        try {
                            val imagePath = call.argument<String>("imagePath")
                            if (imagePath != null) {
                                val classification = classifyImage(imagePath)
                                result.success(classification)
                            } else {
                                result.error("INVALID_INPUT", "Image path is null", null)
                            }
                        } catch (e: Exception) {
                            result.error("CLASSIFICATION_ERROR", "Error classifying image: ${e.message}", e.stackTraceToString())
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun loadLabels() {
        try {
            val inputStream = assets.open("labels.txt")
            val reader = BufferedReader(InputStreamReader(inputStream))
            val labels = mutableListOf<String>()
            reader.useLines { lines ->
                lines.forEach { labels.add(it.trim()) }
            }
            CLASSES = labels.toTypedArray()
            inputStream.close()
        } catch (e: Exception) {
            CLASSES = arrayOf("-----")
            e.printStackTrace()
        }
    }

    private fun classifyImage(imagePath: String): String {
        val imageFile = File(imagePath)
        if (!imageFile.exists()) {
            throw Exception("Image file not found at path: $imagePath")
        }

        // Load and rotate image based on EXIF orientation
        val bitmap = BitmapFactory.decodeFile(imagePath) ?: throw Exception("Could not decode image")
        val rotatedBitmap = rotateBitmapIfNeeded(bitmap, imagePath)
        val resizedBitmap = Bitmap.createScaledBitmap(rotatedBitmap, IMAGE_SIZE, IMAGE_SIZE, true)

        val inputFeature0 = TensorBuffer.createFixedSize(intArrayOf(1, IMAGE_SIZE, IMAGE_SIZE, 3), DataType.FLOAT32)
        val byteBuffer = ByteBuffer.allocateDirect(4 * IMAGE_SIZE * IMAGE_SIZE * 3)
        byteBuffer.order(ByteOrder.nativeOrder())

        val intValues = IntArray(IMAGE_SIZE * IMAGE_SIZE)
        resizedBitmap.getPixels(intValues, 0, IMAGE_SIZE, 0, 0, IMAGE_SIZE, IMAGE_SIZE)

        var pixel = 0
        for (i in 0 until IMAGE_SIZE) {
            for (j in 0 until IMAGE_SIZE) {
                val value = intValues[pixel++]
                byteBuffer.putFloat(((value shr 16) and 0xFF) * (1f / 255f)) // Red
                byteBuffer.putFloat(((value shr 8) and 0xFF) * (1f / 255f))  // Green
                byteBuffer.putFloat((value and 0xFF) * (1f / 255f))          // Blue
            }
        }

        inputFeature0.loadBuffer(byteBuffer)

        val model = Model.newInstance(applicationContext)
        val outputs = model.process(inputFeature0)
        val outputFeature0 = outputs.outputFeature0AsTensorBuffer

        val confidences = outputFeature0.floatArray

        // Debug output
        println("Confidence scores: ${confidences.joinToString()}")
        println("Model output size: ${confidences.size}, Label size: ${CLASSES.size}")

        // Find the class with the highest confidence
        var maxPos = 0
        var maxConfidence = 0f
        var secondMaxConfidence = 0f

        for (i in confidences.indices) {
            if (confidences[i] > maxConfidence) {
                secondMaxConfidence = maxConfidence
                maxConfidence = confidences[i]
                maxPos = i
            } else if (confidences[i] > secondMaxConfidence) {
                secondMaxConfidence = confidences[i]
            }
        }

        // Calculate entropy to measure uncertainty
        val entropy = calculateEntropy(confidences)

        // Calculate the difference between top two classes
        val confidenceDifference = maxConfidence - secondMaxConfidence

        model.close()
        bitmap.recycle()
        rotatedBitmap.recycle()
        resizedBitmap.recycle()

        // Advanced detection logic
        return when {
            // High confidence in breast cancer class - check if it's the first class
            maxPos == 0 && maxConfidence > PRIMARY_CONFIDENCE_THRESHOLD &&
                    confidenceDifference > 0.3f && entropy < ENTROPY_THRESHOLD -> {
                "Breast Cancer (${String.format("%.2f", maxConfidence * 100)}%)"
            }

            // High confidence in normal skin class - check if it's the second class
            maxPos == 1 && maxConfidence > PRIMARY_CONFIDENCE_THRESHOLD &&
                    confidenceDifference > 0.3f && entropy < ENTROPY_THRESHOLD -> {
                "Fresh Skin (${String.format("%.2f", maxConfidence * 100)}%)"
            }

            // Medium confidence but with high uncertainty - likely an invalid image
            maxConfidence > SECONDARY_CONFIDENCE_THRESHOLD &&
                    (confidenceDifference < 0.2f || entropy > ENTROPY_THRESHOLD) -> {
                "Invalid image - please try again with proper scan"
            }

            // Low confidence across all classes
            else -> {
                "No clear detection - please try again with a clearer image"
            }
        }
    }

    // Calculate Shannon entropy to measure prediction uncertainty
    private fun calculateEntropy(confidences: FloatArray): Float {
        var entropy = 0f
        val sum = confidences.sum()

        // Normalize the confidences
        val normalizedConfidences = confidences.map { it / sum }

        // Calculate entropy
        normalizedConfidences.forEach { p ->
            if (p > 0) {
                entropy -= p * kotlin.math.log2(p.toDouble()).toFloat()
            }
        }

        return entropy
    }

    private fun rotateBitmapIfNeeded(bitmap: Bitmap, imagePath: String): Bitmap {
        val exif = ExifInterface(imagePath)
        val orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL)
        val matrix = Matrix()

        when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.postRotate(90f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.postRotate(180f)
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.postRotate(270f)
        }

        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }
}