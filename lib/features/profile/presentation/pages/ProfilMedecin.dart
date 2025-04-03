import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../authentication/data/models/User.dart';

class ProfilMedecin extends StatefulWidget {
  const ProfilMedecin ({Key? key}) : super(key: key);

  @override
  State<ProfilMedecin> createState() => _ProfilMedecinState();
}

class _ProfilMedecinState extends State<ProfilMedecin> {
  var user = GetStorage().read('user');
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(35.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage('assets/images/profil.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.primaryColor),

                  ),
                ),
              ],

            ),
          ),
        ),
      ),

    );
  }
}
