import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/signin_controller.dart';
import '../widget/app_text.dart';
import '../widget/app_textfield.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SignInController controller = Get.put(SignInController());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Obx(() {
        return Stack(
          children: [
            Column(
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
                    padding: const EdgeInsets.all(20),
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
                        AppTextField(
                          hint: "Enter your email",
                          controller: controller.emailController,
                        ),
                        SizedBox(height: 30),

                        /// Password
                        AppTextField(
                          hint: "Enter password",
                          controller: controller.passController,
                          isPassword: true,
                        ),
                        SizedBox(height: 30),

                        /// Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null // disable button while loading
                                : () => controller.login(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : AppText(
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

            /// Full-screen overlay loader
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        );
      }),
    );
  }
}