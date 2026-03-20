class PatientAppointment {
  final String uid;
  final String name;
  final String status;
  final String treatment; 
  final String time;
  final int riskScore;

  PatientAppointment({
    required this.uid,
    required this.name,
    required this.status,
    required this.treatment,
    required this.time,
    required this.riskScore,
  });
}