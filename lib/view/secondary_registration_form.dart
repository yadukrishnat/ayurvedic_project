import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/patient_register_controller.dart';
import '../widget/app_text.dart';
import '../widget/app_textfield.dart';
import '../widget/register_modules.dart';

class SecondaryRegistraionPage extends StatelessWidget {
  SecondaryRegistraionPage({super.key});

  final RegisterController controller = Get.put(RegisterController());
  final double spacing = 12; // consistent spacing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Register',size: 24,weight: FontWeight.w600,),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildField('Name', controller.nameController),
            buildField('Staff Exective', controller.staffController),
            buildField('Whatsapp Number', controller.whatsappController),
            buildField('Address', controller.addressController),

            SizedBox(height: spacing),
            LocationDropdown(controller: controller),
            SizedBox(height: spacing),
            BranchDropdown(controller: controller),

            SizedBox(height: spacing),
            TreatmentSummaryCard(
              femaleCount: controller.selectedTreatmentsList[0]['female'],
              maleCount: controller.selectedTreatmentsList[0]['male'],
              treatmentName: controller.selectedTreatmentsList[0]['name'],
            ),

            buildField('Total Amount', controller.totalAmountController),
            buildField('Discount Amount', controller.discountController),

            SizedBox(height: spacing),
            PaymentOption(controller: controller),

            buildField('Advance Amount', controller.advanceController),
            buildField('Balance Amount', controller.balanceController),

            SizedBox(height: spacing),
            DatePickerField(controller: controller, ),
            SizedBox(height: spacing),
            TimePickerField(controller: controller),

            SizedBox(height: spacing * 2),
            SizedBox(
              width: double.infinity,
              child: Obx(
                    () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: controller.isLoading.value
                      ? null // disable button while loading
                      : () {
                    controller.postRegister();
                  },
                  child: controller.isLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const AppText(
                    'Save',
                    size: 16,
                    weight: FontWeight.w600,
                    color: Colors.white,
                    align: TextAlign.center,
                  ),
                ),
              ),
            ),],
        ),
      ),
    );
  }

  // helper function for consistent field + spacing
  Widget buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label),
        const SizedBox(height: 4),
        AppTextField(controller: controller, hint: 'Enter $label'),
        const SizedBox(height: 12), // spacing after each field
      ],
    );
  }
}
