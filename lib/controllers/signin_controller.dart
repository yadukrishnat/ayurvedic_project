
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ayurvedic/controllers/patient_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http show MultipartRequest;

import '../services/storage_service.dart';

class SignInController extends GetxController{
  final emailController = TextEditingController();
  final passController = TextEditingController();

  Future<void> login() async {
    try {
      var url = Uri.parse("https://flutter-amr.noviindus.in/api/Login");

      var request = http.MultipartRequest("POST", url);

      // Form-data
      request.fields['username'] = emailController.text.trim();
      request.fields['password'] = passController.text.trim();

      log("API Called");

      var response = await request.send().timeout(
        const Duration(seconds: 30),
      );

      log("Status Code: ${response.statusCode}");

      var responseString = await response.stream.bytesToString();
      log("Raw Response: $responseString");

      var data = responseString.isNotEmpty
          ? jsonDecode(responseString)
          : {};

      /// ✅ IF CONDITIONS

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("✅ Login Success");
        log("$data");
        StorageService.saveToken(data['token']);
        Get.put(PatientController()).fetchPatients();
      } else if (response.statusCode == 400) {
        log("❌ Bad Request");
        log("$data");

      } else if (response.statusCode == 401) {
        log("❌ Unauthorized - Wrong credentials");

      } else if (response.statusCode == 403) {
        log("❌ Forbidden");

      } else if (response.statusCode == 404) {
        log("❌ API Not Found");

      } else if (response.statusCode == 500) {
        log("❌ Server Error");

      } else {
        log("⚠️ Unknown Status Code: ${response.statusCode}");
        log("$data");
      }

    } on TimeoutException {
      log("⏰ Request Timeout");

    } catch (e) {
      log("🔥 Unknown Error: $e");
    }
  }
}