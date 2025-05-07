import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousMedecin.dart';

import '../../../messagerie/presentation/pages/conversations_list_screen.dart';
import '../../../ordonnance/presentation/pages/OrdonnancesPage.dart';

class NotificationsMedecin extends StatefulWidget {
  const NotificationsMedecin({super.key});

  @override
  State<NotificationsMedecin> createState() => _NotificationsMedecinState();
}

class _NotificationsMedecinState extends State<NotificationsMedecin> {
  String _selectedFilter = 'all'.tr;
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'new_appointment_request'.tr,
      'message': 'patient_appointment_request'.trParams({'name': 'Jean Dupont', 'time': '15/06 à 14:30'}),
      'time': '10_minutes_ago'.tr,
      'icon': Icons.event_available,
      'category': 'appointments'.tr,
      'read': false,
      'id': '1',
      'priority': 'high',
      'type': 'appointment_request',
      'date': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'title': 'appointment_canceled'.tr,
      'message': 'patient_appointment_canceled'.trParams({'name': 'Marie Claire', 'time': '12/06 à 10:00'}),
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
      'title': 'new_patient_message'.tr,
      'message': 'new_message_from'.trParams({'name': 'Luc Martin'}),
      'time': 'today_0800'.tr,
      'icon': Icons.message,
      'category': 'messages'.tr,
      'read': false,
      'id': '3',
      'priority': 'medium',
      'type': 'message',
    },
    {
      'title': 'appointment_reminder'.tr,
      'message': 'reminder_appointment_with'.trParams({'name': 'Sophie Lemoine', 'time': 'demain à 09:00'}),
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
      'title': 'prescription_issued'.tr,
      'message': 'prescription_ready_for'.trParams({'name': 'Paul Durand'}),
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
          'Notifications'.tr,
          style: GoogleFonts.raleway(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: 24),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _buildFilterChip('all'.tr, 'all'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('appointments'.tr, 'appointments'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('messages'.tr, 'messages'.tr),
          SizedBox(width: 10.w),
          _buildFilterChip('prescriptions'.tr, 'prescriptions'.tr),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.raleway(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      selectedColor: AppColors.primaryColor,
      backgroundColor: Colors.grey[100],
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
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
            Icon(Icons.notifications_off, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'no_notifications'.tr,
              style: GoogleFonts.raleway(
                fontSize: 14,
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
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white, size: 24),
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
    final isUnread = !notification['read'];
    final priorityColor = _getPriorityColor(notification['priority']);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
          _handleNotificationTap(notification);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: priorityColor,
                width: 5,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medical-style icon with priority color
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _getMedicalIcon(notification),
                    ),
                    SizedBox(width: 12),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification['title'],
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            notification['message'],
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Unread indicator and timestamp
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isUnread)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        SizedBox(height: 6),
                        Text(
                          notification['time'],
                          style: GoogleFonts.raleway(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Date information if available
                if (notification['date'] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12, left: 38),
                    child: Row(
                      children: [
                        Icon(Icons.event, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(notification['date']),
                          style: GoogleFonts.raleway(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action button for appointment requests and cancellations
                if (notification['type'] == 'appointment_request' || notification['type'] == 'cancellation')
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RendezVousMedecin(),
                            ),
                          );
                        },
                        child: Text(
                          notification['type'] == 'appointment_request' ? 'review_appointment'.tr : 'view_appointments'.tr,
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _getMedicalIcon(Map<String, dynamic> notification) {
    IconData iconData;
    Color color = _getPriorityColor(notification['priority']);

    switch(notification['type']) {
      case 'appointment_request':
      case 'cancellation':
      case 'appointment_reminder':
        iconData = Icons.calendar_month;
        break;
      case 'message':
        iconData = Icons.message;
        break;
      case 'prescription':
        iconData = Icons.description;
        break;
      default:
        iconData = notification['icon'] ?? Icons.notifications;
    }

    return Icon(
      iconData,
      color: color,
      size: 20,
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return AppColors.primaryColor;
      case 'low':
        return Colors.green;
      default:
        return AppColors.primaryColor;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'filter_notifications'.tr,
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              )
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['all'.tr, 'appointments'.tr, 'messages'.tr, 'prescriptions'.tr].map((filter) {
                return RadioListTile<String>(
                  title: Text(
                      filter,
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.grey[700],
                      )
                  ),
                  value: filter,
                  groupValue: _selectedFilter,
                  activeColor: AppColors.primaryColor,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        );
      },
    );
  }

  void _handleNotificationTap(Map<String, dynamic> notification) {
    switch (notification['type']) {
      case 'appointment_request':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RendezVousMedecin()),
        );
        break;
      case 'cancellation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RendezVousMedecin()),
        );
        break;
      case 'message':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationsScreen(),
          ),
        );
        break;
      case 'appointment_reminder':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RendezVousMedecin()),
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