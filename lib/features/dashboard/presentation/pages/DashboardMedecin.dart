import 'package:flutter/material.dart';

class DashboardMedecin extends StatefulWidget {
  const DashboardMedecin({super.key});

  @override
  State<DashboardMedecin> createState() => _DashboardMedecinState();
}

class _DashboardMedecinState extends State<DashboardMedecin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Dashboard Medecin"),
      ),
    );
  }
}
