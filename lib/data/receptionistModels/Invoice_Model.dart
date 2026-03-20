class InvoiceModel {
  final String patientName;
  final String patientId;
  final String invoiceId;
  final List<Map<String, dynamic>> services;
  final double totalAmount;
  final String status;
  final String date;
  final String? paymentMethod;

  InvoiceModel({
    required this.patientName,
    required this.patientId,
    required this.invoiceId,
    required this.services,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.paymentMethod,
  });
}