import 'package:flutter/material.dart';

class MedicalFile {
  final String fileName;
  final String date;
  final String fileUrl;
  final IconData icon;
  final Color iconColor;

  MedicalFile({
    required this.fileName,
    required this.date,
    required this.fileUrl,
    required this.icon,
    required this.iconColor,
  });
}

final List<MedicalFile> medicalfile = [
  MedicalFile(
    fileName: "Full Mouth X-Ray 2023.pdf",
    date: "Oct 26, 2023",
    fileUrl:
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    icon: Icons.image_outlined,
    iconColor: Colors.cyanAccent,
  ),
  MedicalFile(
    fileName: "Treatment Plan Details.docx",
    date: "Aug 15, 2023",
    fileUrl: "https://www.africau.edu/images/default/sample.pdf",
    icon: Icons.description_outlined,
    iconColor: Colors.cyan,
  ),
  MedicalFile(
    fileName: "Upper Molar Filling.jpg",
    date: "Aug 15, 2023",
    fileUrl:
        "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    icon: Icons.image_outlined,
    iconColor: Colors.cyanAccent,
  ),
  MedicalFile(
    fileName: "Post-Visit Instructions.pdf",
    date: "Oct 26, 2023",
    fileUrl: "https://www.africau.edu/images/default/sample.pdf",
    icon: Icons.description_outlined,
    iconColor: Colors.cyan,
  ),
];
