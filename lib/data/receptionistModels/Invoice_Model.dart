class InvoiceModel {
  final String patientName;
  final String invoiceId;
  final List<String> services;
  final double totalAmount;
  final String status; 
  final String date;
  final String? paymentMethod; 

  InvoiceModel({
    required this.patientName,
    required this.invoiceId,
    required this.services,
    required this.totalAmount,
    required this.status,
    required this.date,
    this.paymentMethod,
  });
}

List<InvoiceModel> fakeInvoices = [
  InvoiceModel(
    patientName: "Sarah Johnson",
    invoiceId: "INV-2026-001",
    services: ["Regular Checkup", "Cleaning"],
    totalAmount: 250,
    status: "Paid",
    date: "Today",
    paymentMethod: "Cash",
  ),
  InvoiceModel(
    patientName: "Michael Chen",
    invoiceId: "INV-2026-002",
    services: ["Root Canal", "X-Ray"],
    totalAmount: 1200,
    status: "Paid",
    date: "Today",
    paymentMethod: "Card",
  ),
  InvoiceModel(
    patientName: "Emma Williams",
    invoiceId: "INV-2026-003",
    services: ["Cavity Filling"],
    totalAmount: 350,
    status: "Pending",
    date: "Today",
    paymentMethod: null,
  ),
  InvoiceModel(
    patientName: "James Brown",
    invoiceId: "INV-2026-155",
    services: ["Teeth Whitening"],
    totalAmount: 500,
    status: "Overdue",
    date: "Yesterday",
    paymentMethod: null,
  ),
];