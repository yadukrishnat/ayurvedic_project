import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'signin.dart';
import 'booking_list.dart'; // Your home page

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    _checkTokenAndNavigate();
  }

  void _checkTokenAndNavigate() async {
    // Initialize GetStorage
    await GetStorage.init();
    final box = GetStorage();

    // Wait 2–3 seconds for splash effect
    Timer(const Duration(seconds: 3), () {
      final token = box.read('token');

      if (token != null && token.isNotEmpty) {
        // ✅ Token exists, go to home / booking page
        Get.offAll(() => BookingListPage());
      } else {
        // ❌ No token, go to login page
        Get.offAll(() => LoginPage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          "assets/images/splashScreen.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}