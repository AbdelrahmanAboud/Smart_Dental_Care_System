import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class Schedulepage extends StatefulWidget {
  @override
  State<Schedulepage> createState() => _SchedulepageState();
}

class _SchedulepageState extends State<Schedulepage> {
  DateTime selectedDay = DateTime.now();
  String? selectedSlot;

  String? selectedDoctorId;
  String? selectedDoctorName;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = formatDate(selectedDay);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "New Registration",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient Information",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            details(
              "Full Name",
              "Enter patient name",
              Icons.person,
              nameController,
            ),
            details(
              "Phone Number",
              "01xxxxxxxxx",
              Icons.phone,
              phoneController,
            ),
            details(
              "Email Address",
              "example@mail.com",
              Icons.email,
              emailController,
            ),

            const SizedBox(height: 30),

            Text(
              "Select Doctor",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Doctor')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                var doctors = snapshot.data!.docs;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDoctorId,
                      hint: const Text(
                        "Choose Doctor",
                        style: TextStyle(color: Colors.white24),
                      ),
                      dropdownColor: cardColor,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: primaryBlue),
                      items: doctors.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                            doc['name'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDoctorId = val;
                          selectedDoctorName = doctors.firstWhere(
                            (d) => d.id == val,
                          )['name'];
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            Text(
              "Select Date",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime dayDate = DateTime.now().add(Duration(days: index));
                  bool isSelected =
                      DateFormat('yyyy-MM-dd').format(dayDate) == formattedDate;

                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedDay = dayDate;
                      selectedSlot = null;
                    }),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryBlue : cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${dayDate.day}",
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            DateFormat('MMM').format(dayDate),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black54
                                  : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Text(
              "Available Slots for $formattedDate",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            StreamBuilder<DocumentSnapshot>(
              stream: (selectedDoctorId != null)
                  ? FirebaseFirestore.instance
                        .collection('available_slots')
                        .doc("${selectedDoctorId}_$formattedDate")
                        .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (selectedDoctorId == null) {
                  return const Center(
                    child: Text(
                      "Please select a doctor first",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      "No slots available for this doctor on this day",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                List<dynamic> fbSlots = snapshot.data!.get('slots') ?? [];

                if (fbSlots.isEmpty) {
                  return const Center(
                    child: Text(
                      "All slots are booked for this doctor!",
                      style: TextStyle(color: Colors.orange),
                    ),
                  );
                }

                return _buildSlotsGrid(fbSlots.cast<String>());
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => _handleBooking(formattedDate),
                child: const Text(
                  "Confirm Appointment",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsGrid(List<String> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedSlot == slots[index];
        return GestureDetector(
          onTap: () => setState(() => selectedSlot = slots[index]),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue.withOpacity(0.2) : cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? primaryBlue : Colors.transparent,
              ),
            ),
            child: Text(
              slots[index],
              style: TextStyle(
                color: isSelected ? primaryBlue : Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget details(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
              prefixIcon: Icon(icon, color: primaryBlue, size: 20),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBooking(String formattedDate) async {
    String email = emailController.text.trim();
    String name = nameController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        selectedSlot == null ||
        selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all details, select a doctor and a slot"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No patient found with this email!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var userData = userQuery.docs.first;
      String patientUid = userData.id;
      String patientNameFromDb = userData['name'];

      await FirebaseFirestore.instance.collection('appointments').add({
        'createdAt': FieldValue.serverTimestamp(),
        'date': Timestamp.fromDate(selectedDay),
        'patientId': patientUid,
        'patientName': patientNameFromDb,
        'doctorId': selectedDoctorId,
        'doctorName': selectedDoctorName,
        'riskScore': 0,
        'slot': selectedSlot,
        'treatment': "Consultation",
        'status': 'Pending',
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment Booked Successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      nameController.clear();
      phoneController.clear();
      emailController.clear();
      setState(() {
        selectedSlot = null;
      });
    } catch (e) {
      Navigator.pop(context);
      print("Booking Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
