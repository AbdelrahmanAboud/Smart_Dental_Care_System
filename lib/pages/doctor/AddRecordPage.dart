// import 'package:flutter/material.dart';
// import 'package:smart_dental_care_system/data/PateintModels/DentelRecord.dart';

// // استخدام نفس الألوان اللي في صفحة السجل
// final Color bgColor = const Color(0xFF0B1C2D);
// final Color primaryBlue = const Color(0xFF2EC4FF);
// final Color cardColor = const Color(0xFF112B3C);

// class AddRecordPage extends StatefulWidget {
//   @override
//   State<AddRecordPage> createState() => _AddRecordPageState();
// }

// class _AddRecordPageState extends State<AddRecordPage> {
//   final _formKey = GlobalKey<FormState>();
  
//   // controllers لسحب الكلام اللي الدكتور هيكتبه
//   final TextEditingController _doctorNameController = TextEditingController();
//   final TextEditingController _visitTypeController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();
//   String _selectedStatus = 'Completed'; // القيمة الافتراضية

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         title: const Text("Add New Record", style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildSectionTitle("Doctor Information"),
//               _buildTextField("Doctor Name", _doctorNameController, Icons.person_outline),
//               const SizedBox(height: 20),
              
//               _buildSectionTitle("Visit Details"),
//               _buildTextField("Visit Type (e.g. Root Canal)", _visitTypeController, Icons.medical_services_outlined),
//               const SizedBox(height: 15),
//               _buildTextField("Date (e.g. 14 Feb 2026)", _dateController, Icons.calendar_today_outlined),
//               const SizedBox(height: 20),
              
//               _buildSectionTitle("Status"),
//               _buildStatusDropdown(),
//               const SizedBox(height: 20),
              
//               _buildSectionTitle("Clinical Notes"),
//               _buildTextField("Write details about the treatment...", _notesController, Icons.note_alt_outlined, maxLines: 4),
              
//               const SizedBox(height: 40),
              
//               // زرار الحفظ
//               SizedBox(
//                 width: double.infinity,
//                 height: 55,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryBlue,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       // هنا بنعمل Create لـ Object جديد
//                       final newRecord = DentalRecord(
//                         doctorName: _doctorNameController.text,
//                         visitType: _visitTypeController.text,
//                         date: _dateController.text,
//                         status: _selectedStatus,
//                         notes: _notesController.text,
//                       );
                      
//                       // المفروض هنا تبعته للـ API أو الـ Database
//                       print("New Record Created: ${newRecord.doctorName}");
//                       Navigator.pop(context); 
//                     }
//                   },
//                   child: const Text("Save Record", style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget مساعد لعمل العناوين
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10, left: 5),
//       child: Text(title, style: TextStyle(color: primaryBlue, fontSize: 14, fontWeight: FontWeight.bold)),
//     );
//   }

//   // Widget مساعد لعمل خانات الكتابة (TextFields)
//   Widget _buildTextField(String hint, TextEditingController controller, IconData icon, {int maxLines = 1}) {
//     return TextFormField(
//       controller: controller,
//       maxLines: maxLines,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: Colors.grey),
//         prefixIcon: Icon(icon, color: Colors.grey),
//         filled: true,
//         fillColor: cardColor,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
//         focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: primaryBlue)),
//       ),
//       validator: (value) => value!.isEmpty ? "Required field" : null,
//     );
//   }

//   // اختيار الحالة (Completed / Pending)
//   Widget _buildStatusDropdown() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedStatus,
//           dropdownColor: cardColor,
//           style: const TextStyle(color: Colors.white),
//           items: ['Completed', 'Pending'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             setState(() {
//               _selectedStatus = newValue!;
//             });
//           },
//         ),
//       ),
//     );
//   }
// }