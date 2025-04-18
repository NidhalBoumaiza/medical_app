import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';

import 'package:medical_app/widgets/reusable_text_widget.dart';

class RendezVousMedecin extends StatefulWidget {
  const RendezVousMedecin({super.key});

  @override
  State<RendezVousMedecin> createState() => _RendezVousMedecinState();
}

class _RendezVousMedecinState extends State<RendezVousMedecin> {
  @override
  void initState() {
    super.initState();
    // Dispatch FetchRendezVous event when the page loads
    context.read<RendezVousBloc>().add(const FetchRendezVous());
  }

  void _updateConsultationStatus(String id, String newStatus) {
    context.read<RendezVousBloc>().add(UpdateRendezVousStatus(id, newStatus));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: const Text("Gérer les consultations"),
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
        body: BlocListener<RendezVousBloc, RendezVousState>(
          listener: (context, state) {
            if (state is RendezVousError) {
              showErrorSnackBar(context, state.message);
            } else if (state is RendezVousLoaded) {
              // Show snackbar only after status update (not initial fetch)
              if (state.rendezVous.any((r) =>
              r.status == 'Accepté' || r.status == 'Refusé')) {
                final lastUpdated = state.rendezVous.lastWhere(
                      (r) => r.status == 'Accepté' || r.status == 'Refusé',
                  orElse: () => state.rendezVous.first,
                );
                showSuccessSnackBar(
                  context,
                  lastUpdated.status == 'Accepté'
                      ? 'Consultation acceptée'
                      : 'Consultation refusée',
                );
              }
            }
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(50.w, 20.h, 50.w, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ReusableTextWidget(
                      text: "Gérer les consultations",
                      textSize: 100,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Image.asset(
                    'assets/images/DoctorConsultations.png',
                    height: 1000.h,
                    width: 900.w,
                  ),
                  SizedBox(height: 100.h),
                  // Consultation List
                  BlocBuilder<RendezVousBloc, RendezVousState>(
                    builder: (context, state) {
                      if (state is RendezVousLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RendezVousLoaded) {
                        if (state.rendezVous.isEmpty) {
                          return ReusableTextWidget(
                            text: "Aucune consultation",
                            textSize: 55,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.rendezVous.length,
                          itemBuilder: (context, index) {
                            final consultation = state.rendezVous[index];
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
                                      text: "Patient: ${consultation.patientName}",
                                      textSize: 50,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 20.h),
                                    ReusableTextWidget(
                                      text:
                                      "Heure de début: ${consultation.startTime.toLocal().toString().substring(0, 16)}",
                                      textSize: 50,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                    SizedBox(height: 20.h),
                                    ReusableTextWidget(
                                      text: "Statut: ${consultation.status}",
                                      textSize: 50,
                                      fontWeight: FontWeight.w600,
                                      color: consultation.status == 'En attente'
                                          ? Colors.orange
                                          : consultation.status == 'Accepté'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    if (consultation.status == 'En attente') ...[
                                      SizedBox(height: 20.h),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(20.r),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 30.w,
                                                vertical: 15.h,
                                              ),
                                            ),
                                            onPressed: () {
                                              _updateConsultationStatus(
                                                  consultation.id!, 'Accepté');
                                            },
                                            child: Text(
                                              'Accepter',
                                              style: GoogleFonts.raleway(
                                                fontSize: 40.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(20.r),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 30.w,
                                                vertical: 15.h,
                                              ),
                                            ),
                                            onPressed: () {
                                              _updateConsultationStatus(
                                                  consultation.id!, 'Refusé');
                                            },
                                            child: Text(
                                              'Refuser',
                                              style: GoogleFonts.raleway(
                                                fontSize: 40.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.whiteColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is RendezVousError) {
                        return ReusableTextWidget(
                          text: state.message,
                          textSize: 55,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}