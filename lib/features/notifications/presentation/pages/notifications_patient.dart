import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';

class NotificationsPatient extends StatefulWidget {
  const NotificationsPatient({super.key});

  @override
  State<NotificationsPatient> createState() => _NotificationsPatientState();
}

class _NotificationsPatientState extends State<NotificationsPatient> {
  String _selectedFilter = 'all'.tr;
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'appointment_confirmed'.tr,
      'message': 'appointment_confirmed_with'.trParams({'doctor': 'Dr. Dupont', 'time': '15/06 à 14:30'}),
      'time': '10_minutes_ago'.tr,
      'icon': Icons.event_available,
      'category': 'appointments'.tr,
      'read': false,
      'id': '1',
      'priority': 'high',
      'type': 'confirmation',
      'date': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'title': 'appointment_canceled'.tr,
      'message': 'appointment_canceled_on'.trParams({'date': '12/06'}),
      'time': '1_hour_ago'.tr,
      'icon': Icons.event_busy,
      'category': 'appointments'.tr,
      'read': true,
      'id': '2',
      'priority': 'high',
      'type': 'cancellation',
      'date': DateTime.now().add(const Duration(days: -1)),
    },
    {
      'title': 'medication_reminder'.tr,
      'message': 'take_medication'.trParams({'medication': 'Doliprane 500mg'}),
      'time': 'today_0800'.tr,
      'icon': Icons.medication_liquid,
      'category': 'medications'.tr,
      'read': false,
      'id': '3',
      'priority': 'medium',
      'type': 'medication_reminder',
      'medication': 'Doliprane 500mg',
      'dose': '1_tablet'.tr,
    },
    {
      'title': 'appointment_reminder'.tr,
      'message': 'appointment_reminder_lab'.trParams({'time': 'demain à 09:00'}),
      'time': 'yesterday_1830'.tr,
      'icon': Icons.notifications_active,
      'category': 'appointments'.tr,
      'read': false,
      'id': '4',
      'priority': 'high',
      'type': 'appointment_reminder',
      'date': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'title': 'prescription_ready'.tr,
      'message': 'prescription_available'.tr,
      'time': '2_days_ago'.tr,
      'icon': Icons.description,
      'category': 'prescriptions'.tr,
      'read': true,
      'id': '5',
      'priority': 'medium',
      'type': 'prescription',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          'notifications'.tr,
          style: GoogleFonts.raleway(
            fontSize: 50.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: 24.sp),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['all'.tr, 'appointments'.tr, 'medications'.tr, 'prescriptions'.tr];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: FilterChip(
              label: Text(
                filter,
                style: GoogleFonts.raleway(fontSize: 50.sp),
              ),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'all'.tr;
                });
              },
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColors.primaryColor,
              labelStyle: GoogleFonts.raleway(
                fontSize: 14.sp,
                color: _selectedFilter == filter ? AppColors.primaryColor : Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationList() {
    final filteredNotifications = _selectedFilter == 'all'.tr
        ? _notifications
        : _notifications.where((n) => n['category'] == _selectedFilter).toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 50.sp, color: Colors.grey[400]),
            SizedBox(height: 16.h),
            Text(
              'no_notifications'.tr,
              style: GoogleFonts.raleway(
                fontSize: 50.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return _buildDismissibleNotification(notification);
      },
    );
  }

  Widget _buildDismissibleNotification(Map<String, dynamic> notification) {
    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('delete_notification'.tr),
            content: Text('confirm_delete_notification'.tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('cancel'.tr),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('delete'.tr, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        final deletedNotification = notification;
        _removeNotification(notification['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('notification_deleted'.tr),
            action: SnackBarAction(
              label: 'undo'.tr,
              onPressed: () {
                setState(() {
                  _notifications.add(deletedNotification);
                });
              },
            ),
          ),
        );
      },
      child: _buildNotificationCard(notification),
    );
  }

  void _removeNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isUnread = !notification['read'];

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 1,
      color: AppColors.whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
          _handleNotificationTap(notification);
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(notification['priority']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification['icon'],
                      color: _getPriorityColor(notification['priority']),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: GoogleFonts.raleway(
                        fontSize: 16.sp,
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                notification['message'],
                style: GoogleFonts.raleway(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.h),
              if (notification['date'] != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14.sp, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text(
                        dateFormat.format(notification['date']),
                        style: GoogleFonts.raleway(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              if (notification['type'] == 'medication_reminder')
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.medical_information, size: 14.sp, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Text(
                        '${notification['medication']} - ${notification['dose']}',
                        style: GoogleFonts.raleway(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 8.h),
              Text(
                notification['time'],
                style: GoogleFonts.raleway(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
              if (notification['type'] == 'cancellation')
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RendezVousPatient(),
                          ),
                        );
                      },
                      child: Text(
                        'reschedule_appointment'.tr,
                        style: GoogleFonts.raleway(
                          fontSize: 14.sp,
                          color: AppColors.whiteColor,
                        ),
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return AppColors.primaryColor;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('filter_notifications'.tr, style: GoogleFonts.raleway(fontSize: 18.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['all'.tr, 'appointments'.tr, 'medications'.tr, 'prescriptions'.tr].map((filter) {
                return RadioListTile(
                  title: Text(filter, style: GoogleFonts.raleway(fontSize: 16.sp)),
                  value: filter,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value.toString();
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'confirmation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RendezVousPatient()),
        );
        break;
      case 'cancellation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RendezVousPatient()),
        );
        break;
      case 'medication_reminder':
      // TODO: Navigate to a medication tracking page when implemented
        break;
      case 'appointment_reminder':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RendezVousPatient()),
        );
        break;
      case 'prescription':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrdonnancesPage()),
        );
        break;
    }
  }
}