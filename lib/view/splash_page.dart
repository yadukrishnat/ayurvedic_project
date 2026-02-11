import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
      Get.off(() => LoginPage());
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
