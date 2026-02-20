class DentalRecord {
  final String date;
  final String doctorName;
  final String visitType;
  final String notes;
  final String status;
  final String? attachmentUrl;
  final String status; 
  final String? attachmentUrl; // أضف هذا السطر

  DentalRecord({
    required this.date,
    required this.doctorName,
    required this.visitType,
    required this.notes,
    required this.status,
    required this.attachmentUrl,
  });
}

// List<DentalRecord> dentalRecords = [
//   DentalRecord(
//     date: "Oct 26, 2023",
//     doctorName: "Dr. Evelyn Reed",
//     visitType: "Routine Check-up",
//     notes:
//         "Notes:No new cavities detected. Advised on proper flossing technique.",
//     status: "completed",
//   ),
//   DentalRecord(
//     date: "Sep 14, 2023",
//     doctorName: "Dr. Michael Adams",
//     visitType: "Teeth Cleaning",
//     notes:
//         "Notes:Professional cleaning completed. Mild plaque buildup removed.",
//     status: "completed",
//   ),
//   DentalRecord(
//     date: "Aug 02, 2023",
//     doctorName: "Dr. Sarah Collins",
//     visitType: "Tooth Filling",
//     notes:
//         "Notes:Composite filling applied to upper left molar. Patient advised to avoid hard food for 24 hours.",
//     status: "completed",
//   ),
//   DentalRecord(
//     date: "Jul 18, 2023",
//     doctorName: "Dr. Daniel Moore",
//     visitType: "Root Canal Consultation",
//     notes:
//         "Notes:X-ray shows possible infection. Root canal treatment scheduled.",
//     status: "pending",
//   ),
//   DentalRecord(
//     date: "Jun 05, 2023",
//     doctorName: "Dr. Evelyn Reed",
//     visitType: "Dental X-Ray",
//     notes:
//         "Notes:Full mouth X-ray completed. No abnormalities detected.",
//     status: "completed",
//   ),
// ];




