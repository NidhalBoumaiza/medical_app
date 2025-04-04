import 'package:flutter/material.dart';

class NotificationsMedecin extends StatefulWidget {
  const NotificationsMedecin({super.key});

  @override
  State<NotificationsMedecin> createState() => _NotificationsMedecinState();
}

class _NotificationsMedecinState extends State<NotificationsMedecin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Color(0xFF2FA7BB),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left, // iOS icon for back navigation
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text("Notifications Medecin"),
      ),
    );
  }
}
