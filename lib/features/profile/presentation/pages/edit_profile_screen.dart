import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_colors.dart';
import 'package:medical_app/features/authentication/domain/entities/medecin_entity.dart';
import 'package:medical_app/features/authentication/domain/entities/patient_entity.dart';
import 'package:medical_app/features/authentication/domain/entities/user_entity.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  final UserEntity user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _genderController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _antecedentController;
  late TextEditingController _specialityController;
  late TextEditingController _numLicenceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneNumberController = TextEditingController(text: widget.user.phoneNumber);
    _genderController = TextEditingController(text: widget.user.gender);
    _dateOfBirthController = TextEditingController(
        text: widget.user.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(widget.user.dateOfBirth!)
            : '');
    _antecedentController =
        TextEditingController(text: widget.user is PatientEntity ? (widget.user as PatientEntity).antecedent : '');
    _specialityController =
        TextEditingController(text: widget.user is MedecinEntity ? (widget.user as MedecinEntity).speciality : '');
    _numLicenceController =
        TextEditingController(text: widget.user is MedecinEntity ? (widget.user as MedecinEntity).numLicence : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    _antecedentController.dispose();
    _specialityController.dispose();
    _numLicenceController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      UserEntity updatedUser;
      if (widget.user is PatientEntity) {
        updatedUser = PatientEntity(
          id: widget.user.id,
          name: _nameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          role: widget.user.role,
          gender: _genderController.text,
          phoneNumber: _phoneNumberController.text,
          dateOfBirth: _dateOfBirthController.text.isNotEmpty
              ? DateTime.tryParse(_dateOfBirthController.text)
              : null,
          antecedent: _antecedentController.text,
        );
      } else {
        updatedUser = MedecinEntity(
          id: widget.user.id,
          name: _nameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          role: widget.user.role,
          gender: _genderController.text,
          phoneNumber: _phoneNumberController.text,
          dateOfBirth: _dateOfBirthController.text.isNotEmpty
              ? DateTime.tryParse(_dateOfBirthController.text)
              : null,
          speciality: _specialityController.text,
          numLicence: _numLicenceController.text,
        );
      }
      Navigator.pop(context, updatedUser);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirthController.text.isNotEmpty
          ? DateTime.parse(_dateOfBirthController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.whiteColor,
              surface: Colors.white,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'.tr),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'first_name_label'.tr,
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'name_required'.tr : null,
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'last_name_label'.tr,
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'last_name_required'.tr : null,
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        enabled: false,
                        controller: _emailController,
                        label: 'email'.tr,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) return 'email_required'.tr;
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'invalid_email_message'.tr;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        controller: _phoneNumberController,
                        label: 'phone_number_label'.tr,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'phone_number_required'.tr : null,
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        controller: _genderController,
                        label: 'gender'.tr,
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'gender_required'.tr : null,
                      ),
                      SizedBox(height: 24.h),
                      _buildTextField(
                        controller: _dateOfBirthController,
                        label: 'date_of_birth_label'.tr,
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        hintText: 'YYYY-MM-DD',
                      ),
                      if (widget.user is PatientEntity) ...[
                        SizedBox(height: 24.h),
                        _buildTextField(
                          controller: _antecedentController,
                          label: 'antecedent'.tr,
                          icon: Icons.medical_services,
                          validator: (value) => value!.isEmpty ? 'antecedent_required'.tr : null,
                        ),
                      ],
                      if (widget.user is MedecinEntity) ...[
                        SizedBox(height: 24.h),
                        _buildTextField(
                          controller: _specialityController,
                          label: 'speciality'.tr,
                          icon: Icons.work,
                          validator: (value) => value!.isEmpty ? 'speciality_required'.tr : null,
                        ),
                        SizedBox(height: 24.h),
                        _buildTextField(
                          controller: _numLicenceController,
                          label: 'num_licence'.tr,
                          icon: Icons.badge,
                          validator: (value) => value!.isEmpty ? 'num_licence_required'.tr : null,
                        ),
                      ],
                      SizedBox(height: 24.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            elevation: 5,
                          ),
                          child: Text(
                            'save'.tr,
                            style: TextStyle(fontSize: 50.sp, color: AppColors.whiteColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    bool? enabled,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      enabled: enabled ?? true,
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(color: AppColors.primaryColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.only(
          top: 70.h,
          bottom: 70.h,
          left: 16.w,
          right: 16.w,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.5)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: enabled == false ? Colors.grey[300] : Colors.grey[100],
      ),
      validator: validator,
    );
  }
}