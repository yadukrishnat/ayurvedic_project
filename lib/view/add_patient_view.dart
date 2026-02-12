import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_register_controller.dart';
import '../model/treatment_model.dart';
import '../widget/app_text.dart';
import '../view/secondary_registration_form.dart';

class RegisterTreatmentPage extends StatelessWidget {
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    if (controller.selectedTreatmentsList.isEmpty) {
      controller.addEmptyTreatment();
    }

    return PopScope(
      canPop: false, // Prevents automatic popping
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.back(); // Manually navigate back using GetX
      },

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
      title: const AppText('Add Treatments', size: 18, weight: FontWeight.w600),
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Get.back(); // Navigate back to previous screen
        },
      ),
    ),
        body: Obx(() {
          return Column(
            children: [
              // List area
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.selectedTreatmentsList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildTreatmentCard(index);
                  },
                ),
              ),
      
              // Add Button (New) & Save Action
              _buildBottomActionArea().paddingOnly(bottom: 30),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTreatmentCard(int index) {
    final item = controller.selectedTreatmentsList[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  // Show loader while treatmentList is empty or isLoading is true
                  if (controller.isLoading.value && controller.treatmentList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return DropdownButtonFormField<Treatment>(
                    isExpanded: true, // Prevents text overflow in dropdown
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    value: controller.treatmentList.firstWhereOrNull((t) => t.id == item['id']),
                    hint: const AppText("Select Treatment", size: 14),
                    items: controller.treatmentList.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text("${t.name} - ₹${t.price}", overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        // Update the local item for UI
                        item['id'] = val.id;
                        item['name'] = val.name;

                        // ✅ Update selectedTreatmentId in controller
                        controller.selectedTreatmentId.value = val.id;

                        // Refresh the list to update UI
                        controller.selectedTreatmentsList.refresh();
                      }
                    },
                  );
                })
              ),
              if (controller.selectedTreatmentsList.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  onPressed: () => controller.removeTreatment(index),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _counterWidget("Male", item['male'],
                      () => controller.updateMale(index, false),
                      () => controller.updateMale(index, true)),
              Container(width: 1, height: 30, color: Colors.grey[300]),
              _counterWidget("Female", item['female'],
                      () => controller.updateFemale(index, false),
                      () => controller.updateFemale(index, true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterWidget(String label, int value, VoidCallback onDec, VoidCallback onInc) {
    return Column(
      children: [
        AppText(label, size: 12, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Row(
          children: [
            _circleButton(Icons.remove, onDec),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AppText('$value', size: 16, weight: FontWeight.bold),
            ),
            _circleButton(Icons.add, onInc),
          ],
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green[700],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildBottomActionArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Get.to(() => SecondaryRegistraionPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Treatment Details', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}