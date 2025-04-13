// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter/services.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Object Detection',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: ObjectDetectionScreen(),
//     );
//   }
// }
//
// class ObjectDetectionScreen extends StatefulWidget {
//   @override
//   _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
// }
//
// class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
//   static const platform = MethodChannel('com.example.object_detection/classifier');
//   File? _image;
//   String _result = 'No detection yet';
//   final picker = ImagePicker();
//
//   Future<void> _getImageAndClassify(ImageSource source) async {
//     try {
//       final pickedFile = await picker.pickImage(source: source);
//
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _result = 'Processing...';
//         });
//
//         final String result = await _classifyImage(pickedFile.path);
//         setState(() {
//           _result = result;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _result = 'Error: $e';
//       });
//     }
//   }
//
//   Future<String> _classifyImage(String imagePath) async {
//     try {
//       final String result = await platform.invokeMethod('classifyImage', {
//         'imagePath': imagePath,
//       });
//       return result;
//     } on PlatformException catch (e) {
//       return "Failed to classify image: ${e.message}";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Object Detection'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             _image == null
//                 ? Text('No image selected.')
//                 : Image.file(_image!, height: 300, fit: BoxFit.contain),
//             SizedBox(height: 20),
//             Text(
//               'Result: $_result',
//               style: TextStyle(fontSize: 20),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _getImageAndClassify(ImageSource.camera),
//               child: Text('Take Picture'),
//             ),
//             ElevatedButton(
//               onPressed: () => _getImageAndClassify(ImageSource.gallery),
//               child: Text('Pick from Gallery'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//  =========  //

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:object/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breast Cancer Detection',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

