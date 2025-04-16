import 'package:flutter/material.dart';


import '../../../../core/utils/app_colors.dart'; // Importation de la classe AppColors

class ProfilePatient extends StatefulWidget {
  const ProfilePatient({super.key});

  @override
  State<ProfilePatient> createState() => _ProfilePatientState();
}

class _ProfilePatientState extends State<ProfilePatient> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cercle pour la photo de profil
                CircleAvatar(
                  radius: 70,
                  backgroundColor: AppColors.whiteColor,
                  backgroundImage: const AssetImage('assets/images/img.png'),
                  onBackgroundImageError: (exception, stackTrace) {
                    Icon(Icons.person, size: 70, color: AppColors.primaryColor);
                  },
                ),
                const SizedBox(height: 16),

                // Carte avec les informations du profil
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Champ pour le nom
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Nom',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.whiteColor,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Champ pour le prénom
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Prénom',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.whiteColor,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Champ pour l’email
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.email, color: AppColors.primaryColor),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.whiteColor,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Champ pour le téléphone
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Téléphone',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.phone, color: AppColors.primaryColor),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.whiteColor,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Champ pour le genre
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Genre',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.person, color: AppColors.primaryColor),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.whiteColor,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Champ pour la date de naissance
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Date de naissance (JJ/MM/AAAA)',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: AppColors.primaryColor),
                                  ),
                                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryColor),
                                ),
                                keyboardType: TextInputType.datetime,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: AppColors.whiteColor,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton pour sauvegarder les modifications
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    child: Text(
                      'Sauvegarder les modifications',
                      style: TextStyle(fontSize: 16, color: AppColors.whiteColor),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton pour se déconnecter
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    ),
                    onPressed: () {},
                    child: Text(
                      "Se déconnecter",
                      style: TextStyle(color: AppColors.whiteColor, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}