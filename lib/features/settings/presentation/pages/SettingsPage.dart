import 'package:flutter/material.dart';

import '../../../authentication/presentation/pages/login_screen.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
        child: ElevatedButton(
          onPressed: () {
            // Logique de déconnexion (ex. : supprimer les tokens, rediriger vers la page de connexion)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Déconnexion réussie")),
            );
            // Exemple : Rediriger vers la page de connexion
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          child: Text("Se déconnecter"),
        ),
      ),
    );
  }
}
