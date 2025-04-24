// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:easy_localization/easy_localization.dart';

class checkoutButton extends StatelessWidget {
  const checkoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent, Colors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const HomePage();
              },
            ),
          );
        },
        child: Text(
          'checkout'.tr(),
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
