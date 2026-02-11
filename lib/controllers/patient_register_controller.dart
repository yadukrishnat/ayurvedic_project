import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

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
  var treatmentDate = Rxn<DateTime>();
  var treatmentTime = Rxn<TimeOfDay>();

  // DYNAMIC LIST: This stores the added treatments
  // Structure: {'name': string, 'male': int, 'female': int}
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

  // Update logic for dynamic list
  void updateMale(int index, bool increment) {
    if (!increment && selectedTreatmentsList[index]['male'] == 0) return;

    increment ? selectedTreatmentsList[index]['male']++ : selectedTreatmentsList[index]['male']--;
    selectedTreatmentsList.refresh(); // Important: Notifies GetX that a value inside the map changed
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

  void save() {
    if (selectedTreatmentsList.isEmpty) {
      Get.snackbar('Error', 'Please add at least one treatment');
      return;
    }
    Get.snackbar(
      'Saved',
      'Treatments saved successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
    );
  }
}