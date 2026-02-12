import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/patient_controller.dart';
import '../widget/app_text.dart';
import '../widget/booking_card.dart';
import 'add_patient_view.dart';

class BookingListPage extends StatelessWidget {
  BookingListPage({super.key});

  final PatientController controller = Get.put(PatientController());
  final TextEditingController searchController = TextEditingController();

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.arrow_back),
                  Icon(Icons.notifications_none),
                ],
              ),

              const SizedBox(height: 20),

              /// Search
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search for treatments",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        "Comming soon",
                        "This feature will be available soon",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: const AppText(
                      "Search",
                      color: Colors.white,
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // /// Sort
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     const AppText("Sort by :"),
              //     Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(20),
              //         border: Border.all(color: Colors.grey),
              //       ),
              //       child: const Row(
              //         children: [
              //           AppText("Date"),
              //           Icon(Icons.keyboard_arrow_down)
              //         ],
              //       ),
              //     )
              //   ],
              // ),

              const SizedBox(height: 20),

              /// Patient List with Pull-to-Refresh
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.patients.isEmpty) {
                    return const Center(child: AppText("No bookings found"));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await  PatientController.getPatients(); // ✅ correct for static method;
                      Get.snackbar(
                        "Refreshed",
                        "Booking list updated",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.patients.length,
                      itemBuilder: (_, i) {
                        final p = controller.patients[i];

                        return BookingCard(
                          index: i + 1,
                          name: p.name ?? "",
                          treatment: p.patientDetails.isNotEmpty
                              ? p.patientDetails[0].treatmentName
                              : "",
                          date: controller.formatApiDate(p.dateTime),
                          therapist: "Jithesh",
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              /// Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.off(() => RegisterTreatmentPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const AppText(
                    "Register Now",
                    color: Colors.white,
                    size: 16,
                    weight: FontWeight.w600,
                    align: TextAlign.center,
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