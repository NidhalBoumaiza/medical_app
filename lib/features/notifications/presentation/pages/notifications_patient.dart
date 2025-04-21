import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../rendez_vous/presentation/pages/RendezVousPatient.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String _selectedFilter = 'Tous';
  List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Rendez-vous confirmé',
      'message': 'Votre consultation avec le Dr. Dupont est confirmée pour le 15/06 à 14:30',
      'time': 'Il y a 10 min',
      'icon': Icons.event_available,
      'category': 'Rendez-vous',
      'read': false,
      'id': '1',
      'priority': 'high',
      'type': 'confirmation',
      'date': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'title': 'Rendez-vous annulé',
      'message': 'Votre consultation du 12/06 a été annulée. Cliquez pour replanifier',
      'time': 'Il y a 1 heure',
      'icon': Icons.event_busy,
      'category': 'Rendez-vous',
      'read': true,
      'id': '2',
      'priority': 'high',
      'type': 'annulation',
      'date': DateTime.now().add(const Duration(days: -1)),
    },
    {
      'title': 'Rappel de médicament',
      'message': 'Prendre votre dose de Doliprane 500mg ce matin',
      'time': 'Aujourd\'hui, 08:00',
      'icon': Icons.medication_liquid,
      'category': 'Médicaments',
      'read': false,
      'id': '3',
      'priority': 'medium',
      'type': 'rappel_medicament',
      'medicament': 'Doliprane 500mg',
      'dose': '1 comprimé',
    },
    {
      'title': 'Rappel de rendez-vous',
      'message': 'Vous avez un examen sanguin demain à 09:00 au labo Pasteur',
      'time': 'Hier, 18:30',
      'icon': Icons.notifications_active,
      'category': 'Rendez-vous',
      'read': false,
      'id': '4',
      'priority': 'high',
      'type': 'rappel_rdv',
      'date': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'title': 'Ordonnance prête',
      'message': 'Votre ordonnance est disponible en pharmacie',
      'time': 'Il y a 2 jours',
      'icon': Icons.description,
      'category': 'Médicaments',
      'read': true,
      'id': '5',
      'priority': 'medium',
      'type': 'ordonnance',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.whiteColor,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
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
    final filters = ['Tous', 'Rendez-vous', 'Médicaments'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'Tous';
                });
              },
              selectedColor: AppColors.primaryColor.withOpacity(0.2),
              checkmarkColor: AppColors.primaryColor,
              labelStyle: TextStyle(
                color: _selectedFilter == filter
                    ? AppColors.primaryColor
                    : Colors.grey[600],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationList() {
    final filteredNotifications = _selectedFilter == 'Tous'
        ? _notifications
        : _notifications.where((n) => n['category'] == _selectedFilter).toList();

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Supprimer la notification"),
            content: const Text("Voulez-vous vraiment supprimer cette notification ?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
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
            content: const Text("Notification supprimée"),
            action: SnackBarAction(
              label: 'Annuler',
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
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      color: AppColors.whiteColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            notification['read'] = true;
          });
          _handleNotificationTap(notification);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(notification['priority']).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notification['icon'],
                      color: _getPriorityColor(notification['priority']),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification['message'],
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              if (notification['date'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(notification['date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              if (notification['type'] == 'rappel_medicament')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.medical_information, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${notification['medicament']} - ${notification['dose']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                notification['time'],
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (notification['type'] == 'annulation')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RendezVousPatient(
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Replanifier le rendez-vous',
                        style: TextStyle(color: AppColors.whiteColor),
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
          title: const Text('Filtrer les notifications'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...['Tous', 'Rendez-vous', 'Médicaments'].map((filter) {
                return RadioListTile(
                  title: Text(filter),
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
      // Naviguer vers les détails du rendez-vous
        break;
      case 'annulation':
      // Ouvrir l'écran de replanification
        break;
      case 'rappel_medicament':
      // Ouvrir le suivi des médicaments
        break;
      case 'rappel_rdv':
      // Voir les détails du rendez-vous
        break;
      case 'ordonnance':
      // Ouvrir les ordonnances
        break;
    }
  }
}