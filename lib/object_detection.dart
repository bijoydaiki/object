import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

// ResultDisplay Widget as StatelessWidget
class ResultDisplay extends StatelessWidget {
  final double finalPercentage;
  final String result;
  final Color resultColor;

  const ResultDisplay({
    Key? key,
    required this.finalPercentage,
    required this.result,
    required this.resultColor,
  }) : super(key: key);

  String getRiskMessage() {
    if (finalPercentage >= 70) {
      return "High Risk: Please consult a doctor immediately.";
    } else if (finalPercentage >= 50) {
      return "Moderate Risk: Consider visiting a doctor for a check-up.";
    } else {
      return "Low Risk: No immediate concern, but monitor for changes.";
    }
  }

  Color getRiskColor() {
    if (finalPercentage >= 70) return Colors.red[700]!;
    if (finalPercentage >= 50) return Colors.orange[700]!;
    return Colors.green[700]!;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.02), // Responsive padding
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFFFFFFFF),
              width: 2,
            ),
          ),
          child: Text(
            result,
            style: TextStyle(
              fontSize: screenWidth * 0.05, // Responsive font size
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Card(
          color: Colors.white,
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Final Risk Percentage",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "${finalPercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: getRiskColor(),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  getRiskMessage(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  final double affectedPercentage;
  const ObjectDetectionScreen({Key? key, required this.affectedPercentage}) : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  static const platform = MethodChannel('com.example.object_detection/classifier');
  File? _image;
  String _result = 'No detection yet';
  bool _isLoading = false;
  Color _resultColor = Colors.black;
  double _finalPercentage = 0.0;
  final picker = ImagePicker();

  Future<void> _getImageAndClassify(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _result = 'Processing...';
          _isLoading = true;
          _resultColor = Colors.blue;
        });

        final String result = await _classifyImage(pickedFile.path);

        // Calculate final percentage based on detection
        double finalPercentage = _calculateFinalPercentage(result);

        Color resultColor;
        if (result.contains("Breast Cancer")) {
          resultColor = Colors.white;
        } else if (result.contains("Fresh Skin")) {
          resultColor = Colors.green;
        } else if (result.contains("Invalid") || result.contains("No clear detection")) {
          resultColor = Colors.orange;
        } else {
          resultColor = Colors.black;
        }

        setState(() {
          _result = result;
          _isLoading = false;
          _resultColor = resultColor;
          _finalPercentage = finalPercentage;
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
        _resultColor = Colors.red;
        _finalPercentage = 0.0;
      });
      _showErrorDialog(e.toString());
    }
  }

  double _calculateFinalPercentage(String result) {
    const double breastCancerBasePercentage = 75.0;
    const double freshSkinPercentage = 10.0;

    if (result.contains("Breast Cancer")) {
      return (breastCancerBasePercentage + widget.affectedPercentage) / 2;
    } else if (result.contains("Fresh Skin")) {
      return freshSkinPercentage;
    } else {
      return 0.0;
    }
  }

  Future<String> _classifyImage(String imagePath) async {
    try {
      final String result = await platform.invokeMethod('classifyImage', {
        'imagePath': imagePath,
      });
      return result;
    } on PlatformException catch (e) {
      return "Failed to classify image: ${e.message}";
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred during image processing. Please try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructionCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions:',
              style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text('1. Ensure proper lighting for accurate detection.', style: TextStyle(fontSize: screenWidth * 0.035)),
            Text('2. Hold the camera steady when taking a picture.', style: TextStyle(fontSize: screenWidth * 0.035)),
            Text('3. Make sure the image is clear and focused.', style: TextStyle(fontSize: screenWidth * 0.035)),
            Text('4. Results below 85% confidence may be unreliable.', style: TextStyle(fontSize: screenWidth * 0.035)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Breast Cancer Detection',
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF046027),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildInstructionCard(),
                SizedBox(height: screenHeight * 0.02),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenWidth * 0.9,
                    maxHeight: screenHeight * 0.4,
                  ),
                  child: _image == null
                      ? Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFFA3CFB2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: screenWidth * 0.15,
                      color: Color(0xFF046027),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                _isLoading
                    ? Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Analyzing image...',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
                    : ResultDisplay(
                  finalPercentage: _finalPercentage,
                  result: _result,
                  resultColor: _resultColor,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.camera),
            icon: Icon(Icons.camera_alt, color: Colors.white, size: screenWidth * 0.06),
            label: Text(
              'Take Picture',
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.015),
              backgroundColor: Color(0xFF046027),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          TextButton.icon(
            onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.gallery),
            icon: Icon(Icons.photo_library, color: Colors.white, size: screenWidth * 0.06),
            label: Text(
              'Gallery',
              style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.015),
              backgroundColor: Colors.pink[300],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}