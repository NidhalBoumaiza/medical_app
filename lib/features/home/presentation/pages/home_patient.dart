import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/core/utils/navigation_with_transition.dart';
import 'package:medical_app/cubit/theme_cubit/theme_cubit.dart';
import 'package:medical_app/features/dashboard/presentation/pages/dashboard_patient.dart';
import 'package:medical_app/features/localisation/presentation/pages/pharmacie_page.dart';
import 'package:medical_app/features/notifications/presentation/pages/notifications_patient.dart';
import 'package:medical_app/features/ordonnance/presentation/pages/OrdonnancesPage.dart';
import 'package:medical_app/features/payement/presentation/pages/payement.dart';
import 'package:medical_app/features/profile/presentation/pages/ProfilPatient.dart';
import 'package:medical_app/features/rendez_vous/presentation/pages/RendezVousPatient.dart';
import 'package:medical_app/features/secours/presentation/pages/secours_screen.dart';
import 'package:medical_app/features/settings/presentation/pages/settings_patient.dart';
import 'package:medical_app/widgets/theme_cubit_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../authentication/presentation/pages/login_screen.dart';
import '../../../messagerie/presentation/pages/conversations_list_screen.dart';
import '../../../profile/presentation/pages/blocs/BLoC update profile/update_user_bloc.dart';
import '../../../rendez_vous/presentation/pages/appointments_patients.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePatient extends StatefulWidget {
  const HomePatient({super.key});

  @override
  State<HomePatient> createState() => _HomePatientState();
}

class _HomePatientState extends State<HomePatient> {
  int _selectedIndex = 0;
  String userId = '';
  String patientName = 'John Doe';
  String email = 'johndoe@example.com';
  DateTime? _selectedAppointmentDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('CACHED_USER');
    if (userJson != null) {
      print ('User JSON: $userJson');
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      setState(() {
        userId = userMap['id'] as String? ?? '';
        patientName = '${userMap['name'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
        email = userMap['email'] as String? ?? 'johndoe@example.com';
      });
    }
  }

  // Function to select a date for appointments
  Future<void> _selectAppointmentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAppointmentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedAppointmentDate) {
      setState(() {
        _selectedAppointmentDate = picked;
        _updatePages();
      });
    }
  }
  
  // Reset appointment date filter
  void _resetAppointmentDateFilter() {
    setState(() {
      _selectedAppointmentDate = null;
      _updatePages();
    });
  }
  
  // Update pages list with current state
  void _updatePages() {
    setState(() {
      _pages = [
        const Dashboardpatient(),
        AppointmentsPatients(showAppBar: false),
        const ConversationsScreen(showAppBar: false),
        const ProfilePatient(),
      ];
    });
  }

  List<BottomNavigationBarItem> get _navItems => [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined, size: 24),
      activeIcon: Icon(Icons.home_filled, size: 24),
      label: 'home'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined, size: 24),
      activeIcon: Icon(Icons.calendar_today, size: 24),
      label: 'appointments'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline, size: 24),
      activeIcon: Icon(Icons.chat_bubble, size: 24),
      label: 'messages'.tr,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline, size: 24),
      activeIcon: Icon(Icons.person, size: 24),
      label: 'profile'.tr,
    ),
  ];

  late List<Widget> _pages = [
    const Dashboardpatient(),
    AppointmentsPatients(showAppBar: false),
    const ConversationsScreen(showAppBar: false),
    const ProfilePatient(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onNotificationTapped() {
    navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
      context,
      const NotificationsPatient(),
    );
  }

  void _logout() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('confirm logout'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('CACHED_USER');
                await prefs.remove('TOKEN');

                // Use custom navigation with transition
                navigateToAnotherScreenWithSlideTransitionFromRightToLeftPushReplacement(
                  context,
                  LoginScreen(),
                );

                // Optional: show success message
                Get.snackbar(
                  'Success',
                  'Logged out successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                // Show error message if logout fails
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                print("Logout error: $e");
              }
            },
            child: Text('logout'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
    Color? color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: color ?? Colors.white,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color ?? Colors.white,
                    ),
                  ),
                ),
                if (badgeCount != null)
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: GoogleFonts.raleway(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    print ("1111111111111111111111111111111") ;
    print ("userId : $userId") ;
    return SafeArea(
      child: BlocListener<UpdateUserBloc, UpdateUserState>(
        listener: (context, state) {
          if (state is UpdateUserSuccess) {
            setState(() {
              patientName = '${state.user.name} ${state.user.lastName}'.trim();
              email = state.user.email;
              userId = state.user.id ?? '';
              _pages = [
                const Dashboardpatient(),
                AppointmentsPatients(showAppBar: false),
                const ConversationsScreen(showAppBar: false),
                const ProfilePatient(),
              ];
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: AppBar(
            title: Text(
              _selectedIndex == 1 ? 'Mes rendez-vous' : 'MediLink',
              style: GoogleFonts.raleway(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            actions: [
              if (_selectedIndex == 1) ...[
                IconButton(
                  icon: Icon(Icons.calendar_today, color: AppColors.whiteColor),
                  onPressed: () => _selectAppointmentDate(context),
                  tooltip: "Filtrer par date",
                ),
                if (_selectedAppointmentDate != null)
                  IconButton(
                    icon: Icon(Icons.clear, color: AppColors.whiteColor),
                    onPressed: _resetAppointmentDateFilter,
                    tooltip: "Réinitialiser le filtre",
                  ),
              ],
              IconButton(
                icon: Icon(Icons.notifications_none, size: 24, color: AppColors.whiteColor),
                onPressed: _onNotificationTapped,
              ),
            ],
          ),
          body: _pages[_selectedIndex],

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: BottomNavigationBar(
                items: _navItems,
                currentIndex: _selectedIndex,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: AppColors.textSecondary,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppColors.whiteColor,
                elevation: 10,
                selectedLabelStyle: GoogleFonts.raleway(fontSize: 12, fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.raleway(fontSize: 12, fontWeight: FontWeight.w500),
                onTap: _onItemTapped,
              ),
            ),
          ),

          drawer: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Drawer(
              width: MediaQuery.of(context).size.width * 0.8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
              ),
              elevation: 10,
              shadowColor: Colors.black26,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2fa7bb),
                      const Color(0xFF2fa7bb).withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 50, left: 25, right: 25, bottom: 25),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.whiteColor,
                              child: Icon(
                                Icons.person,
                                size: 36,
                                color: const Color(0xFF2fa7bb),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            patientName,
                            style: GoogleFonts.raleway(
                              fontSize: 18,
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Patient',
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              color: AppColors.whiteColor.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            email,
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              color: AppColors.whiteColor.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 1,
                      height: 1,
                    ),
                    SizedBox(height: 15),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        children: [
                          _buildDrawerItem(
                            icon: FontAwesomeIcons.filePrescription,
                            title: 'prescriptions'.tr,
                            badgeCount: 2,
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context,
                                const OrdonnancesPage(),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: FontAwesomeIcons.hospital,
                            title: 'hospitals'.tr,
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context,
                                const PharmaciePage(),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: FontAwesomeIcons.kitMedical,
                            title: 'first_aid'.tr,
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context,
                                const SecoursScreen(),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: FontAwesomeIcons.creditCard,
                            title: 'payments'.tr,
                            badgeCount: 1,
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context,
                                const PaymentsPage(),
                              );
                            },
                          ),
                          _buildDrawerItem(
                            icon: FontAwesomeIcons.gear,
                            title: 'settings'.tr,
                            onTap: () {
                              Navigator.pop(context);
                              navigateToAnotherScreenWithSlideTransitionFromRightToLeft(
                                context,
                                const SettingsPatient(),
                              );
                            },
                          ),
                          // Theme toggle
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: BlocBuilder<ThemeCubit, ThemeState>(
                              builder: (context, state) {
                                final isDarkMode = state is ThemeLoaded ? state.themeMode == ThemeMode.dark : false;
                                return Row(
                                  children: [
                                    Icon(
                                      isDarkMode
                                          ? FontAwesomeIcons.moon 
                                          : FontAwesomeIcons.sun,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      isDarkMode
                                          ? 'dark_mode'.tr 
                                          : 'light_mode'.tr,
                                      style: GoogleFonts.raleway(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: const ThemeCubitSwitch(compact: true),
                                    ),
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 1,
                      height: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      child: _buildDrawerItem(
                        icon: FontAwesomeIcons.rightFromBracket,
                        title: 'Logout'.tr,
                        onTap: _logout,
                        color: Colors.red[50],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}