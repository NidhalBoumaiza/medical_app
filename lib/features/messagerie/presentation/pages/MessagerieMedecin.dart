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
      ),
      body: Center(
        child: Text("Messagerie"),
      ),
    );
  }
}
