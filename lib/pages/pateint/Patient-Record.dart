import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/PateintModels/DentelRecord.dart';
import 'package:smart_dental_care_system/data/PateintModels/MedicalFile.dart';
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
  List<DentalRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _filteredRecords = dentalRecords;
  }

  void _runFilter(String enteredKeyword) {
    List<DentalRecord> results = [];
    if (enteredKeyword.isEmpty) {
      results = dentalRecords;
    } else {
      String query = enteredKeyword.toLowerCase();
      results = dentalRecords.where((record) {
        return record.doctorName.toLowerCase().contains(query) ||
               record.visitType.toLowerCase().contains(query) ||
               record.date.toLowerCase().contains(query) ||    
               record.status.toLowerCase().contains(query);    
      }).toList();
    }

    setState(() {
      _filteredRecords = results;
    });
  }

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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                      onChanged: (value) => _runFilter(value),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Search records...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                        filled: true,
                        fillColor: cardColor.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
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
                        _searchController.clear();
                        _runFilter('');
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
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), 
              itemCount: _filteredRecords.length,
              itemBuilder: (context, index) {
                return Center(
                  child: SizedBox(
                    width: 350,
                    child: RecordCard(_filteredRecords[index], context),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Attachments",
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicalfile.length,
              itemBuilder: (context, index) {
                return Center(
                  child: SizedBox(
                    width: 350, 
                    child: AttachmentCard(medicalfile[index])
                  ),
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
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitDetailsPage(visitDate: record.date),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record.date,
                    style: TextStyle(fontSize: 14, color: primaryBlue),
                  ),
                  Text(
                    record.status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: record.status.toLowerCase() == "completed"
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                record.doctorName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                record.visitType,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                record.notes,
                style: const TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget AttachmentCard(MedicalFile file) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: file.iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(file.icon, size: 24, color: file.iconColor),
      ),
      title: Text(
        file.fileName,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        file.date,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.visibility, color: Colors.white70),
        onPressed: () async {
          final Uri url = Uri.parse(file.fileUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            debugPrint("Could not launch $url");
          }
        },
      ),
    ),
  );
}