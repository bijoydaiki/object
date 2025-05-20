import 'package:flutter/material.dart';

import 'object_detection.dart';

class QuestionsPage extends StatefulWidget {
  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  Map<int, int> selectedAnswers = {};

  final List<Map<String, dynamic>> questions = [
    {"question": "Do you have a lump in your breast or underarm?"},
    {"question": "Have you noticed a change in breast size or shape?"},
    {"question": "Does your breast feel thickened or different from usual?"},
    {"question": "Have you observed any dimpling or puckering of the breast skin?"},
    {"question": "Has your nipple become inverted (turned inward)?"},
    {"question": "Have you noticed any nipple discharge (clear, bloody, or yellowish)?"},
    {"question": "Do you experience itching or burning in your nipple?"},
    {"question": "Have you noticed redness, flakiness, or skin irritation on your nipple?"},
    {"question": "Do you experience breast or nipple pain?"},
    {"question": "Is there any unexplained tenderness or sensitivity in your breast?"},
    {"question": "Have you observed any unusual swelling in your breast or underarm?"},
    {"question": "Is there persistent redness or warmth in your breast?"},
    {"question": "Have you noticed any unexplained bruising on your breast?"},
    {"question": "Has the skin on your breast started peeling or forming sores?"},
    {"question": "Do you have unexplained weight loss, bone pain, or fatigue?"},
    {"question": "Have you noticed changes in your lymph nodes (swollen or tender underarms)?"},
    {"question": "Are your breasts feeling unusually heavy?"},
    {"question": "Have you noticed any skin ulcers or open sores on your breast?"},
  ];

  void _submitAnswers() {
    if (selectedAnswers.length != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please answer all questions before submitting.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int totalQuestions = questions.length;
    int yesAnswers = selectedAnswers.values.where((value) => value == 1).length;
    double affectedPercentage = (yesAnswers / totalQuestions) * 100;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ObjectDetectionScreen(affectedPercentage: affectedPercentage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get device size to make responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isTabletOrDesktop = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Breast Cancer Symptom Checker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF046027),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF046027), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isTabletOrDesktop ? 20.0 : 10.0),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // For tablet and desktop views, use a grid layout
                      if (isTabletOrDesktop) {
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenSize.width > 1200 ? 3 : 2,
                            childAspectRatio: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            return _buildQuestionCard(index);
                          },
                        );
                      } else {
                        // For mobile views, use a list layout
                        return ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            return _buildQuestionCard(index);
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: isTabletOrDesktop ? 30 : 20),
                Container(
                  width: isTabletOrDesktop ? screenSize.width * 0.4 : double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitAnswers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF046027),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: isTabletOrDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final bool isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTabletOrDesktop ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${index + 1}. ${questions[index]['question']}",
              style: TextStyle(
                fontSize: isTabletOrDesktop ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRadioOption(index, 1, "Yes", Colors.red),
                SizedBox(width: isTabletOrDesktop ? 40 : 30),
                _buildRadioOption(index, 0, "No", Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(int index, int value, String label, Color color) {
    final bool isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

    return Row(
      children: [
        Radio(
          value: value,
          groupValue: selectedAnswers[index],
          onChanged: (val) {
            setState(() {
              selectedAnswers[index] = val as int;
            });
          },
          activeColor: color,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isTabletOrDesktop ? 18 : 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}