import 'package:flutter/material.dart';

class RendezVousMedecin extends StatefulWidget {
  const RendezVousMedecin({super.key});

  @override
  State<RendezVousMedecin> createState() => _RendezVousMedecinState();
}

class _RendezVousMedecinState extends State<RendezVousMedecin> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Liste des Rendez-vous"),
        ),
        body: Center(
          //child: Text("Rendez-vous Medecin"),
        ),
      ),
    );
  }
}
