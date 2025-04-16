import 'package:flutter/material.dart';
import 'package:medical_app/features/secours/presentation/pages/secours_screen.dart';
import 'package:medical_app/features/settings/presentation/pages/settings_patient.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../localisation/presentation/pages/pharmacie_page.dart';
import '../../../specialite/presentation/pages/AllSpecialtiesPage.dart';
import '../../../specialite/presentation/pages/dentiste_screen.dart';
import '../../../specialite/presentation/pages/neurologue_screen.dart';

class Dashboardpatient extends StatefulWidget {
  const Dashboardpatient({super.key});

  @override
  State<Dashboardpatient> createState() => _DashboardpatientState();
}

class _DashboardpatientState extends State<Dashboardpatient> {
  // Data for "Que cherchez-vous ?" section (using Icons)
  final List<Map<String, dynamic>> searchItems = [
    {'icon': Icons.person, 'text': 'Médecins'},
    {'icon': Icons.local_pharmacy, 'text': 'Pharmacies'},
    {'icon': Icons.local_hospital, 'text': 'Hopitaux'},
    {'icon': Icons.settings, 'text': 'Parametres'},
  ];

  // Data for "Spécialités" section (using asset images)
  final List<Map<String, dynamic>> specialties = [
    {'image': 'assets/images/dentiste.png', 'text': 'Dentiste'},
    {'image': 'assets/images/pnmeulogue.png', 'text': 'Pneumologue'},
    {'image': 'assets/images/dermatologue.png', 'text': 'Dermatologue'},
    {'image': 'assets/images/diet.png', 'text': 'Nutritionniste'},
    {'image': 'assets/images/cardio.png', 'text': 'Cardiologue'},
    {'image': 'assets/images/psy.png', 'text': 'Psychologue'},
    {'image': 'assets/images/generaliste.png', 'text': 'Médecin généraliste'},
    {'image': 'assets/images/neurologue.png', 'text': 'Neurologue'},
    {'image': 'assets/images/orthopediste.png', 'text': 'Orthopédique'},
    {'image': 'assets/images/gyneco.png', 'text': 'Gynécologue'},
    {'image': 'assets/images/ophtalmo.png', 'text': 'Ophtalmologue'},
    {'image': 'assets/images/medecin1.png', 'text': 'Médecin esthétique'},
  ];

  // Data for "Vidéos éducatives de premiers secours" section
  final List<Map<String, dynamic>> firstAidVideos = [
    {'image': 'assets/images/cpr1.jpg', 'text': 'Réanimation', 'videoUrl': 'https://example.com/fainting_video'},
    {'image': 'assets/images/choking.jpg', 'text': 'Étouffement', 'videoUrl': 'https://example.com/choking_video'},
    {'image': 'assets/images/bleeding2.jpg', 'text': 'Saignement', 'videoUrl': 'https://example.com/bleeding_video'},
    {'image': 'assets/images/brulure.jpg', 'text': 'Brûlures', 'videoUrl': 'https://example.com/burns_video'},
  ];

  // Contrôleur pour le PageView
  final PageController _pageController = PageController();
  int _currentPage = 0; // Variable pour suivre la page actuelle

  @override
  void initState() {
    super.initState();
    // Ajouter un écouteur pour synchroniser les points avec le PageView
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Que cherchez-vous ?" Section
              Text(
                'Que cherchez-vous ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: searchItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: InkWell(
                          onTap: () {
                            switch (searchItems[index]["text"]) {
                              case 'Médecins':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllSpecialtiesPage(specialties: specialties),
                                  ),
                                );
                                break;
                              case 'Pharmacies':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PharmaciePage()),
                                );
                                break;
                              case 'Hopitaux':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PharmaciePage()),
                                );
                                break;
                              case 'Parametres':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsPatient()),
                                );
                                break;
                            }
                          },
                          child: Container(
                            width: 100,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(searchItems[index]['icon'], size: 40, color: Colors.black45),
                                SizedBox(height: 8),
                                Text(
                                  searchItems[index]['text'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // "Spécialités" Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Spécialités',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllSpecialtiesPage(specialties: specialties),
                        ),
                      );
                    },
                    child: Text('Voir tout', style: TextStyle(fontSize: 16, color: Colors.teal)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                specialties[index]['image']!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error, size: 40, color: Colors.red);
                                },
                              ),
                              SizedBox(height: 8),
                              Text(
                                specialties[index]['text']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),

              // "Premiers Secours" Section (Pleine largeur avec slider)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Premiers Secours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SecoursScreen()),
                      );
                    },
                    child: Text('Voir tout', style: TextStyle(fontSize: 16, color: Colors.teal)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: firstAidVideos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            firstAidVideos[index]['image']!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error, size: 60, color: Colors.red);
                            },
                          ),
                          SizedBox(height: 16),
                          Text(
                            firstAidVideos[index]['text']!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // Indicateur de page synchronisé
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  firstAidVideos.length,
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.teal : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}