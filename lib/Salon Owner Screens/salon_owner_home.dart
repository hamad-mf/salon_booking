import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_up_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalonOwnerHome extends StatefulWidget {
  const SalonOwnerHome({super.key});

  @override
  State<SalonOwnerHome> createState() => _SalonOwnerHomeState();
}

class _SalonOwnerHomeState extends State<SalonOwnerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isOwnerLoggedIn', false);
              final authController = Provider.of<SignUpController>(
                context,
                listen: false,
              );

              authController.signOut(context);
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: Text("owner home screen"))],
      ),
    );
  }
}