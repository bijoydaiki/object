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
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),   //    color: Color(0xFF139109),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFFFFFFFF),
              width: 2,
            ),
          ),
          child: Text(
            result,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 5),
        Card(
          color: Colors.white,
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Final Risk Percentage",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "${finalPercentage.toStringAsFixed(1)}%",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: getRiskColor(),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  getRiskMessage(),
                  style: TextStyle(
                    fontSize: 18,
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
    const double breastCancerBasePercentage = 75.0;  // Example base percentage for breast cancer
    const double freshSkinPercentage = 10.0;        // Example percentage for fresh skin

    if (result.contains("Breast Cancer")) {
      // Average of breast cancer base percentage and questionnaire affected percentage
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('1. Ensure proper lighting for accurate detection.'),
            Text('2. Hold the camera steady when taking a picture.'),
            Text('3. Make sure the image is clear and focused.'),
            Text('4. Results below 85% confidence may be unreliable.'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        // ===== here i will be add sheba logo ========//
        title: Row(
          children: [
            Text('Breast Cancer Detection',style: TextStyle(color: Colors.white),)
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF046027),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildInstructionCard(),
                SizedBox(height: 10),
                _image == null
                    ? Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFFA3CFB2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 80,
                    color: Color(0xFF046027),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _image!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                _isLoading
                    ? Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing image...',
                      style: TextStyle(
                        fontSize: 18,
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
      floatingActionButton: FloatingActionButton.extended(backgroundColor: Color(
          0xFFFFFFFF), onPressed: () {

      }, label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.camera),
            icon: Icon(Icons.camera_alt,color: Colors.white,),
            label: Text('Take Picture',style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              backgroundColor: Color(0xFF046027),
            ),
          ),
          Text("  "),
          TextButton.icon(
            onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.gallery),
            icon: Icon(Icons.photo_library,color: Colors.white,),
            label: Text('Gallery',style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 1),
              backgroundColor: Colors.pink[300],
            ),
          ),
        ],
      ),),
    );
  }
}