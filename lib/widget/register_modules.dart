import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/patient_register_controller.dart';
import '../model/branch_response_model.dart';
import 'app_text.dart';
import 'app_textfield.dart';


class DatePickerField extends StatelessWidget {
  final RegisterController controller;
  const DatePickerField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText('Treatment Date'),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: controller.selectedDate.value,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) controller.setSelectedDate(picked);
          },
          child: AbsorbPointer(
            child: AppTextField(
              controller: TextEditingController(
                text: DateFormat('dd/MM/yyyy').format(controller.selectedDate.value),
              ),
              hint: 'Select date',
            ),
          ),
        ),
      ],
    ));
  }
}

class TimePickerField extends StatelessWidget {
  final dynamic controller;
  const TimePickerField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText('Treatment Time'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: controller.treatmentTime.value?.hour,
                  hint: const Text('Hour'),
                  items: List.generate(24, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                  onChanged: (val) {
                    if (val == null) return;
                    controller.setTreatmentTime(TimeOfDay(
                      hour: val,
                      minute: controller.treatmentTime.value?.minute ?? 0,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: controller.treatmentTime.value?.minute,
                  hint: const Text('Minutes'),
                  items: List.generate(60, (i) => DropdownMenuItem(value: i, child: Text('$i'))),
                  onChanged: (val) {
                    if (val == null) return;
                    controller.setTreatmentTime(TimeOfDay(
                      hour: controller.treatmentTime.value?.hour ?? 0,
                      minute: val,
                    ));
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
class LocationDropdown extends StatelessWidget {
  final RegisterController controller;
  const LocationDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
      value: controller.selectedLocation.value,
      items: controller.locations
          .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
          .toList(),
      onChanged: (val) => controller.selectedLocation.value = val,
      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Choose your location'),
    ));
  }
}

class BranchDropdown extends StatelessWidget {
  final RegisterController controller;

  const BranchDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.branchList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return DropdownButtonFormField<int>(
        value: controller.selectedBranchId.value == 0
            ? null
            : controller.selectedBranchId.value,
        items: controller.branchList.map((Branch b) {
          return DropdownMenuItem<int>(
            value: b.id,           // branch ID
            child: Text(b.name),   // branch name
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) controller.selectedBranchId.value = val;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Select the branch',
        ),
      );
    });
  }
}

class PaymentOption extends StatelessWidget {
  final RegisterController controller;

  const PaymentOption({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Option'),
            Row(

              children: controller.paymentOptions.map((option) {
                return Expanded(
                  child: RadioListTile<String>(
                    value: option,
                    groupValue: controller.selectedPayment.value,
                    title: Text(option),
                    onChanged: (val) => controller.selectedPayment.value = val!,
                  ),
                );
              }).toList(),
            ),
          ],
        ));
  }
}


class TreatmentSummaryCard extends StatelessWidget {
  final String treatmentName;
  final int maleCount;
  final int femaleCount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TreatmentSummaryCard({
    Key? key,
    required this.treatmentName,
    required this.maleCount,
    required this.femaleCount,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Treatment Name
            Expanded(
              child: Text(
                treatmentName.isEmpty ? 'No Treatment Selected' : treatmentName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Male & Female counts
            Row(
              children: [
                _countBox('Male', maleCount),
                SizedBox(width: 12),
                _countBox('Female', femaleCount),
                SizedBox(width: 12),
              ],
            ),

            // Edit Icon
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: onEdit,
              ),

            // Delete Icon
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }

  Widget _countBox(String label, int count) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text('$count', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// class TreatmentList extends StatelessWidget {
//   final RegisterController controller;
//   const TreatmentList({super.key, required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() => Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Treatments'),
//         const SizedBox(height: 4),
//         ...controller.treatments.asMap().entries.map((entry) {
//           int index = entry.key;
//           Map<String, dynamic> treatment = entry.value;
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 4),
//             child: ListTile(
//               title: Text('${treatment["name"]}'),
//               subtitle: Row(
//                 children: [
//                   Text('Male: ${treatment["male"]}  '),
//                   Text('Female: ${treatment["female"]}'),
//                 ],
//               ),
//               trailing: IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => controller.removeTreatment(index),
//               ),
//             ),
//           );
//         }),
//         TextButton.icon(
//           onPressed: controller.addTreatment,
//           icon: const Icon(Icons.add),
//           label: const Text('+ Add Treatments'),
//         ),
//       ],
//     ));
//   }
// }