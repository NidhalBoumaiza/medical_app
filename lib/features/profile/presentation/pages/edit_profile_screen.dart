import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, String> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _genreController;
  late TextEditingController _dateNaissanceController;
  late TextEditingController _adresseController;
  late TextEditingController _contactUrgenceController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profileData['nom']);
    _prenomController = TextEditingController(text: widget.profileData['prenom']);
    _emailController = TextEditingController(text: widget.profileData['email']);
    _telephoneController = TextEditingController(text: widget.profileData['telephone']);
    _genreController = TextEditingController(text: widget.profileData['genre']);
    _dateNaissanceController = TextEditingController(text: widget.profileData['dateNaissance']);
    _adresseController = TextEditingController(text: widget.profileData['adresse']);
    _contactUrgenceController = TextEditingController(text: widget.profileData['contactUrgence']);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _genreController.dispose();
    _dateNaissanceController.dispose();
    _adresseController.dispose();
    _contactUrgenceController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'telephone': _telephoneController.text,
        'genre': _genreController.text,
        'dateNaissance': _dateNaissanceController.text,
        'adresse': _adresseController.text,
        'contactUrgence': _contactUrgenceController.text,
      };
      Navigator.pop(context, updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier vos données'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nomController,
                        label: 'Nom',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _prenomController,
                        label: 'Prénom',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return 'Veuillez entrer un email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _telephoneController,
                        label: 'Téléphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer un numéro de téléphone' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _genreController,
                        label: 'Genre',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer un genre' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _dateNaissanceController,
                        label: 'Date de naissance (JJ/MM/AAAA)',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.datetime,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer une date de naissance' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _adresseController,
                        label: 'Adresse',
                        icon: Icons.home,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer une adresse' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _contactUrgenceController,
                        label: 'Contact d\'urgence',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'Veuillez entrer un contact d\'urgence' : null,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 5,
                          ),
                          child: Text(
                            'Sauvegarder',
                            style: TextStyle(fontSize: 16, color: AppColors.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
    );
  }
}