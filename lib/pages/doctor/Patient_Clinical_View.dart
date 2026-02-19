import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_dental_care_system/pages/doctor/Tooth_Chart.dart';
import 'package:smart_dental_care_system/pages/doctor/Treatment_Plan.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient-Record.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class PatientClinicalView extends StatefulWidget {
  final String patientId;

  const PatientClinicalView({super.key, required this.patientId});

  @override
  State<PatientClinicalView> createState() => _PatientClinicalViewState();
}

class _PatientClinicalViewState extends State<PatientClinicalView> {
  String currentPatientName = "Patient"; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Patient Profile",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // StreamBuilder الأول: لجلب بيانات المريض
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.patientId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                  String? profileUrl = userData['profileImage'];
                  currentPatientName = userData['name'] ?? "Unknown Patient";

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryBlue.withOpacity(0.5), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: bgColor,
                            backgroundImage: (profileUrl != null && profileUrl.isNotEmpty)
                                ? NetworkImage(profileUrl)
                                : const AssetImage("lib/assets/user_logo.png") as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          currentPatientName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "ID: ${userData['id'] ?? 'N/A'}",
                          style: TextStyle(color: primaryBlue.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 15),
                        _buildContactInfo(Icons.phone, userData['phone'] ?? "No Phone"),
                        const SizedBox(height: 8),
                        _buildContactInfo(Icons.email, userData['email'] ?? "No Email"),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              // StreamBuilder الثاني: Dental Chart
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patients')
                    .doc(widget.patientId)
                    .snapshots(),
                builder: (context, snapshot) {
                  Map<String, String> teethStates = {};
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    if (data.containsKey('teeth_chart')) {
                      var chart = data['teeth_chart'] as Map<String, dynamic>;
                      chart.forEach((key, value) {
                        teethStates[key] = value['status'] ?? "none";
                      });
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: primaryBlue.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text("Interactive Dental Chart", style: TextStyle(fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 15),
                        const Text("Upper Jaw", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 1; i <= 16; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Uppertooth(i, teethStates[i.toString()] ?? "none"),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text("Low Jaw", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 17; i <= 32; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Lowertooth(i, teethStates[i.toString()] ?? "none"),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLegend(),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryBlue),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => Toothchart(patientId: widget.patientId)),
                                );
                              },
                              child: Text("View Detailed Chart", style: TextStyle(color: primaryBlue)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // زر Start New Treatment
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => TreatmentPlan(patientId: widget.patientId)),
                      );
                    },
                    child: const Text(
                      "Start New Treatment",
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: const Icon(Icons.receipt_long, color: Colors.white),
                    label: const Text(
                      "Add Billing Info",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showAddBillingSheet(context, currentPatientName),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: cardColor,
                      side: BorderSide(color: primaryBlue, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PatientRecord()));
                    },
                    child: Text("View Records", style: TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Functions المساعدة ---
  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem("Cavity", const Color(0xFFFF4D6D)),
            _legendItem("Filling", const Color(0xFF00E5FF)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem("Crown", const Color(0xFFFFC300)),
            _legendItem("Healthy", const Color(0xFF06D6A0)),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showAddBillingSheet(BuildContext context, String pName) {
  final TextEditingController serviceController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  
  List<Map<String, dynamic>> servicesList = [];
  double totalAmount = 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: cardColor,
    shape:  RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) => StatefulBuilder( 
      builder: (context, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Billing for $pName",
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
               SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: serviceController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Service",
                        labelStyle:  TextStyle(color: Colors.white60),
     focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: primaryBlue, width: 1),
    ),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryBlue.withOpacity(0.3))),
                      ),
                    ),
                  ),
                   SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style:  TextStyle(color: Colors.white),
                      decoration: InputDecoration(
     focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: primaryBlue, width: 1), 
    ),
                        labelText: "Price",
                        labelStyle:  TextStyle(color: Colors.white60),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryBlue.withOpacity(0.3))),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: primaryBlue, size: 30),
                    onPressed: () {
                      if (serviceController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        setSheetState(() {
                          servicesList.add({
                            'serviceName': serviceController.text,
                            'price': double.parse(priceController.text),
                          });
                          totalAmount += double.parse(priceController.text);
                          serviceController.clear();
                          priceController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),

               SizedBox(height: 15),

              if (servicesList.isNotEmpty)
                Container(
                  constraints:  BoxConstraints(maxHeight: 150),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: servicesList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        title: Text(servicesList[index]['serviceName'], style: const TextStyle(color: Colors.white)),
                        trailing: Text("${servicesList[index]['price']} EGP", style: TextStyle(color: primaryBlue)),
                        leading: IconButton(
                          icon:  Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            setSheetState(() {
                              totalAmount -= servicesList[index]['price'];
                              servicesList.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

              const Divider(color: Colors.white24),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text("Total:", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("${totalAmount.toStringAsFixed(2)} EGP", 
                      style: TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize:  Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: servicesList.isEmpty ? null : () async {
                  await FirebaseFirestore.instance.collection('invoices').add({
                    'patientId': widget.patientId,
                    'patientName': pName,
                    'services': servicesList, 
                    'totalAmount': totalAmount,
                    'status': 'pending',
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invoice sent to Receptionist successfully!")),
                  );
                },
                child:  Text("Send Full Invoice", 
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ),
  );
}
}

Widget Uppertooth(int number, String status) {
  Color color = _getToothColor(status);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25, height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        ),
      ),
      const SizedBox(height: 4),
      Text("$number", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
    ],
  );
}

Widget Lowertooth(int number, String status) {
  Color color = _getToothColor(status);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25, height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        ),
      ),
      const SizedBox(height: 4),
      Text("$number", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
    ],
  );
}

Color _getToothColor(String status) {
  switch (status) {
    case "cavity": return const Color(0xFFFF4D6D);
    case "filling": return const Color(0xFF00E5FF);
    case "crown": return const Color(0xFFFFC300);
    case "healthy": return const Color(0xFF06D6A0);
    default: return const Color(0xFF1B263B);
  }
}