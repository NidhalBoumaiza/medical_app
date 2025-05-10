import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/prescription_entity.dart';
import '../bloc/prescription_bloc.dart';
import 'prescription_details_page.dart';

class PrescriptionsListPage extends StatefulWidget {
  final bool isDoctor;
  final String userId;
  final String userName;

  const PrescriptionsListPage({
    Key? key,
    required this.isDoctor,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  _PrescriptionsListPageState createState() => _PrescriptionsListPageState();
}

class _PrescriptionsListPageState extends State<PrescriptionsListPage> {
  late PrescriptionBloc _prescriptionBloc;

  @override
  void initState() {
    super.initState();
    _prescriptionBloc = BlocProvider.of<PrescriptionBloc>(context);
    _loadPrescriptions();
  }

  void _loadPrescriptions() {
    if (widget.isDoctor) {
      _prescriptionBloc.add(GetDoctorPrescriptions(doctorId: widget.userId));
    } else {
      _prescriptionBloc.add(GetPatientPrescriptions(patientId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDoctor ? 'Mes Ordonnances' : 'Mes Ordonnances',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: BlocBuilder<PrescriptionBloc, PrescriptionState>(
        builder: (context, state) {
          if (state is PrescriptionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DoctorPrescriptionsLoaded && widget.isDoctor) {
            return _buildPrescriptionsList(state.prescriptions);
          } else if (state is PatientPrescriptionsLoaded && !widget.isDoctor) {
            return _buildPrescriptionsList(state.prescriptions);
          } else if (state is PrescriptionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Erreur: ${state.message}',
                    style: GoogleFonts.raleway(
                      fontSize: 16.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: _loadPrescriptions,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      'Réessayer',
                      style: GoogleFonts.raleway(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    color: Colors.grey,
                    size: 60.sp,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Chargement des ordonnances...',
                    style: GoogleFonts.raleway(
                      fontSize: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPrescriptionsList(List<PrescriptionEntity> prescriptions) {
    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              color: Colors.grey,
              size: 60.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Aucune ordonnance',
              style: GoogleFonts.raleway(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.isDoctor
                  ? 'Vous n\'avez pas encore créé d\'ordonnance'
                  : 'Vous n\'avez pas encore reçu d\'ordonnance',
              style: GoogleFonts.raleway(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadPrescriptions();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return _buildPrescriptionCard(prescription);
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionEntity prescription) {
    final medicationCount = prescription.medications.length;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider<PrescriptionBloc>.value(
                value: _prescriptionBloc,
                child: PrescriptionDetailsPage(
                  prescription: prescription,
                  isDoctor: widget.isDoctor,
                ),
              ),
            ),
          ).then((_) {
            // Refresh list when returning
            _loadPrescriptions();
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Ordonnance du ${DateFormat('dd/MM/yyyy').format(prescription.date)}',
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                widget.isDoctor
                    ? 'Patient: ${prescription.patientName}'
                    : 'Médecin: Dr. ${prescription.doctorName}',
                style: GoogleFonts.raleway(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              Divider(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$medicationCount médicament${medicationCount > 1 ? 's' : ''}',
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Voir détails',
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryColor,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
              
              // Show edit status if doctor
              if (widget.isDoctor) 
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16.sp,
                        color: Colors.green,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Modifiable',
                        style: GoogleFonts.raleway(
                          fontSize: 12.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 