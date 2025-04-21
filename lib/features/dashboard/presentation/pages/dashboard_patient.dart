import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/features/secours/presentation/pages/secours_screen.dart';
import 'package:medical_app/features/settings/presentation/pages/settings_patient.dart';

import '../../../localisation/presentation/pages/pharmacie_page.dart';
import '../../../rendez_vous/presentation/pages/RendezVousPatient.dart';
import '../../../specialite/presentation/pages/AllSpecialtiesPage.dart';

class Dashboardpatient extends StatefulWidget {
  const Dashboardpatient({super.key});

  @override
  State<Dashboardpatient> createState() => _DashboardpatientState();
}

class _DashboardpatientState extends State<Dashboardpatient> {
  // Data for "Que cherchez-vous ?" section (using Icons)
  final List<Map<String, dynamic>> searchItems = [
    {'icon': FontAwesomeIcons.userDoctor, 'text': 'Médecins'},
    {'icon': FontAwesomeIcons.prescriptionBottleMedical, 'text': 'Pharmacies'},
    {'icon': FontAwesomeIcons.hospital, 'text': 'Hopitaux'},
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
  late Timer _timer; // Timer for auto-scrolling

  @override
  void initState() {
    super.initState();
    // Ajouter un écouteur pour synchroniser les points avec le PageView
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });

    // Set up the timer for auto-scrolling every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < firstAidVideos.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Loop back to the first page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
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
              const Text(
                'Que cherchez-vous ?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
                            }
                          },
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  searchItems[index]['icon'],
                                  size: 25,
                                  color: Colors.black45,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchItems[index]['text'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
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
              const SizedBox(height: 24),

              // "Spécialités" Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
                    child: const Text('Voir tout', style: TextStyle(fontSize: 16, color: Colors.teal)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                          context,
                          RendezVousPatient(selectedSpecialty: specialties[index]['text']),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            width: 100,
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  specialties[index]['image']!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.error, size: 40, color: Colors.red);
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  specialties[index]['text']!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 24),

              // "Premiers Secours" Section (Pleine largeur avec slider)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
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
                    child: const Text('Voir tout', style: TextStyle(fontSize: 16, color: Colors.teal)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                              return const Icon(Icons.error, size: 60, color: Colors.red);
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            firstAidVideos[index]['text']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Indicateur de page synchronisé
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  firstAidVideos.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
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