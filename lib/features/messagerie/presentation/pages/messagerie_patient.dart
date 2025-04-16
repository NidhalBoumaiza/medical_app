import 'package:flutter/material.dart';

class MessageriePatient extends StatefulWidget {
  const MessageriePatient({super.key});

  @override
  State<MessageriePatient> createState() => _MessageriePatientState();
}

class _MessageriePatientState extends State<MessageriePatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messagerie"),
        backgroundColor: Color(0xFF2FA7BB),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text("Message Page"),
      ),
    );
  }
}
