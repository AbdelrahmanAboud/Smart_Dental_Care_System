import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Invoice_Model.dart';
import 'package:url_launcher/url_launcher.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});

  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);
  static const Color primaryBlue = Color(0xFF2EC4FF);

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  final Stream<QuerySnapshot> _invoicesStream =
  FirebaseFirestore.instance.collection('invoices').snapshots();

  // --- 1. إرسال إيميل احترافي (يفرق بين مدفوع ومعلق) ---
  Future<void> _fetchAndSendEmail(InvoiceModel invoice) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(invoice.patientId).get();
      String? patientEmail = userDoc.data()?['email'];

      if (patientEmail == null || patientEmail.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email not found for this patient")));
        return;
      }

      bool isPaid = invoice.status.toLowerCase() == "paid";

      // تنسيق محتوى الإيميل بناءً على الحالة
      final String subject = Uri.encodeComponent(isPaid
          ? "Payment Receipt - Smart Dental Care"
          : "Invoice Due - Smart Dental Care");

      final String statusHeader = isPaid
          ? "CONFIRMED RECEIPT"
          : "OUTSTANDING INVOICE";

      final String paymentInfo = isPaid
          ? "Payment Method: ${invoice.paymentMethod}\nStatus: PAID"
          : "Status: PENDING PAYMENT";

      final String body = Uri.encodeComponent(
          "--- $statusHeader ---\n\n"
              "Dear ${invoice.patientName},\n\n"
              "${isPaid ? 'Thank you for your payment.' : 'This is a reminder of your current invoice.'}\n\n"
              "Details:\n"
              "--------------------------\n"
              "Services: ${invoice.services.join(', ')}\n"
              "Total Amount: \$${invoice.totalAmount}\n"
              "$paymentInfo\n"
              "Date: ${invoice.date}\n"
              "--------------------------\n\n"
              "If you have any questions, please contact us.\n"
              "Best regards,\n"
              "Smart Dental Care Team");

      final Uri emailUri = Uri.parse("mailto:$patientEmail?subject=$subject&body=$body");

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error opening email app")));
    }
  }

  // --- 2. نافذة بيانات الكارت ---
  void _showCardPaymentDialog(String invoiceId) {
    final TextEditingController cardNum = TextEditingController();
    final TextEditingController cardExpiry = TextEditingController();
    final TextEditingController cardCVV = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Billing.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Enter Card Details", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: cardNum, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Card Number"), keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: cardExpiry, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("MM/YY"), keyboardType: TextInputType.datetime)),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: cardCVV, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("CVV"), keyboardType: TextInputType.number, obscureText: true)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Billing.primaryBlue),
            onPressed: () async {
              if (cardNum.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('invoices').doc(invoiceId).update({
                  'status': 'Paid',
                  'paymentMethod': 'Card',
                });
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text("Confirm Pay"),
          )
        ],
      ),
    );
  }

  // --- 3. خيارات الدفع ---
  void _showPaymentOptions(String invoiceId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Billing.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Select Payment Method", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _methodTile(Icons.payments, "Cash", Colors.green, () async {
              await FirebaseFirestore.instance.collection('invoices').doc(invoiceId).update({'status': 'Paid', 'paymentMethod': 'Cash'});
              Navigator.pop(context);
            }),
            _methodTile(Icons.credit_card, "Card", Colors.blue, () => _showCardPaymentDialog(invoiceId)),
            _methodTile(Icons.qr_code_2, "QR Code", Colors.purpleAccent, () async {
              await FirebaseFirestore.instance.collection('invoices').doc(invoiceId).update({'status': 'Paid', 'paymentMethod': 'QR'});
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _methodTile(IconData icon, String method, Color color, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, color: color), title: Text(method, style: const TextStyle(color: Colors.white)), onTap: onTap);
  }

  // --- 4. نافذة إنشاء فاتورة ---
  void _showGenerateInvoiceDialog() {
    String? selectedPatient;
    String? selectedPatientId;
    List<Map<String, dynamic>> tempServices = [];
    final TextEditingController serviceController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          double currentTotal = tempServices.fold(0, (sum, item) => sum + item['price']);
          return AlertDialog(
            backgroundColor: Billing.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Create New Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Patient').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const CircularProgressIndicator();
                        var patients = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          dropdownColor: Billing.cardColor,
                          decoration: _inputDecoration("Select Patient"),
                          style: const TextStyle(color: Colors.white),
                          items: patients.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc['name'] ?? "No Name"))).toList(),
                          onChanged: (val) {
                            selectedPatientId = val;
                            selectedPatient = patients.firstWhere((d) => d.id == val)['name'];
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(flex: 2, child: TextField(controller: serviceController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Service"))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: priceController, style: const TextStyle(color: Colors.white), decoration: _inputDecoration("Price"), keyboardType: TextInputType.number)),
                        IconButton(icon: const Icon(Icons.add_circle, color: Billing.primaryBlue), onPressed: () {
                          if (serviceController.text.isNotEmpty && priceController.text.isNotEmpty) {
                            setDialogState(() {
                              tempServices.add({'serviceName': serviceController.text, 'price': double.tryParse(priceController.text) ?? 0.0});
                              serviceController.clear(); priceController.clear();
                            });
                          }
                        })
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 30),
                    ...tempServices.map((s) => ListTile(title: Text(s['serviceName'], style: const TextStyle(color: Colors.white70)), trailing: Text("\$${s['price']}", style: const TextStyle(color: Colors.white)))),
                    Text("Total: \$${currentTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(onPressed: () async {
                if (selectedPatientId != null && tempServices.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('invoices').add({
                    'patientName': selectedPatient, 'patientId': selectedPatientId, 'status': 'pending', 'totalAmount': currentTotal,
                    'paymentMethod': 'None', 'services': tempServices, 'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                }
              }, child: const Text("Generate")),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Billing.primaryBlue)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Billing.bgColor,
      appBar: AppBar(backgroundColor: Billing.bgColor, title: const Text("Billing & Payments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        stream: _invoicesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final invoices = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return InvoiceModel(
              invoiceId: doc.id, patientId: data['patientId'] ?? '', patientName: data['patientName'] ?? 'Unknown',
              status: data['status'] ?? 'pending', totalAmount: (data['totalAmount'] ?? 0).toDouble(),
              paymentMethod: data['paymentMethod'] ?? 'None', services: (data['services'] as List?)?.map((s) => s['serviceName'].toString()).toList() ?? [], date: "Today",
            );
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatsCards(invoices),
                const SizedBox(height: 24),
                _buildNewInvoiceButton(),
                const SizedBox(height: 24),
                _buildInvoiceList(invoices),
                const SizedBox(height: 24),
                _buildPaymentSummary(invoices),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewInvoiceButton() {
    return SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _showGenerateInvoiceDialog, style: ElevatedButton.styleFrom(backgroundColor: Billing.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("Generate New Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  // --- ارجاع ديزاين الكارد القديم (الأفضل) ---
  Widget _buildInvoiceList(List<InvoiceModel> invoices) {
    return ListView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: invoices.length,
      itemBuilder: (context, index) => _buildInvoiceListItem(invoices[index]),
    );
  }

  Widget _buildInvoiceListItem(InvoiceModel invoice) {
    bool isPending = invoice.status.toLowerCase() == "pending";
    return Card(
      color: Billing.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(invoice.patientName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: getStatusColor(invoice.status).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(invoice.status.toUpperCase(), style: TextStyle(color: getStatusColor(invoice.status), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(invoice.services.join(", "), style: const TextStyle(color: Colors.white54, fontSize: 13)),
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("\$${invoice.totalAmount}", style: const TextStyle(color: Billing.primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.email_outlined, color: Colors.white70), onPressed: () => _fetchAndSendEmail(invoice)),
                    if (isPending)
                      ElevatedButton(
                        onPressed: () => _showPaymentOptions(invoice.invoiceId),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                        child: const Text("Pay", style: TextStyle(color: Billing.primaryBlue)),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(List<InvoiceModel> invoices) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Billing.cardColor, borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          const Text(
            "Payment Summary",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 15),
          // --------------------
          SummaryRow(label: "Cash Payments", value: calculateByMethod(invoices, "Cash"), color: Colors.greenAccent),
          SummaryRow(label: "Card Payments", value: calculateByMethod(invoices, "Card"), color: Colors.blueAccent),
          SummaryRow(label: "QR Payments", value: calculateByMethod(invoices, "QR"), color: Colors.purpleAccent),
          const Divider(color: Colors.white10, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Revenue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("\$${calculateTodayRevenue(invoices).toStringAsFixed(0)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(List<InvoiceModel> invoices) {
    return Row(
      children: [
        Expanded(child: BillingCard(icon: Icons.attach_money, iconColor: Colors.green, value: "\$${calculateTodayRevenue(invoices).toStringAsFixed(0)}", title: "Total Paid")),
        const SizedBox(width: 14),
        Expanded(child: BillingCard(icon: Icons.timer, iconColor: Colors.orange, value: "\$${calculatePending(invoices).toStringAsFixed(0)}", title: "Total Pending")),
      ],
    );
  }
}

// --- المساعدات ---
double calculateTodayRevenue(List<InvoiceModel> invoices) => invoices.where((inv) => inv.status.toLowerCase() == "paid").fold(0.0, (sum, item) => sum + item.totalAmount);
double calculatePending(List<InvoiceModel> invoices) => invoices.where((inv) => inv.status.toLowerCase() == "pending").fold(0.0, (sum, item) => sum + item.totalAmount);
double calculateByMethod(List<InvoiceModel> invoices, String method) => invoices.where((inv) => inv.status.toLowerCase() == "paid" && inv.paymentMethod == method).fold(0.0, (sum, item) => sum + item.totalAmount);
Color getStatusColor(String status) => status.toLowerCase() == 'paid' ? Colors.green : Colors.orange;

class BillingCard extends StatelessWidget {
  final IconData icon; final Color iconColor; final String value; final String title;
  const BillingCard({super.key, required this.icon, required this.iconColor, required this.value, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Color(0xFF0F2235), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(children: [Icon(icon, color: iconColor, size: 28), const SizedBox(height: 10), Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12))]),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label; final double value; final Color color;
  const SummaryRow({super.key, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70)), Text("\$${value.toStringAsFixed(0)}", style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
    );
  }
}