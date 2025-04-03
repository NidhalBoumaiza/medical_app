import 'package:flutter/material.dart';

class ProfilPatient extends StatefulWidget {
  const ProfilPatient({super.key});

  @override
  State<ProfilPatient> createState() => _ProfilPatientState();
}

class _ProfilPatientState extends State<ProfilPatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Profil Patient"),
      ),
    );
  }
}
