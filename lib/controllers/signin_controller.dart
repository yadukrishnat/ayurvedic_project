import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ayurvedic/controllers/patient_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http show MultipartRequest;

import '../services/storage_service.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  // loader observable
  var isLoading = false.obs;

  Future<void> login() async {
    try {
      isLoading.value = true; // start loader

      var url = Uri.parse("https://flutter-amr.noviindus.in/api/Login");
      var request = http.MultipartRequest("POST", url);

      request.fields['username'] = emailController.text.trim();
      request.fields['password'] = passController.text.trim();

      log("API Called");

      var response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var responseString = await response.stream.bytesToString();
      var data = responseString.isNotEmpty ? jsonDecode(responseString) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Login Success");
        StorageService.saveToken(data['token']);

        // Initialize PatientController and wait for patients to load
        final patientController = Get.put(PatientController());
        await patientController.fetchPatients(); // await completion

        // After patients are fetched and page is loaded, stop loader
        isLoading.value = false;

      } else {
        log("❌ Login Failed: ${response.statusCode} $data");
        Get.snackbar(
          "Error",
          "Login failed. Check credentials.",
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
      }
    } on TimeoutException {
      log("⏰ Request Timeout");
      isLoading.value = false;
    } catch (e) {
      log("🔥 Unknown Error: $e");
      isLoading.value = false;
    }
  }
}