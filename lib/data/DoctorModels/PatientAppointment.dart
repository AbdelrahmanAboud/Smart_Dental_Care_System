class PatientAppointment {
  final String name;
  final String treatment;
  final String time;
  final int riskScore;
  final String status; // waiting, In Progress, Completed

  PatientAppointment({
    required this.name,
    required this.treatment,
    required this.time,
    required this.riskScore,
    required this.status,
  });
}

final List<PatientAppointment> appointments = [
  PatientAppointment(name: "Sarah Johnson", treatment: "Regular Checkup", time: "9:00 AM", riskScore: 82, status: "waiting"),
  PatientAppointment(name: "Michael Chen", treatment: "Root Canal", time: "10:00 AM", riskScore: 65, status: "In Progress"),
  PatientAppointment(name: "Emma Williams", treatment: "Teeth Cleaning", time: "11:30 AM", riskScore: 91, status: "waiting"),
  PatientAppointment(name: "James Brown", treatment: "Cavity Filling", time: "2:00 PM", riskScore: 58, status: "waiting"),
  PatientAppointment(name: "Olivia Taylor", treatment: "Braces Adjustment", time: "3:00 PM", riskScore: 70, status: "waiting"),
  PatientAppointment(name: "Ahmed Ali", treatment: "Tooth Extraction", time: "4:30 PM", riskScore: 95, status: "waiting"),
  PatientAppointment(name: "Sophia Miller", treatment: "Whitening Session", time: "5:15 PM", riskScore: 40, status: "waiting"),
  PatientAppointment(name: "Robert Wilson", treatment: "Crown Installation", time: "6:00 PM", riskScore: 77, status: "waiting"),
  PatientAppointment(name: "Nour El-Din", treatment: "Gingivitis Treatment", time: "7:00 PM", riskScore: 88, status: "waiting"),
  PatientAppointment(name: "Olivia Taylor", treatment: "Implant Consult", time: "8:00 PM", riskScore: 62, status: "waiting"),
];

