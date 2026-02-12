import 'package:ayurvedic/view/secondary_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_register_controller.dart';
import '../model/treatment_model.dart';
import '../widget/app_text.dart';

class RegisterTreatmentPage extends StatelessWidget {
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        // Ensure at least one item exists
        if (controller.selectedTreatmentsList.isEmpty) {
          controller.addEmptyTreatment();
        }

        return Column(
          children: [
            // Top card with padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ...List.generate(1, (index) {
                        final item = controller.selectedTreatmentsList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              // Dropdown
                              DropdownButtonFormField<Treatment>(
                                value: item['id'] == 0
                                    ? null
                                    : controller.treatmentList.firstWhere(
                                      (t) => t.id == item['id'],
                                  orElse: () => controller.treatmentList[0],
                                ),
                                hint: const AppText(
                                  "Select Treatment",
                                  size: 14,
                                  weight: FontWeight.w500,
                                ),
                                items: controller.treatmentList.map((Treatment t) {
                                  return DropdownMenuItem<Treatment>(
                                    value: t,
                                    child: AppText(
                                      "${t.name} (${t.duration}) - ₹${t.price}",
                                      size: 14,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Treatment? val) {
                                  if (val != null) {
                                    controller.selectedTreatmentsList[index]['id'] = val.id;
                                    controller.selectedTreatmentsList[index]['name'] = val.name;
                                    controller.selectedTreatmentsList.refresh();
                                  }
                                },
                              ),

                              const SizedBox(height: 12),

                              // Counters
                              counterRow(
                                "Male",
                                item['male'],
                                    () => controller.updateMale(index, false),
                                    () => controller.updateMale(index, true),
                              ),
                              const SizedBox(height: 8),
                              counterRow(
                                "Female",
                                item['female'],
                                    () => controller.updateFemale(index, false),
                                    () => controller.updateFemale(index, true),
                              ),

                              const SizedBox(height: 8),

                              // Delete Button
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: controller.selectedTreatmentsList.length > 1
                                      ? () => controller.removeTreatment(index)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Spacer to push the button to bottom
            const Spacer(),

            // Save Button at bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => SecondaryRegistraionPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const AppText(
                    'Save',
                    size: 16,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).paddingOnly(bottom: 25),
          ],
        );
      }),
    );
  }

  // Helper widget for counters
  Widget counterRow(String label, int value, VoidCallback onDec, VoidCallback onInc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(label, size: 14, weight: FontWeight.w500),
        const SizedBox(width: 20),
        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: onDec),
        AppText('$value', size: 14, weight: FontWeight.bold),
        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: onInc),
      ],
    );
  }
}