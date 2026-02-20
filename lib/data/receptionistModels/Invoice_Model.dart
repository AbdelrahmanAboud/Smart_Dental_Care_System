class InvoiceModel {
  final String patientName;
  final String patientId; // <--- أضف هذا السطر
  final String invoiceId;
  final List<String> services;
  final double totalAmount;
  final String status;
  final String date;
  final String? paymentMethod;

  InvoiceModel({
    required this.patientName,
    required this.patientId, // <--- أضف هذا السطر
    required this.invoiceId,
    required this.services,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.paymentMethod,
  });
}