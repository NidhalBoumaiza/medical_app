import 'package:flutter/material.dart';

class RendezVousPatient extends StatefulWidget {
  const RendezVousPatient({super.key});

  @override
  State<RendezVousPatient> createState() => _RendezVousPatientState();
}

class _RendezVousPatientState extends State<RendezVousPatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Rendez-vous"),
      ),

    );
  }
}
