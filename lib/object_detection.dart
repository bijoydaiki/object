import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html hide Text;

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
    return LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          double maxHeight = constraints.maxHeight;

          // Adjust sizes based on available width
          double fontSize = maxWidth * 0.05;
          double smallerFontSize = maxWidth * 0.04;
          double titleFontSize = maxWidth * 0.045;
          double percentageFontSize = maxWidth * 0.08;

          // For very large screens, cap font sizes
          if (maxWidth > 600) {
            fontSize = 30;
            smallerFontSize = 24;
            titleFontSize = 28;
            percentageFontSize = 48;
          }

          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(maxWidth * 0.02), // Responsive padding
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
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: maxHeight * 0.01),
              Card(
                color: Colors.white,
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(maxWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Final Risk Percentage",
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.01),
                      Text(
                        "${finalPercentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: percentageFontSize,
                          fontWeight: FontWeight.bold,
                          color: getRiskColor(),
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.01),
                      Text(
                        getRiskMessage(),
                        style: TextStyle(
                          fontSize: smallerFontSize,
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
  File? _imageFile;
  Uint8List? _webImage;
  String _result = 'No detection yet';
  bool _isLoading = false;
  Color _resultColor = Colors.black;
  double _finalPercentage = 0.0;
  final picker = ImagePicker();

  // Method to handle picking an image for both web and mobile
  Future<void> _getImageAndClassify(ImageSource source) async {
    try {
      if (kIsWeb) {
        if (source == ImageSource.camera) {
          // For web camera
          await _getWebCameraImage();
        } else {
          // For web gallery
          await _getWebGalleryImage();
        }
      } else {
        // For mobile platforms
        await _getMobileImage(source);
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

  // Web camera capture implementation
  Future<void> _getWebCameraImage() async {
    setState(() {
      _result = 'Processing...';
      _isLoading = true;
      _resultColor = Colors.blue;
    });

    try {
      // Create file input element
      final html.InputElement input = html.document.createElement('input') as html.InputElement;
      input.type = 'file';
      input.accept = 'image/*';
      input.capture = 'camera';

      // Add event listener for when file is selected
      input.onChange.listen((e) {
        if (input.files!.isNotEmpty) {
          final reader = html.FileReader();
          reader.readAsDataUrl(input.files![0]);
          reader.onLoad.listen((e) async {
            final result = reader.result as String;
            final base64 = result.split(',')[1];
            final imageBytes = base64Decode(base64);

            setState(() {
              _webImage = imageBytes;
              _imageFile = null;
            });

            // Process the image
            await _processWebImage(imageBytes);
          });
        }
      });

      // Trigger click to open camera
      input.click();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Failed to access camera: $e';
        _resultColor = Colors.red;
      });
    }
  }

  // Web gallery image selection implementation
  Future<void> _getWebGalleryImage() async {
    setState(() {
      _result = 'Processing...';
      _isLoading = true;
      _resultColor = Colors.blue;
    });

    try {
      // Create file input element
      final html.InputElement input = html.document.createElement('input') as html.InputElement;
      input.type = 'file';
      input.accept = 'image/*';

      // Add event listener for when file is selected
      input.onChange.listen((e) {
        if (input.files!.isNotEmpty) {
          final reader = html.FileReader();
          reader.readAsDataUrl(input.files![0]);
          reader.onLoad.listen((e) async {
            final result = reader.result as String;
            final base64 = result.split(',')[1];
            final imageBytes = base64Decode(base64);

            setState(() {
              _webImage = imageBytes;
              _imageFile = null;
            });

            // Process the image
            await _processWebImage(imageBytes);
          });
        }
      });

      // Trigger click to open file browser
      input.click();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Failed to access gallery: $e';
        _resultColor = Colors.red;
      });
    }
  }

  // Mobile image capture implementation
  Future<void> _getMobileImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
          _result = 'Processing...';
          _isLoading = true;
          _resultColor = Colors.blue;
        });

        // Process the image for mobile
        final String result = await _classifyImage(pickedFile.path);
        _updateResultState(result);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Error picking image: $e';
        _resultColor = Colors.red;
      });
    }
  }

  // Process web image for classification
  Future<void> _processWebImage(Uint8List imageBytes) async {
    try {
      // For web, we need to handle classification differently
      // since we can't use the platform channel directly with a file path

      // You would need to implement a web-specific classifier here
      // This is a placeholder for the actual web classification logic
      String result = await _mockClassifyImageForWeb(imageBytes);

      _updateResultState(result);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = 'Error processing image: $e';
        _resultColor = Colors.red;
      });
    }
  }

  // Mock classification for web (replace with actual web classification logic)
  Future<String> _mockClassifyImageForWeb(Uint8List imageBytes) async {
    // Simulate processing delay
    await Future.delayed(Duration(seconds: 2));

    // In a real application, you would implement a web-based classifier here
    // For example, using TensorFlow.js or a backend API

    // Random result for demo purposes
    final random = DateTime.now().millisecond % 3;
    if (random == 0) {
      return "Breast Cancer Detected";
    } else if (random == 1) {
      return "Fresh Skin Detected";
    } else {
      return "No clear detection";
    }
  }

  // Update state with classification results
  void _updateResultState(String result) {
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
        // For web, use the mock implementation
        return "Web platform - classification would be implemented differently";
      } else {
        // For mobile, use the platform channel
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

  Widget _buildInstructionCard(BoxConstraints constraints) {
    double maxWidth = constraints.maxWidth;
    double fontSize = maxWidth * 0.045;
    double smallerFontSize = maxWidth * 0.035;

    // Cap font sizes for very large screens
    if (maxWidth > 600) {
      fontSize = 28;
      smallerFontSize = 22;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(maxWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions:',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: maxWidth * 0.02),
            Text('1. Ensure proper lighting for accurate detection.', style: TextStyle(fontSize: smallerFontSize)),
            Text('2. Hold the camera steady when taking a picture.', style: TextStyle(fontSize: smallerFontSize)),
            Text('3. Make sure the image is clear and focused.', style: TextStyle(fontSize: smallerFontSize)),
            Text('4. Results below 85% confidence may be unreliable.', style: TextStyle(fontSize: smallerFontSize)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Breast Cancer Detection',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF046027),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double maxWidth = constraints.maxWidth;
            double maxHeight = constraints.maxHeight;

            // Layout adjustments based on screen size
            bool isSmallScreen = maxWidth < 600;
            double padding = isSmallScreen ? maxWidth * 0.03 : maxWidth * 0.1;
            double imageMaxHeight = isSmallScreen ? maxHeight * 0.4 : maxHeight * 0.5;
            double buttonFontSize = isSmallScreen ? maxWidth * 0.035 : 18;
            double iconSize = isSmallScreen ? maxWidth * 0.06 : 30;

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildInstructionCard(constraints),
                      SizedBox(height: maxHeight * 0.02),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? maxWidth * 0.9 : 600,
                          maxHeight: imageMaxHeight,
                        ),
                        child: _webImage != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _webImage!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                            : _imageFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFA3CFB2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: iconSize,
                            color: Color(0xFF046027),
                          ),
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.02),
                      _isLoading
                          ? Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: maxHeight * 0.02),
                          Text(
                            'Analyzing image...',
                            style: TextStyle(
                              fontSize: buttonFontSize,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      )
                          : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? maxWidth * 0.9 : 600,
                        ),
                        child: ResultDisplay(
                          finalPercentage: _finalPercentage,
                          result: _result,
                          resultColor: _resultColor,
                        ),
                      ),
                      SizedBox(height: maxHeight * 0.05),
                      // Responsive buttons
                      Wrap(
                        spacing: maxWidth * 0.03,
                        runSpacing: maxHeight * 0.02,
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.camera),
                            icon: Icon(Icons.camera_alt, color: Colors.white, size: iconSize),
                            label: Text(
                              'Take Picture',
                              style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.03, vertical: maxHeight * 0.015),
                              backgroundColor: Color(0xFF046027),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _isLoading ? null : () => _getImageAndClassify(ImageSource.gallery),
                            icon: Icon(Icons.photo_library, color: Colors.white, size: iconSize),
                            label: Text(
                              'Gallery',
                              style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.03, vertical: maxHeight * 0.015),
                              backgroundColor: Colors.pink[300],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}