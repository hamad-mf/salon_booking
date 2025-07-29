
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_in_controller.dart';
import 'package:salon_booking/Controller/sign_up_controller.dart';
import 'package:salon_booking/firebase_options.dart';
import 'package:salon_booking/splash_screen.dart';


Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
       ChangeNotifierProvider(
          create: (context) => SignUpController(),
        ),
         ChangeNotifierProvider(
          create: (context) => SignInController(),
        ),
      ],
      child: MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
  }
}
