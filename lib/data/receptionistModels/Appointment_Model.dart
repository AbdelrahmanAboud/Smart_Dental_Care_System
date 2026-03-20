import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String uid;
  final String patientName;
  final String treatmentType;
  final String appointmentTime;
  final String status;
  final String doctorName; 

  AppointmentModel({
    required this.uid,
    required this.patientName,
    required this.treatmentType,
    required this.appointmentTime,
    required this.status,
    required this.doctorName, 
  });
  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      uid: doc.id,
      patientName: data['patientName'] ?? 'No Name',
      treatmentType: data['type'] ?? data['treatmentType'] ?? 'General Consultation', 
      appointmentTime: data['slot'] ?? data['time'] ?? '--:--',
      status: data['status'] ?? 'pending',
      doctorName: data['doctorName'] ?? 'No Doctor',
    );
  }

}

