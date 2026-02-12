import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/patient_controller.dart';
import '../widget/app_text.dart';
import '../widget/booking_card.dart';
import 'add_patient_view.dart';

class BookingListPage extends StatelessWidget {

  BookingListPage({super.key});

  final PatientController controller =
  Get.put(PatientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// Top Bar
              Row(
                children: const [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 12),
                  Icon(Icons.notifications_none),
                ],
              ),

              const SizedBox(height: 20),

              /// Search
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search for treatments",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                    ),
                    child: const AppText(
                      "Search",
                      color: Colors.white,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// Sort
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const AppText("Sort by :"),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(20),
                      border:
                      Border.all(color: Colors.grey),
                    ),
                    child: const Row(
                      children: [
                        AppText("Date"),
                        Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              /// Patient List
              Expanded(
                child: Obx(() {

                  if (controller.isLoading.value) {
                    return const Center(
                        child:
                        CircularProgressIndicator());
                  }

                  if (controller.patients.isEmpty) {
                    return const Center(
                      child:
                      AppText("No bookings found"),
                    );
                  }

                  return ListView.builder(
                    itemCount:
                    controller.patients.length,
                    itemBuilder: (_, i) {
                      final p =
                      controller.patients[i];

                      return BookingCard(
                        index: i + 1,
                        name: p.name ?? "",
                        treatment: p.patientDetails.isNotEmpty
                            ? p.patientDetails[0].treatmentName
                            : "",
                        date: controller.formatApiDate(p.dateTime), // you can format p.dateTime here
                        therapist: "Jithesh",
                      );
                      ;
                    },
                  );
                }),
              ),

              /// Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {  Get.off(() =>
                   RegisterTreatmentPage());},
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green[800],
                  ),
                  child: const AppText(
                    "Register Now",
                    color: Colors.white,
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
