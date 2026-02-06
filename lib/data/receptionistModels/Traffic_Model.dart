class PatientModel {
  final String name;
  final String doctor;
  final String appointmentTime;
  final String arrivedTime;
  final String status;
  final String? consultationStart;
  final String? consultationEnd;
  final double? patientRating;

  PatientModel({
    required this.name,
    required this.doctor,
    required this.appointmentTime,
    required this.arrivedTime,
    required this.status,
    this.consultationStart,
    this.consultationEnd,
    this.patientRating,
  });
}


List<PatientModel> fakePatients = [
  PatientModel(
    name: "Sarah Johnson",
    doctor: "Dr. Mitchell",
    appointmentTime: "9:00 AM",
    arrivedTime: "8:55 AM",
    status: "Done",
    consultationStart: "9:05 AM",
    consultationEnd: "9:30 AM",
    patientRating: 4.5,
  ),
  PatientModel(
    name: "Michael Chen",
    doctor: "Dr. Chen",
    appointmentTime: "10:00 AM",
    arrivedTime: "9:50 AM",
    status: "With Doctor",
    consultationStart: "10:05 AM",
    consultationEnd: "10:25 AM",
    patientRating: 4.0,
  ),
  PatientModel(
    name: "Emma Williams",
    doctor: "Dr. Mitchell",
    appointmentTime: "11:30 AM",
    arrivedTime: "11:25 AM",
    status: "Waiting",
    patientRating: null,
  ),
  PatientModel(
    name: "James Brown",
    doctor: "Dr. Lee",
    appointmentTime: "2:00 PM",
    arrivedTime: "1:55 PM",
    status: "Arrived",
    patientRating: null,
  ),
  PatientModel(
    name: "Lisa Davis",
    doctor: "Dr. Mitchell",
    appointmentTime: "3:30 PM",
    arrivedTime: "3:28 PM",
    status: "Arrived",
    patientRating: null,
  ),
];