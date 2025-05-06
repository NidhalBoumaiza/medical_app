import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:medical_app/core/utils/app_themes.dart';
import 'package:medical_app/cubit/theme_cubit/theme_cubit.dart';

class ThemeCubitSwitch extends StatelessWidget {
  final bool compact;
  
  const ThemeCubitSwitch({
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        if (state is ThemeLoaded) {
          final isDarkMode = state.themeMode == ThemeMode.dark;
          
          if (compact) {
            return Switch(
              value: isDarkMode,
              onChanged: (_) {
                context.read<ThemeCubit>().toggleTheme();
              },
              activeColor: AppThemes.primaryColor,
            );
          }
          
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppThemes.primaryColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isDarkMode ? "dark_mode".tr : "light_mode".tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (_) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    activeColor: AppThemes.primaryColor,
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show placeholder while theme is initializing
        return const SizedBox.shrink();
      },
    );
  }
} 