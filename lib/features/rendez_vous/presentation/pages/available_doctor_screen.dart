import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';

import '../../../../widgets/reusable_text_widget.dart';

class AvailableDoctorsScreen extends StatelessWidget {
  final String specialty;
  final DateTime dateTime;

  const AvailableDoctorsScreen({
    super.key,
    required this.specialty,
    required this.dateTime,
  });

  // Hardcoded list of doctors for demonstration
  final List<Map<String, String>> doctors = const [
    {
      'name': 'Dr. John Smith',
      'specialty': 'Cardiologie',
    },
    {
      'name': 'Dr. Emily Johnson',
      'specialty': 'Dermatologie',
    },
    {
      'name': 'Dr. Michael Brown',
      'specialty': 'Neurologie',
    },
    {
      'name': 'Dr. Sarah Davis',
      'specialty': 'Pédiatrie',
    },
    {
      'name': 'Dr. David Wilson',
      'specialty': 'Orthopédie',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter doctors by specialty for demonstration
    final filteredDoctors = doctors.where((doctor) => doctor['specialty'] == specialty).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text("Médecins disponibles"),
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
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(50.w, 20.h, 50.w, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ReusableTextWidget(
                    text: "Médecins disponibles",
                    textSize: 100,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 40.h),
                Image.asset(
                  'assets/images/Doctors.png',
                  height: 1000.h,
                  width: 900.w,
                ),
                SizedBox(height: 100.h),
                if (filteredDoctors.isEmpty)
                  ReusableTextWidget(
                    text: "Aucun médecin disponible",
                    textSize: 55,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(vertical: 20.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(40.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ReusableTextWidget(
                                text: "Nom du médecin: ${doctor['name']}",
                                textSize: 50,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              SizedBox(height: 20.h),
                              ReusableTextWidget(
                                text: "Spécialité: ${doctor['specialty']}",
                                textSize: 50,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}