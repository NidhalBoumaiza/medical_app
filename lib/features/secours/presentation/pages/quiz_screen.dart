import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final String videoTitle;

  const QuizScreen({super.key, required this.videoTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz - $videoTitle"),
        backgroundColor: Color(0xFF2FA7BB),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          'Quiz pour : $videoTitle\n(Cette page peut être personnalisée avec des questions)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}