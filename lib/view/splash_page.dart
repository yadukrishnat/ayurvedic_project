import 'dart:async';
import 'package:ayurvedic/view/secondary_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_patient_view.dart';
import 'booking_list.dart';
import 'signin.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
      Get.off(() =>
          RegisterTreatmentPage());
      //LoginPage());
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
          fit: BoxFit.cover, // makes it full screen
        ),
      ),
    );
  }

}
