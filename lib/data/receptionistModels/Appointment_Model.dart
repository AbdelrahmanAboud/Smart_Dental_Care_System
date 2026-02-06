class AppointmentModel {
  final String patientName;
  final String treatmentType;
  final String appointmentTime;
  final String status;

  AppointmentModel({
    required this.patientName,
    required this.treatmentType,
    required this.appointmentTime,
    required this.status,
  });
}
List<AppointmentModel> appointmentList = [
  AppointmentModel(
    patientName: "Abdo Aboud",
    treatmentType: "Root Canal Surgery",
    appointmentTime: "09:00 AM",
    status: "confirmed",
  ),
  AppointmentModel(
    patientName: "Sarah Mansour",
    treatmentType: "Teeth Whitening",
    appointmentTime: "10:15 AM",
    status: "confirmed",
  ),
  AppointmentModel(
    patientName: "Omar Hassan",
    treatmentType: "Dental Implants",
    appointmentTime: "11:30 AM",
    status: "waiting",
  ),
  AppointmentModel(
    patientName: "Mariam Ali",
    treatmentType: "Regular Checkup",
    appointmentTime: "01:00 PM",
    status: "confirmed",
  ),
  AppointmentModel(
    patientName: "Khaled Yehia",
    treatmentType: "Orthodontic Adjustment",
    appointmentTime: "02:15 PM",
    status: "pending",
  ),
  AppointmentModel(
    patientName: "Laila Ibrahim",
    treatmentType: "Scaling & Polishing",
    appointmentTime: "03:30 PM",
    status: "confirmed",
  ),
  AppointmentModel(
    patientName: "Youssef Zaid",
    treatmentType: "Tooth Extraction",
    appointmentTime: "04:45 PM",
    status: "waiting",
  ),
  AppointmentModel(
    patientName: "Nour El-Din",
    treatmentType: "Composite Filling",
    appointmentTime: "06:00 PM",
    status: "confirmed",
  ),
  AppointmentModel(
    patientName: "Hanaa Selim",
    treatmentType: "Bridge Installation",
    appointmentTime: "07:15 PM",
    status: "pending",
  ),
  AppointmentModel(
    patientName: "Mostafa Gad",
    treatmentType: "Emergency Pain",
    appointmentTime: "08:30 PM",
    status: "confirmed",
  ),
];