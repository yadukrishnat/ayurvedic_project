import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../config.dart';
import '../model/patient_model.dart';
import '../view/booking_list.dart';

class PatientController extends GetxController {

  var patients = <PatientModel>[].obs;
  var page = 1;
  var isLoading = false.obs;
  var hasMore = true.obs;

  @override
  void onInit() {
    fetchPatients();
    super.onInit();
  }

  Future<void>  fetchPatients() async {


    try {
      isLoading.value = true;


      var data = await getPatients();
      if (data.isNotEmpty) {
        patients.value = data;
        Get.to(() => BookingListPage());
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  static Future<List<PatientModel>> getPatients() async {
    final box = GetStorage();
    log("function working>...");
    String? token = box.read('token');
    final response = await http.get(
      Uri.parse("${AppConfig.baseUrl}PatientList"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      print("BODY: $decoded");

      // ✅ Case 1: Direct list
      if (decoded is List) {
        return decoded.map((e) => PatientModel.fromJson(e)).toList();
      }

      // ✅ Case 2: Map → try common keys
      if (decoded is Map<String, dynamic>) {
        final possibleList =
            decoded["data"] ??
                decoded["results"] ??
                decoded["patients"] ??
                decoded.values.firstWhere(
                      (v) => v is List,
                  orElse: () => null,
                );

        if (possibleList is List) {
          return possibleList
              .map((e) => PatientModel.fromJson(e))
              .toList();
        }
      }

      throw Exception("API returned unknown format");
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  }

  String formatApiDate(String date) {
    if (date.isEmpty) return "";
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date; // return as-is if parsing fails
    }
  }
}