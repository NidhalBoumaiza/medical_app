import 'package:flutter/material.dart';

class MessagerieMedecin extends StatefulWidget {
  const MessagerieMedecin({super.key});

  @override
  State<MessagerieMedecin> createState() => _MessagerieMedecinState();
}

class _MessagerieMedecinState extends State<MessagerieMedecin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(
        title: Text("Messagerie"),
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
        child: Text("Messagerie"),


      ),
    );
  }
}
