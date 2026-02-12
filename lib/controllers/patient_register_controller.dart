import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http; // Fixed import: Removed 'show post' to allow MultipartRequest
import 'package:intl/intl.dart';

class RegisterController extends GetxController {
  // Static Data
  final locations = ['Kochi', 'Trivandrum', 'Calicut'];
  final branches = ['Edappali', 'Kakkanad', 'Ernakulam'];
  final paymentOptions = ['Cash', 'Card', 'UPI'];
  final treatments = ['Treatment A', 'Treatment B', 'Treatment C'];

  // Form Field Controllers
  final nameController = TextEditingController();
  final whatsappController = TextEditingController();
  final addressController = TextEditingController();
  final totalAmountController = TextEditingController();
  final discountController = TextEditingController();
  final advanceController = TextEditingController();
  final balanceController = TextEditingController();

  // Observable Selections
  var selectedLocation = RxnString();
  var selectedBranch = RxnString();
  var selectedPayment = 'Cash'.obs;
  var selectedDate = DateTime.now().obs;      // stores the picked date
  var treatmentTime = TimeOfDay.now().obs;

  var formattedDate = ''.obs;
  var isLoading = false.obs;

  var selectedTreatmentsList = <Map<String, dynamic>>[].obs;

  void addTreatment() {
    selectedTreatmentsList.add({
      'name': '',
      'male': 0,
      'female': 0
    });
  }

  void addEmptyTreatment() {
    selectedTreatmentsList.add({
      'name': '',
      'male': 0,
      'female': 0,
    });
  }

  void removeTreatment(int index) => selectedTreatmentsList.removeAt(index);

  void updateMale(int index, bool increment) {
    if (!increment && selectedTreatmentsList[index]['male'] == 0) return;
    increment ? selectedTreatmentsList[index]['male']++ : selectedTreatmentsList[index]['male']--;
    selectedTreatmentsList.refresh();
  }

  void updateFemale(int index, bool increment) {
    if (!increment && selectedTreatmentsList[index]['female'] == 0) return;
    increment ? selectedTreatmentsList[index]['female']++ : selectedTreatmentsList[index]['female']--;
    selectedTreatmentsList.refresh();
  }

  void updateTreatmentName(int index, String name) {
    selectedTreatmentsList[index]['name'] = name;
    selectedTreatmentsList.refresh();
  }

  // Combined formatted string
  String get formattedDateTime {
    final datePart = DateFormat('dd/MM/yyyy').format(selectedDate.value);
    final hour = treatmentTime.value.hourOfPeriod == 0 ? 12 : treatmentTime.value.hourOfPeriod;
    final minute = treatmentTime.value.minute.toString().padLeft(2, '0');
    final period = treatmentTime.value.period == DayPeriod.am ? 'AM' : 'PM';
    return "$datePart-$hour:$minute $period";
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void setTreatmentTime(TimeOfDay time) {
    treatmentTime.value = time;
  }

  Future<void> postRegister() async {
    if (nameController.text.isEmpty || selectedBranch.value == null) {
      Get.snackbar("Error", "Please fill required fields", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final box = GetStorage();
    String? token = box.read('token');

    try {
      isLoading.value = true;

      // Initialize MultipartRequest for Form Data
      var uri = Uri.parse("https://flutter-amr.noviindus.in/api/PatientUpdate");
      var request = http.MultipartRequest("POST", uri); // Changed 'url' to 'uri' to match your variable

      // 1. Add Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // 2. Add Fields
      request.fields.addAll({
        "name": nameController.text,
        "excecutive": "Staff_01",
        "payment": selectedPayment.value,
        "phone": whatsappController.text,
        "address": addressController.text,
        "total_amount": totalAmountController.text,
        "discount_amount": discountController.text,
        "advance_amount":advanceController.text,
        "balance_amount": balanceController.text,
        "date_nd_time": formattedDateTime,
        "id": "0",
        "male": selectedTreatmentsList.isNotEmpty
            ? selectedTreatmentsList[0]['male'].toString()
            : "0",
        "female": selectedTreatmentsList.isNotEmpty
            ? selectedTreatmentsList[0]['female'].toString()
            : "0",
        "branch":  "166",
        "treatments": "Head Massage",
      });

      log("Fields being sent: ${request.fields}");

      // 3. Send Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Patient Registered Successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        log("Server Error Body: ${response.body}");
        Get.snackbar("Error", "Server Error: ${response.statusCode}");
      }
    } catch (e) {
      log("Connection Error: $e");
      Get.snackbar("Error", "Connection failed: $e");
    } finally {
      isLoading.value = false;
    }
  }
}