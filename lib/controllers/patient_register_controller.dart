import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../config.dart';
import '../model/branch_response_model.dart';
import '../model/patient_invoice_model.dart';
import '../model/treatment_model.dart';
import '../services/pdf_view.dart';
import '../view/booking_list.dart';

class RegisterController extends GetxController {
  // Static Data
  final locations = ['Kochi', 'Trivandrum', 'Calicut'];
  var branchList = <Branch>[].obs;
  final paymentOptions = ['Cash', 'Card', 'UPI'];
  var treatmentList = <Treatment>[].obs;

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
  var selectedDate = DateTime.now().obs;
  var treatmentTime = TimeOfDay.now().obs;
  var selectedBranchId = 0.obs;
  var selectedTreatmentId = 0.obs;
  var selectedTreatmentsList = <Map<String, dynamic>>[].obs;
  var formattedDate = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await fetchTreatments();
    fetchBranches();
  }

  // Treatment selection
  void addEmptyTreatment() {
    selectedTreatmentsList.add({'name': '', 'male': 0, 'female': 0});
  }

  void removeTreatment(int index) => selectedTreatmentsList.removeAt(index);

  void updateMale(int index, bool increment) {
    if (!increment && selectedTreatmentsList[index]['male'] == 0) return;
    increment
        ? selectedTreatmentsList[index]['male']++
        : selectedTreatmentsList[index]['male']--;
    selectedTreatmentsList.refresh();
  }

  void updateFemale(int index, bool increment) {
    if (!increment && selectedTreatmentsList[index]['female'] == 0) return;
    increment
        ? selectedTreatmentsList[index]['female']++
        : selectedTreatmentsList[index]['female']--;
    selectedTreatmentsList.refresh();
  }

  void updateTreatmentName(int index, String id) {
    selectedTreatmentsList[index]['name'] = id;
    selectedTreatmentsList.refresh();
  }

  String get formattedDateTime {
    final datePart = DateFormat('dd/MM/yyyy').format(selectedDate.value);
    final hour = treatmentTime.value.hourOfPeriod == 0
        ? 12
        : treatmentTime.value.hourOfPeriod;
    final minute = treatmentTime.value.minute.toString().padLeft(2, '0');
    final period =
    treatmentTime.value.period == DayPeriod.am ? 'AM' : 'PM';
    return "$datePart-$hour:$minute $period";
  }

  void setSelectedDate(DateTime date) => selectedDate.value = date;

  void setTreatmentTime(TimeOfDay time) => treatmentTime.value = time;

  // POST register
  Future<void> postRegister() async {
    if (nameController.text.isEmpty || selectedBranchId.value == 0) {
      Get.snackbar(
        "Error",
        "Please fill required fields: Name and Branch are mandatory.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final box = GetStorage();
    String? token = box.read('token');

    try {
      isLoading.value = true;

      // Prepare API request
      var uri = Uri.parse("${AppConfig.baseUrl}PatientUpdate");
      var request = http.MultipartRequest("POST", uri);

      // Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      // Fields
      request.fields.addAll({
        "name": nameController.text,
        "excecutive": "Staff_01",
        "payment": selectedPayment.value,
        "phone": whatsappController.text,
        "address": addressController.text,
        "total_amount": totalAmountController.text,
        "discount_amount": discountController.text,
        "advance_amount": advanceController.text,
        "balance_amount": balanceController.text,
        "date_nd_time": formattedDateTime,
        "id": "",
        "male": selectedTreatmentsList.isNotEmpty
            ? selectedTreatmentsList[0]['male'].toString()
            : "0",
        "female": selectedTreatmentsList.isNotEmpty
            ? selectedTreatmentsList[0]['female'].toString()
            : "0",
        "branch": selectedBranchId.value.toString(),        // ✅ use selectedBranchId
        "treatments": selectedTreatmentId.value.toString(), // ✅ use selectedTreatmentId
      });

      // Log request for debugging
      request.fields.forEach((key, value) {

      });

      // Send request
      var streamedResponse = await request.send();
      var responseString = await streamedResponse.stream.bytesToString();



      final jsonData = responseString.isNotEmpty ? jsonDecode(responseString) : {};

      if (streamedResponse.statusCode == 200 || streamedResponse.statusCode == 201) {
        if (jsonData['status'] == true) {
          // ✅ Only proceed if API says success


// Create invoice from local data
          // 1️⃣ Create PatientInvoice from local form & controller data
          final invoice = PatientInvoice(
            name: nameController.text,
            executive: "Staff_01", // or dynamic if you have
            payment: selectedPayment.value,
            phone:whatsappController.text,
            address: addressController.text,
            totalAmount: double.tryParse(totalAmountController.text) ?? 0,
            discountAmount: double.tryParse(discountController.text) ?? 0,
            advanceAmount: double.tryParse(advanceController.text) ?? 0,
            balanceAmount: double.tryParse(balanceController.text) ?? 0,
            dateAndTime: formattedDateTime,
            id: 0, // new patient, or existing patient ID if updating
            male: selectedTreatmentsList.isNotEmpty
                ? selectedTreatmentsList[0]['male'] ?? 0
                : 0,
            female: selectedTreatmentsList.isNotEmpty
                ? selectedTreatmentsList[0]['female'] ?? 0
                : 0,
            branch: selectedBranchId.value,
            treatments: selectedTreatmentId.value,
          );


          final pdfData = await generateInvoicePDF(invoice);
          await Printing.layoutPdf(onLayout: (format) => pdfData);

          Get.offAll(() => BookingListPage());
        } else {
          // API returned status: false
          Get.snackbar(
            "Error",
            jsonData['message'] ?? "Unknown error from server",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        // Handle other HTTP errors
        Get.snackbar(
          "Server Error",
          "HTTP ${streamedResponse.statusCode}: ${jsonData['message'] ?? 'Something went wrong'}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Handle network or JSON parsing errors
      Get.snackbar(
        "Connection Error",
        "Failed to connect or parse response: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false; // Hide loader
    }
  }

  // GET branches
  Future<void> fetchBranches() async {
    final url = Uri.parse("${AppConfig.baseUrl}BranchList");
    final box = GetStorage();
    String? token = box.read('token');
    isLoading.value = true;

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final branchResponse = BranchResponse.fromJson(data);
        branchList.value = branchResponse.branches;
      } else if (response.statusCode == 401) {
        Get.snackbar("Unauthorized", "Token invalid or expired");
      } else if (response.statusCode == 403) {
        Get.snackbar("Forbidden", "Access denied");
      } else if (response.statusCode == 404) {
        Get.snackbar("Not Found", "Branches not found");
      } else if (response.statusCode == 500) {
        Get.snackbar("Server Error", "Internal server error");
      } else {
        Get.snackbar(
            "Error", "Unexpected error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Connection Error", "Failed to fetch branches: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // GET treatments
  Future<void> fetchTreatments() async {
    final url = Uri.parse("${AppConfig.baseUrl}TreatmentList");
    final box = GetStorage();
    String? token = box.read('token');
    isLoading.value = true;

    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['treatments'] != null) {
          treatmentList.value = List<Treatment>.from(
            data['treatments'].map((x) => Treatment.fromJson(x)),
          );
        } else {
          Get.snackbar("No Data", "No treatments found");
        }
      } else if (response.statusCode == 401) {
        Get.snackbar("Unauthorized", "Token invalid or expired");
      } else if (response.statusCode == 403) {
        Get.snackbar("Forbidden", "Access denied");
      } else if (response.statusCode == 404) {
        Get.snackbar("Not Found", "Treatment list not found");
      } else if (response.statusCode == 500) {
        Get.snackbar("Server Error", "Internal server error");
      } else {
        Get.snackbar(
            "Error", "Unexpected error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Connection Error", "Failed to fetch treatments: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedBranch(int id) => selectedBranchId.value = id;
  void setSelectedTreatment(int id) => selectedTreatmentId.value = id;
}