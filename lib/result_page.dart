import 'package:flutter/material.dart';
import 'package:object/questions_page.dart';


class ResultScreen extends StatelessWidget {
  final double affectedPercentage;

  ResultScreen({required this.affectedPercentage});

  String getRiskMessage() {
    if (affectedPercentage >= 60) {
      return "High Risk: Please consult a doctor immediately.";
    } else if (affectedPercentage >= 30) {
      return "Moderate Risk: Consider visiting a doctor for a check-up.";
    } else {
      return "Low Risk: No immediate concern, but monitor for changes.";
    }
  }

  Color _getRiskColor() {
    if (affectedPercentage >= 60) return Colors.red[700]!;
    if (affectedPercentage >= 30) return Colors.orange[700]!;
    return Colors.green[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Assessment Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Your Affected Percentage",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "${affectedPercentage.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(),
                        ),
                      ),
                      SizedBox(height: 20),
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
                SizedBox(height: 40),
                ElevatedButton(
                  //  onPressed: () => Navigator.pop(context),

                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => QuestionsPage(),)),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink[700],
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}