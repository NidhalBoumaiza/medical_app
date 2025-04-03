import 'package:flutter/material.dart';

class OrdonnancesPage extends StatefulWidget {
  const OrdonnancesPage({super.key});

  @override
  State<OrdonnancesPage> createState() => _OrdonnancesPageState();
}

class _OrdonnancesPageState extends State<OrdonnancesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ordonnances"),
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
        child: Text(" Ordonnances Page"),
      ),
    );
  }
}
