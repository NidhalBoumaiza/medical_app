import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../authentication/domain/entities/medecin_entity.dart';
import '../../../ratings/domain/entities/doctor_rating_entity.dart';
import '../../../ratings/presentation/bloc/rating_bloc.dart';

class DoctorProfilePage extends StatefulWidget {
  final MedecinEntity doctor;
  final bool canBookAppointment;
  final VoidCallback? onBookAppointment;

  const DoctorProfilePage({
    Key? key, 
    required this.doctor,
    this.canBookAppointment = false,
    this.onBookAppointment,
  }) : super(key: key);

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  @override
  void initState() {
    super.initState();
    // Request ratings and average rating when page loads
    if (widget.doctor.id != null) {
      context.read<RatingBloc>().add(GetDoctorRatings(widget.doctor.id!));
      context.read<RatingBloc>().add(GetDoctorAverageRating(widget.doctor.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil du médecin",
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor header card with basic info
            _buildDoctorHeaderCard(),
            
            // Ratings section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                "Évaluations des patients",
                style: GoogleFonts.raleway(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            BlocBuilder<RatingBloc, RatingState>(
              builder: (context, state) {
                if (state is DoctorAverageRatingLoaded) {
                  return _buildRatingSummary(state.averageRating);
                } else if (state is RatingLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                } else if (state is RatingError) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      "Erreur lors du chargement des évaluations: ${state.message}",
                      style: GoogleFonts.raleway(
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return _buildRatingSummary(0.0);
              },
            ),
            
            // Patient comments
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: Text(
                "Commentaires",
                style: GoogleFonts.raleway(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            BlocBuilder<RatingBloc, RatingState>(
              builder: (context, state) {
                if (state is DoctorRatingsLoaded) {
                  final ratings = state.ratings;
                  if (ratings.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Center(
                        child: Text(
                          "Aucun commentaire disponible",
                          style: GoogleFonts.raleway(
                            color: Colors.grey[600],
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      return _buildCommentCard(ratings[index]);
                    },
                  );
                } else if (state is RatingLoading) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  );
                } else if (state is RatingError) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text(
                      "Erreur lors du chargement des commentaires: ${state.message}",
                      style: GoogleFonts.raleway(
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Text(
                      "Chargement des commentaires...",
                      style: GoogleFonts.raleway(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Book appointment button
            if (widget.canBookAppointment && widget.onBookAppointment != null)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: widget.onBookAppointment,
                    child: Text(
                      "Prendre rendez-vous",
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeaderCard() {
    return Card(
      margin: EdgeInsets.all(16.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 70.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${widget.doctor.name} ${widget.doctor.lastName}",
                        style: GoogleFonts.raleway(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.doctor.speciality ?? "Spécialité non spécifiée",
                        style: GoogleFonts.raleway(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 30.h, thickness: 1),
            
            // Contact info
            Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.doctor.email,
                  style: GoogleFonts.raleway(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if (widget.doctor.phoneNumber != null && widget.doctor.phoneNumber!.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: AppColors.primaryColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.doctor.phoneNumber!,
                    style: GoogleFonts.raleway(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(double averageRating) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                averageRating.toStringAsFixed(1),
                style: GoogleFonts.raleway(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBar.builder(
                  initialRating: averageRating,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 24.sp,
                  ignoreGestures: true,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                SizedBox(height: 4.h),
                BlocBuilder<RatingBloc, RatingState>(
                  builder: (context, state) {
                    int ratingCount = 0;
                    if (state is DoctorRatingsLoaded) {
                      ratingCount = state.ratings.length;
                    }
                    return Text(
                      "$ratingCount évaluations",
                      style: GoogleFonts.raleway(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(DoctorRatingEntity rating) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryColor.withOpacity(0.2),
                  radius: 20.sp,
                  child: Text(
                    rating.patientName != null && rating.patientName!.isNotEmpty
                        ? rating.patientName![0]
                        : "P",
                    style: GoogleFonts.raleway(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.patientName ?? "Patient",
                      style: GoogleFonts.raleway(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(rating.createdAt),
                      style: GoogleFonts.raleway(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        rating.rating.toString(),
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (rating.comment != null && rating.comment!.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                rating.comment!,
                style: GoogleFonts.raleway(
                  fontSize: 14.sp,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 