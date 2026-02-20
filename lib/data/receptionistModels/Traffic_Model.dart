import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  final String id;
  final String name;
  final String status;
  final String doctor;
  final String appointmentTime;
  final DateTime? arrivedTime;
  final DateTime? consultationStart;
  final DateTime? consultationEnd;
  final double? patientRating;

  PatientModel({
    required this.id,
    required this.name,
    required this.status,
    required this.doctor,
    required this.appointmentTime,
    this.arrivedTime,
    this.consultationStart,
    this.consultationEnd,
    this.patientRating,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map, String documentId) {
    // دالة داخلية لتحويل الـ Timestamp لـ DateTime بأمان
    DateTime? parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return PatientModel(
      id: documentId,
      name: map['name'] ?? '',
      status: map['status'] ?? '',
      doctor: map['doctor'] ?? '',
      appointmentTime: map['appointmentTime'] ?? '',
      // استخدام parseDateTime لكل حقول الوقت
      arrivedTime: parseDateTime(map['arrivedTime']),
      consultationStart: parseDateTime(map['startTime']),
      consultationEnd: parseDateTime(map['endTime']),
      // تحويل التقييم لرقم عشري بأمان
      patientRating: (map['patientRating'] as num?)?.toDouble(),
    );
  }
}