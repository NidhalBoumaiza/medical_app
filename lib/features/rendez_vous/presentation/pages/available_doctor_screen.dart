import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/custom_snack_bar.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/rendez_vous/domain/entities/rendez_vous_entity.dart';
import 'package:medical_app/features/rendez_vous/presentation/blocs/rendez-vous%20BLoC/rendez_vous_bloc.dart';

class AvailableDoctorsScreen extends StatefulWidget {
  final String specialty;
  final DateTime startTime;
  final String patientId;
  final String patientName;

  const AvailableDoctorsScreen({
    Key? key,
    required this.specialty,
    required this.startTime,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<AvailableDoctorsScreen> createState() => _AvailableDoctorsScreenState();
}

class _AvailableDoctorsScreenState extends State<AvailableDoctorsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RendezVousBloc>().add(
      FetchDoctorsBySpecialty(widget.specialty, widget.startTime),
    );
  }

  Future<void> _confirmRendezVous(
      BuildContext context, MedecinEntity doctor) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la consultation'),
        content: Text(
          'Voulez-vous confirmer la consultation avec ${doctor.name} ${doctor.lastName} pour ${widget.startTime.toString().substring(0, 16)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final rendezVous = RendezVousEntity(
        patientId: widget.patientId,
        patientName: widget.patientName,
        doctorId: doctor.id,
        doctorName: '${doctor.name} ${doctor.lastName}',
        speciality: widget.specialty,
        startTime: widget.startTime,
        status: 'pending',
      );
      context.read<RendezVousBloc>().add(CreateRendezVous(rendezVous));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text('Médecins disponibles - ${widget.specialty}'),
        backgroundColor: const Color(0xFF2FA7BB),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<RendezVousBloc, RendezVousState>(
        listener: (context, state) {
          if (state is RendezVousError) {
            showErrorSnackBar(context, state.message);
          } else if (state is RendezVousCreated) {
            showSuccessSnackBar(context, 'Consultation confirmée, en attente d\'approbation');
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is RendezVousLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorsLoaded) {
            final doctors = state.doctors;
            if (doctors.isEmpty) {
              return const Center(child: Text('Aucun médecin disponible'));
            }
            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: ListTile(
                    title: Text('${doctor.name} ${doctor.lastName}'),
                    subtitle: Text(doctor.speciality),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.whiteColor,
                      ),
                      onPressed: () => _confirmRendezVous(context, doctor),
                      child: const Text('Sélectionner'),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}