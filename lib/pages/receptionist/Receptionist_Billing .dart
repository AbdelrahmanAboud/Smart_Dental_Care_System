import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Invoice_Model.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});

  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);
  static const Color primaryBlue = Color(0xFF2EC4FF);

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Billing.bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Billing.bgColor,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          "Billing & Payments",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics:  NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical
                  ,
                  child: BillingCard(
                    icon: Icons.attach_money,
                    iconColor: const Color(0xFF4CAF50),
                    value:
                        "\$${calculateTodayRevenue(fakeInvoices).toStringAsFixed(0)}",
                    title: "Today Revenue",
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: BillingCard(
                    icon: Icons.account_balance_wallet,
                    iconColor: const Color(0xFFE1D840),
                    value:
                        "\$${calculatepending(fakeInvoices).toStringAsFixed(0)}",
                    title: "Pending",
                  ),
                ),
              ],
            ),
             SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  elevation: 20,
                  backgroundColor: Billing.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shadowColor: Billing.primaryBlue,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      FontAwesomeIcons.fileInvoice,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Generate new Invoice",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(height: 28),
            ListView.builder(
              itemCount: fakeInvoices.length,
              shrinkWrap: true,
              physics:  NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final invoice = fakeInvoices[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side:  BorderSide(color: Colors.white10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  color: Billing.cardColor,
                  margin:  EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding:  EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              invoice.status,
                              style: TextStyle(
                                fontSize: 14,
                                color: getStatusColor(invoice.status),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          invoice.invoiceId,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Services:\n . ${invoice.services.join("\n .")}",
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.white38),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: \$${invoice.totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Billing.primaryBlue,
                              ),
                            ),
                            if (invoice.status == "Pending" ||
                                invoice.status == "Overdue")
                              ElevatedButton(
                                onPressed: () {},
                                child:  Text(
                                  "Process Payment",
                                  style: TextStyle(color: Billing.primaryBlue),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Billing.bgColor,
                                  padding:  EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Billing.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.send, color: Colors.greenAccent, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Send Receipt",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Email or SMS Receipt to patient",
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      "Send",
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Billing.bgColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Billing.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Payment Summary",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SummaryRow(
                    label: "Cash Payments",
                    value: calculateCashRevenue(fakeInvoices),
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 12),
                  SummaryRow(
                    label: "Card Payments",
                    value: calculateCardRevenue(fakeInvoices),
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 12),
                  SummaryRow(
                    label: "QR Payments",
                    value: calculateQRRevenue(fakeInvoices),
                    color: Colors.greenAccent,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white38, thickness: 1, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Revenue",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "\$${calculateTodayRevenue(fakeInvoices).toStringAsFixed(0)}",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;

  const BillingCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Billing.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Billing.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        padding:  EdgeInsets.symmetric(vertical: 15, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
             SizedBox(height: 12),
            Text(
              value,
              style:  TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        Text(
          "\$${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

double calculateTodayRevenue(List<InvoiceModel> invoices) {
  return invoices
      .where((inv) => inv.status == "Paid" && inv.date == "Today")
      .map((inv) => inv.totalAmount)
      .fold(0.0, (a, b) => a + b);
}

double calculatepending(List<InvoiceModel> invoices) {
  return invoices
      .where((inv) => inv.status == "Pending")
      .map((inv) => inv.totalAmount)
      .fold(0.0, (a, b) => a + b);
}

double calculateCashRevenue(List<InvoiceModel> invoices) {
  return invoices
      .where((inv) => inv.status == "Paid" && inv.paymentMethod == "Cash")
      .map((inv) => inv.totalAmount)
      .fold(0.0, (a, b) => a + b);
}

double calculateCardRevenue(List<InvoiceModel> invoices) {
  return invoices
      .where((inv) => inv.status == "Paid" && inv.paymentMethod == "Card")
      .map((inv) => inv.totalAmount)
      .fold(0.0, (a, b) => a + b);
}

double calculateQRRevenue(List<InvoiceModel> invoices) {
  return invoices
      .where((inv) => inv.status == "Paid" && inv.paymentMethod == "QR")
      .map((inv) => inv.totalAmount)
      .fold(0.0, (a, b) => a + b);
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Paid':
      return Colors.green;
    case 'Overdue':
      return Colors.redAccent;
    case 'Arrived':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
