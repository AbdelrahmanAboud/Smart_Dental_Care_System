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
