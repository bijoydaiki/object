import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isWeb ? 16.0 : screenWidth * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Text(
            result,
            style: TextStyle(
              fontSize: isWeb ? 20.0 : screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isWeb ? 16.0 : screenWidth * 0.01),
        Card(
          color: Colors.white,
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(isWeb ? 20.0 : screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Final Risk Percentage",
                  style: TextStyle(
                    fontSize: isWeb ? 18.0 : screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: isWeb ? 10.0 : screenWidth * 0.01),
                Text(
                  "${finalPercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: isWeb ? 32.0 : screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: getRiskColor(),
                  ),
                ),
                SizedBox(height: isWeb ? 10.0 : screenWidth * 0.01),
                Text(
                  getRiskMessage(),
                  style: TextStyle(
                    fontSize: isWeb ? 16.0 : screenWidth * 0.04,
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
      if (kIsWeb) {
        // Web-specific implementation
        await Future.delayed(Duration(seconds: 2)); // Simulate processing
        return "Web detection result (simulated)";
      } else {
        final String result = await platform.invokeMethod('classifyImage', {
          'imagePath': imagePath,
        });
        return result;
      }
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
    final isWeb = kIsWeb;
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: isWeb ? 18.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isWeb ? 12.0 : 8.0),
            Text(
              '1. Ensure proper lighting for accurate detection.',
              style: TextStyle(fontSize: isWeb ? 16.0 : 14.0),
            ),
            Text(
              '2. Hold the camera steady when taking a picture.',
              style: TextStyle(fontSize: isWeb ? 16.0 : 14.0),
            ),
            Text(
              '3. Make sure the image is clear and focused.',
              style: TextStyle(fontSize: isWeb ? 16.0 : 14.0),
            ),
            Text(
              '4. Results below 85% confidence may be unreliable.',
              style: TextStyle(fontSize: isWeb ? 16.0 : 14.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final isWeb = kIsWeb;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isWeb ? 600.0 : double.infinity,
        maxHeight: isWeb ? 400.0 : 300.0,
      ),
      child: _image == null
          ? Container(
        decoration: BoxDecoration(
          color: Color(0xFFA3CFB2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.camera_alt,
            size: isWeb ? 60.0 : 80.0,
            color: Color(0xFF046027),
          ),
        ),
      )
          : ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(
          _image!.path,
          fit: BoxFit.cover,
        )
            : Image.file(
          _image!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final isWeb = kIsWeb;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.camera),
          icon: Icon(Icons.camera_alt, color: Colors.white),
          label: Text('Take Picture'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24.0 : 16.0, vertical: 12.0),
            backgroundColor: Color(0xFF046027),
          ),
        ),
        SizedBox(width: isWeb ? 20.0 : 12.0),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.gallery),
          icon: Icon(Icons.photo_library, color: Colors.white),
          label: Text('Gallery'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 24.0 : 16.0, vertical: 12.0),
            backgroundColor: Colors.pink[300],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Breast Cancer Detection',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF046027),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(isWeb ? 40.0 : 16.0),
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _buildInstructionCard(),
                SizedBox(height: isWeb ? 30.0 : 20.0),
                _buildImagePreview(),
                SizedBox(height: isWeb ? 30.0 : 20.0),
                if (_isLoading)
                  Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: isWeb ? 20.0 : 16.0),
                      Text(
                        'Analyzing image...',
                        style: TextStyle(
                          fontSize: isWeb ? 18.0 : 16.0,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                else
                  ResultDisplay(
                    finalPercentage: _finalPercentage,
                    result: _result,
                    resultColor: _resultColor,
                  ),
                SizedBox(height: isWeb ? 30.0 : 20.0),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}