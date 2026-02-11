import 'package:ayurvedic/view/secondary_registration_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_register_controller.dart';

class RegisterTreatmentPage extends StatelessWidget {
  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
              () {
            // Ensure at least one item exists
            if (controller.selectedTreatmentsList.isEmpty) {
              controller.addEmptyTreatment();
            }

            return Column(
              children: [
                ...List.generate(controller.selectedTreatmentsList.length, (index) {
                  final item = controller.selectedTreatmentsList[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: item['name'].isEmpty ? null : item['name'],
                            hint: Text("Select Treatment"),
                            items: controller.treatments
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (val) => controller.updateTreatmentName(index, val!),
                          ),
                          counterRow(
                            "Male",
                            item['male'],
                                () => controller.updateMale(index, false),
                                () => controller.updateMale(index, true),
                          ),
                          counterRow(
                            "Female",
                            item['female'],
                                () => controller.updateFemale(index, false),
                                () => controller.updateFemale(index, true),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: controller.selectedTreatmentsList.length > 1
                                  ? () => controller.removeTreatment(index)
                                  : null, // Disable delete if only one
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (){
                      Get.to(() => RegisterScreen());

                    },
                    child: Text('SAVE RECORD'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],

            );
          },
        ),
      ),
    );
  }

  // Helper widget for counters
  Widget counterRow(String label, int value, VoidCallback onDec, VoidCallback onInc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: onDec),
            Text('$value', style: TextStyle(fontWeight: FontWeight.bold)),
            IconButton(icon: Icon(Icons.add_circle_outline), onPressed: onInc),
          ],
        ),
      ],
    );
  }
}
