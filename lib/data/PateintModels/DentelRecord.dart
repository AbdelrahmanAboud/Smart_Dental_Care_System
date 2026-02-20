class DentalRecord {
  final String date;
  final String doctorName;
  final String visitType;
  final String notes;
  final String status;
  final String? attachmentUrl;

  DentalRecord({
    required this.date,
    required this.doctorName,
    required this.visitType,
    required this.notes,
    required this.status,
    required this.attachmentUrl,
  });
}
