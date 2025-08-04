import 'package:flutter/material.dart';

class SalonDetailScreendummy extends StatelessWidget {
  final String salonName;

  const SalonDetailScreendummy({Key? key, required this.salonName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(salonName)),
      body: Center(
        child: Text('Welcome to $salonName! Here you can add more details.'),
      ),
    );
  }
}
