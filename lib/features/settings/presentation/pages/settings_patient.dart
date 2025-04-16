import 'package:flutter/material.dart';

class SettingsPatient extends StatefulWidget {
  const SettingsPatient({super.key});

  @override
  State<SettingsPatient> createState() => _SettingsPatientState();
}

class _SettingsPatientState extends State<SettingsPatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.settings, size: 100),
            SizedBox(height: 20),
            Text(
              'Paramètres de l\'application',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),

      ),

    );
  }
}
