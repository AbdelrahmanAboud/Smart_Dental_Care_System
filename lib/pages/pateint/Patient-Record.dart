import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/PateintModels/DentelRecord.dart';
import 'package:smart_dental_care_system/pages/pateint/visit_details_Page.dart';
import 'package:url_launcher/url_launcher.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class PatientRecord extends StatefulWidget {
  @override
  State<PatientRecord> createState() => _PatientRrecordState();
}

class _PatientRrecordState extends State<PatientRecord> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final patientId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Medical Record",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(thickness: 1.5, color: Colors.black26),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Search records...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: cardColor.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: primaryBlue, width: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = "";
                        });
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Visit History",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patient_records')
                  .doc(patientId)
                  .collection('visits')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No visits yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                List<DentalRecord> visits = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return DentalRecord(
                        date: data['date'] ?? "",
                        doctorName: data['doctorName'] ?? "",
                        visitType: data['visitType'] ?? "",
                        notes: data['notes'] ?? "",
                        status: data['status'] ?? "Pending",
                        attachmentUrl: data['attachmentUrl'],
                      );
                    })
                    .where(
                      (record) =>
                          record.doctorName.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          record.visitType.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          record.date.toLowerCase().contains(_searchQuery) ||
                          record.status.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: visits.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: SizedBox(
                        width: 350,
                        child: RecordCard(visits[index], context),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

Widget RecordCard(DentalRecord record, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
    child: Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(record.date, style: TextStyle(color: primaryBlue)),
                Text(
                  record.status,
                  style: TextStyle(
                    color: record.status.toLowerCase() == "completed"
                        ? Color(0xFF00E676)
                        : Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              record.doctorName,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(record.visitType, style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),
            Text(
              record.notes,
              style: TextStyle(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),

            if (record.attachmentUrl != null &&
                record.attachmentUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final Uri url = Uri.parse(record.attachmentUrl!);

                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalNonBrowserApplication,
                    )) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },

                  child: Row(
                    children: [
                      Icon(Icons.attach_file, color: primaryBlue),
                      SizedBox(width: 5),
                      Text(
                        "View Attachment",
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
