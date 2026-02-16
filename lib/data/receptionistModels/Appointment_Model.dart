class AppointmentModel {
  final String uid;
  final String patientName;
  final String treatmentType;
  final String appointmentTime;
  final String status;

  AppointmentModel({
    required this.uid,
    required this.patientName,
    required this.treatmentType,
    required this.appointmentTime,
    required this.status,
  });
}
