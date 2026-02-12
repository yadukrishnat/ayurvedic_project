import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http show MultipartRequest;

import '../config.dart';
import '../services/storage_service.dart';
import 'patient_controller.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // loader observable
  var isLoading = false.obs;

  Future<void> login() async {
    final username = emailController.text.trim();
    final password = passController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter both username and password.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true; // start loader

    try {
      var url = Uri.parse("${AppConfig.baseUrl}Login");
      var request = http.MultipartRequest("POST", url);

      request.fields['username'] = username;
      request.fields['password'] = password;

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final responseString = await streamedResponse.stream.bytesToString();
      final data =
      responseString.isNotEmpty ? jsonDecode(responseString) : {};

      // ✅ Successful login
      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        if (data['token'] != null && data['token'].toString().isNotEmpty) {
          StorageService.saveToken(data['token']);

          // Fetch patients after login
          final patientController = Get.put(PatientController());
          await patientController.fetchPatients();

        } else {
          Get.snackbar(
            "Login Failed",
            "Token not received. Please try again.",
            snackPosition: SnackPosition.BOTTOM,
          );
        }

      }
      // ❌ Invalid credentials
      else if (streamedResponse.statusCode == 400 || streamedResponse.statusCode == 401) {
        Get.snackbar(
          "Invalid Credentials",
          "Username or password is incorrect.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      // ❌ Forbidden
      else if (streamedResponse.statusCode == 403) {
        Get.snackbar(
          "Access Denied",
          "You do not have permission to login.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      // ❌ Not Found
      else if (streamedResponse.statusCode == 404) {
        Get.snackbar(
          "Not Found",
          "Login endpoint not found.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      // ❌ Server error
      else if (streamedResponse.statusCode == 500) {
        Get.snackbar(
          "Server Error",
          "Internal server error. Please try later.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      // ❌ Other errors
      else {
        Get.snackbar(
          "Error",
          "Unexpected error: ${streamedResponse.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on TimeoutException {
      Get.snackbar(
        "Timeout",
        "Request timed out. Check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}