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
        "Please fill required fields: Name & Branch",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final box = GetStorage();
    String? token = box.read('token');
    isLoading.value = true;

    try {
      var uri = Uri.parse("${AppConfig.baseUrl}PatientUpdate");
      var request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

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
        "id": "0",
        "male": selectedTreatmentsList.isNotEmpty
            ? selectedTreatmentsList[0]['male'].toString()
            : "0",
        "female": selectedTreatmentsList.isNotEmpty
            ? selectedTreatmentsList[0]['female'].toString()
            : "0",
        "branch": selectedBranchId.value.toString(),
        "treatments": selectedTreatmentId.value.toString(),
      });

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        final invoice = PatientInvoice.fromJson(jsonData);
        final pdfData = await generateInvoicePDF(invoice);
        await Printing.layoutPdf(onLayout: (format) => pdfData);
        Get.offAll(() => BookingListPage());
      } else if (response.statusCode == 400) {
        Get.snackbar("Bad Request", "Invalid data sent to server");
      } else if (response.statusCode == 401) {
        Get.snackbar("Unauthorized", "Token invalid or expired");
      } else if (response.statusCode == 403) {
        Get.snackbar("Forbidden", "Access denied");
      } else if (response.statusCode == 404) {
        Get.snackbar("Not Found", "API endpoint not found");
      } else if (response.statusCode == 500) {
        Get.snackbar("Server Error", "Internal server error");
      } else {
        Get.snackbar(
            "Error", "Unexpected error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Connection Error", "Failed to connect: $e");
    } finally {
      isLoading.value = false;
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