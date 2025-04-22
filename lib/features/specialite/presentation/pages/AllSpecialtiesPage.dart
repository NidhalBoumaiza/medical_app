import 'package:flutter/material.dart';

import '../../../../core/utils/navigation_with_transition.dart';
import '../../../rendez_vous/presentation/pages/RendezVousPatient.dart';

class AllSpecialtiesPage extends StatefulWidget {
  final List<Map<String, dynamic>> specialties;

  const AllSpecialtiesPage({Key? key, required this.specialties}) : super(key: key);

  @override
  _AllSpecialtiesPageState createState() => _AllSpecialtiesPageState();
}

class _AllSpecialtiesPageState extends State<AllSpecialtiesPage> {
  List<Map<String, dynamic>> _filteredSpecialties = [];

  @override
  void initState() {
    super.initState();
    // Initially, the filtered list is the same as the full list
    _filteredSpecialties = widget.specialties;
  }

  void _filterSpecialties(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show all specialties
        _filteredSpecialties = widget.specialties;
      } else {
        // Filter specialties based on the query (case-insensitive)
        _filteredSpecialties = widget.specialties.where((specialty) {
          final specialtyName = specialty['text']?.toString().toLowerCase() ?? '';
          return specialtyName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spécialités"),
        backgroundColor: const Color(0xFF2FA7BB),
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.3)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Trouver médecin, spécialité...",
                  hintStyle: const TextStyle(color: Color(0xFF42A5F5)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF42A5F5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                onChanged: (value) {
                  _filterSpecialties(value);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Grid of Specialties
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _filteredSpecialties.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                        context,
                        RendezVousPatient(selectedSpecialty: _filteredSpecialties[index]['text']),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF42A5F5), width: 0.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _filteredSpecialties[index]['image']!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                            color: const Color(0xFF42A5F5),
                            colorBlendMode: BlendMode.srcIn,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 40,
                                color: Colors.red,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _filteredSpecialties[index]['text']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}