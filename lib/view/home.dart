import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/app_text.dart';


class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: Column(
        children: [

          /// Top Image Section
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Image.asset(
                  "assets/images/signup_image.png",
                  fit: BoxFit.cover,
                ),
              ),

              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  "assets/images/main_icon.png",
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),

          /// Form Section
          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  AppText(
                    "Login Or Register To Book\nYour Appointments",
                    size: 20,
                    weight: FontWeight.bold,
                  ),

                  SizedBox(height: 25),

                  /// Email
                  AppText("Email", weight: FontWeight.w500),
                  SizedBox(height: 6),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  /// Password
                  AppText("Password", weight: FontWeight.w500),
                  SizedBox(height: 6),

                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      filled: true,
                      fillColor: Colors.grey[300],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  /// Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.snackbar("Login", "Button clicked");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: AppText(
                        "Login",
                        size: 16,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Spacer(),

                  /// Terms Text
                  Center(
                    child: AppText(
                      "By creating or logging into an account you are agreeing\n"
                          "with our Terms and Conditions and Privacy Policy.",
                      size: 12,
                      color: Colors.grey,
                      align: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
