import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http; // Fixed import: Removed 'show post' to allow MultipartRequest
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
  var selectedDate = DateTime.now().obs;      // stores the picked date
  var treatmentTime = TimeOfDay.now().obs;
  var selectedBranchId = 0.obs;
  var selectedTreatmentId = 0.obs;
  var selectedTreatmentsList = <Map<String, dynamic>>[].obs;
  var formattedDate = ''.obs;
  var isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    fetchTreatments();
    fetchBranches();
    // optional if you want treatment names
  }
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

  void updateTreatmentName(int index, String id) {
    selectedTreatmentsList[index]['name'] = id;
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
    if (nameController.text.isEmpty || selectedBranch.value == 0) {
      // log actual values
      log("Name: ${nameController.text}, Branch: ${selectedBranch.value}");

      Get.snackbar(
        "Error",
        "Please fill required fields: Name = ${nameController.text}, Branch = ${selectedBranch.value}",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final box = GetStorage();
    String? token = box.read('token');

    try {
      isLoading.value = true;

      // Initialize MultipartRequest for Form Data
      var uri = Uri.parse("${AppConfig.baseUrl}PatientUpdate");
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
        "treatments": selectedBranchId.value.toString(),
      });

      log("Fields being sent: ${request.fields}");

      // 3. Send Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {

        final jsonData = jsonDecode(response.body);

// 1️⃣ Convert JSON to model
    final invoice = PatientInvoice.fromJson(jsonData);

// 2️⃣ Generate PDF
    final pdfData = await generateInvoicePDF(invoice);

// 3️⃣ Optional: Preview/Print PDF
    await Printing.layoutPdf(
    onLayout: (format) => pdfData,
    );

// 4️⃣ Navigate away
    Get.offAll(() => BookingListPage());


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

  Future<void> fetchBranches() async {
    final url = Uri.parse("https://flutter-amr.noviindus.in/api/BranchList");
    final box = GetStorage();
    String? token = box.read('token');
    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final branchResponse = BranchResponse.fromJson(data);
        branchList.value = branchResponse.branches;
      } else {
        print("BranchList Error: ${response.statusCode}");
      }
    } catch (e) {
      print("BranchList Exception: $e");
    }
  }

  void setSelectedBranch(int id) {
    selectedBranchId.value = id;
  }

  Future<void> fetchTreatments() async {
    final url = Uri.parse("https://flutter-amr.noviindus.in/api/TreatmentList");
    final box = GetStorage();
    String? token = box.read('token');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['treatments'] != null) {
          treatmentList.value = List<Treatment>.from(
            data['treatments'].map((x) => Treatment.fromJson(x)),
          );
        }
      } else {
        print("Treatment API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Treatment API Exception: $e");
    }
  }

  void setSelectedTreatment(int id) {
    selectedTreatmentId.value = id;
  }

}