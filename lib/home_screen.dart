import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_up_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        actions: [
          IconButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
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
    );
  }
}
