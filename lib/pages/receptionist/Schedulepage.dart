import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/data/PateintModels/AvailableDay.dart';

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

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

    List<String> currentSlots = availabledays
        .firstWhere(
          (day) => day.date == formattedDate,
          orElse: () => AvailableDay(date: "", slots: []),
        )
        .slots;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("New Registration", style: TextStyle(color: Colors.white)),
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
        itemCount: availabledays.length,
        itemBuilder: (context, index) {
          DateTime dayDate = DateTime.parse(availabledays[index].date);
          bool isSelected = dayDate.day == selectedDay.day;

          return GestureDetector(
            onTap: () => setState(() => selectedDay = dayDate),
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
                    "Feb",
                    style: TextStyle(
                      color: isSelected ? Colors.black54 : Colors.white54,
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
             SizedBox(height: 30),

            Text(
              "Available Slots for ${formattedDate}",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            if (currentSlots.isEmpty)
              const Center(
                child: Text(
                  "No slots available for this day",
                  style: TextStyle(color: Colors.redAccent),
                ),
              )
            else
              _buildSlotsGrid(currentSlots),

             SizedBox(height: 40),

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
        onPressed: () {},
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
      physics:  NeverScrollableScrollPhysics(),
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
}