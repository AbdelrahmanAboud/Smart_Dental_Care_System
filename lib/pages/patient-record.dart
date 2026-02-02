import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/data/DentelRecord.dart';
import 'package:smart_dental_care_system/data/MedicalFile.dart';
import 'package:smart_dental_care_system/pages/register.dart';
import 'package:smart_dental_care_system/pages/visit_details_Page.dart';
import 'package:url_launcher/url_launcher.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);


class PatientRecord extends StatefulWidget {
  @override
  State<PatientRecord> createState() => _PatientRrecordState();
}

class _PatientRrecordState extends State<PatientRecord> {
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text(
              "Medical Record",
              style: TextStyle(color: Colors.white, fontSize: 20),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Register()));
          },
        ),
      
        
      
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(thickness: 1.5, color: Colors.black),

          Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: "Search records...",
                      labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: cardColor, width: 2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    width: 48,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const FaIcon(
                        FontAwesomeIcons.magnifyingGlass,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              "Visit History",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: dentalRecords.length,
              itemBuilder: (context, index) {
                final record = dentalRecords[index];
                return Center(
                  child: SizedBox(width: 350, child: RecordCard(record, context)),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              "Attachments",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: medicalfile.length,
              itemBuilder: (context, index) {
                final file = medicalfile[index];
                return Center(
                  // لضمان بقاء الكارد في المنتصف إذا كان عرض الشاشة أكبر من 350
                  child: SizedBox(width: 350, child: AttachmentCard(file)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget RecordCard(DentalRecord record, BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(left: 20.0, right: 20),
    child: GestureDetector(
     onTap: () {
        // الانتقال لصفحة التفاصيل وتمرير التاريخ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VisitDetailsPage(visitDate: record.date),
          ),
        );
        },
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
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
      
                        color: record.status.toLowerCase() == "completed"
                            ? Color(0xFF00E676)
                            : Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  record.doctorName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  record.visitType,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  record.notes,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget AttachmentCard(MedicalFile file) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Icon(file.icon, size: 24, color: file.iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.fileName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file.date,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
             onPressed: () async {
    final Uri url = Uri.parse(file.fileUrl);
    
    // محاولة فتح الرابط
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
       // لو الرابط فيه مشكلة، هيطبع لك في الكونسول
       debugPrint("Could not launch $url");
    }
  },
              icon: const Icon(Icons.visibility, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

