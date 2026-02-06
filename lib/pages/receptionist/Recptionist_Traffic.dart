import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smart_dental_care_system/data/receptionistModels/Traffic_Model.dart';

class ClinicTraffic extends StatefulWidget {
  @override
  State<ClinicTraffic> createState() => _ClinicTrafficState();
}

final Color bgColor = Color(0xFF0B1C2D);
final Color cardColor = Color(0xFF0F2235);
final Color primaryBlue = Color(0xFF2EC4FF);

class _ClinicTrafficState extends State<ClinicTraffic> {
  int get totalPatients => fakePatients.length;

  int get completedPatients =>
      fakePatients.where((p) => p.status == "Done").length;

  int get waitingPatients =>
      fakePatients.where((p) => p.status == "Waiting").length;

  int get withDoctorPatients =>
      fakePatients.where((p) => p.status == "With Doctor").length;

  int get arrivedPatients =>
      fakePatients.where((p) => p.status == "Arrived").length;

  int get activePatients =>
      fakePatients.where((p) => p.status != "Done").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Clinic Traffic",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 13.0),
            child: IconButton(
              iconSize: 28,
              icon: Icon(Icons.notifications_none, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.cyan.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Patients Today",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    totalPatients.toString(),
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${completedPatients} completed",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("•", style: TextStyle(color: Colors.white38)),
                      const SizedBox(width: 8),
                      Text(
                        "${activePatients} active",
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                clincTraffic(
                  icon: Icons.person,
                  iconColor: Color(0xFFFFD223),
                  value: arrivedPatients.toString(),
                  title: "Arrived ",
                ),

                clincTraffic(
                  icon: FontAwesomeIcons.clock,
                  iconColor: Color(0xFF4CAF50),
                  value: waitingPatients.toString(),
                  title: "Waiting ",
                ),
                clincTraffic(
                  icon: FontAwesomeIcons.userDoctor,
                  iconColor: primaryBlue,
                  value: withDoctorPatients.toString(),
                  title: "With Doctor ",
                ),
                clincTraffic(
                  icon: FontAwesomeIcons.checkCircle,
                  iconColor: Color(0xFF00EFB2),
                  value: completedPatients.toString(),
                  title: "Completed ",
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: fakePatients.length,
              itemBuilder: (context, index) {
                final patient = fakePatients[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white10),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.3),
                  color: cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: getPatientIcon(patient.status),
                    ),

                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          patient.status,
                          style: TextStyle(
                            fontSize: 14,
                            color: getStatusColor(patient.status),
                          ),
                        ),
                      ],
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.doctor,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Appt: ${patient.appointmentTime}  Arrived: ${patient.arrivedTime}",
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 4),
                        getStatusText(patient.status),
                        const SizedBox(height: 4),

                        if (patient.status == 'Waiting') ...[
                          Divider(
                            color: Colors.white38,
                            thickness: 1,
                            height: 1,
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('Notify Doctor'),
                            ),
                          ),
                        ] else if (patient.status == 'Arrived') ...[
                          Divider(
                            color: Colors.white38,
                            thickness: 1,
                            height: 1,
                          ),
                          SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,

                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text('Complete Check-in'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            patientJourneyFlow(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Performance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Builder(
                    builder: (context) {
                      double wait = avgWaitTime(fakePatients);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Avg Wait Time",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "${wait.toStringAsFixed(0)} min",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  Builder(
                    builder: (context) {
                      double consult = avgConsultationTime(fakePatients);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Avg Consultation",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "${consult.toStringAsFixed(0)} min",
                            style: const TextStyle(
                              color: Color(0xFF2EC4FF),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  Builder(
                    builder: (context) {
                      double satisfaction = avgPatientSatisfaction(
                        fakePatients,
                      );
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Patient Satisfaction",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "${satisfaction.toStringAsFixed(1)}/5.0",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget patientJourneyFlow() {
    final data = getPatientCounts();
    final colors = {
      "Arrived": Colors.orangeAccent,
      "Waiting": Colors.teal,
      "With Doctor": Colors.blue,
      "Done": Colors.greenAccent,
    };

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Patient Journey Flow",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.keys.map((status) {
              return Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colors[status],
                    child: Text(
                      data[status].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    status,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

Map<String, int> getPatientCounts() {
  return {
    "Arrived": fakePatients.where((p) => p.status == "Arrived").length,
    "Waiting": fakePatients.where((p) => p.status == "Waiting").length,
    "With Doctor": fakePatients.where((p) => p.status == "With Doctor").length,
    "Done": fakePatients.where((p) => p.status == "Done").length,
  };
}

class clincTraffic extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;

  const clincTraffic({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2235),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(1.2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2235),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'Done':
      return Colors.green;
    case 'With Doctor':
      return Colors.blue;
    case 'Waiting':
      return Colors.teal;
    case 'Arrived':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

Text getStatusText(String status) {
  String message;
  Color color;

  switch (status) {
    case 'Done':
      message = "Completed";
      color = Colors.green;
      break;
    case 'With Doctor':
      message = "in consultation";
      color = Colors.blue;
      break;
    case 'Waiting':
      message = "in waiting room";
      color = Colors.teal;
      break;
    case 'Arrived':
      message = "check-in pending";
      color = Colors.orange;
      break;
    default:
      message = "Unknown";
      color = Colors.grey;
  }

  return Text(
    message,
    style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w500),
  );
}

Widget getPatientIcon(String status) {
  switch (status) {
    case 'Done':
      return Icon(
        FontAwesomeIcons.checkCircle,
        color: Colors.greenAccent,
        size: 28,
      );
    case 'With Doctor':
      return Icon(FontAwesomeIcons.userDoctor, color: primaryBlue, size: 28);
    case 'Waiting':
      return Icon(FontAwesomeIcons.clock, color: Colors.teal, size: 28);
    case 'Arrived':
      return Icon(Icons.person, color: Colors.amber, size: 28);
    default:
      return Icon(Icons.person, color: Colors.white, size: 28);
  }
}

Duration calculateWaitTime(PatientModel patient) {
  final format = DateFormat("h:mm a");
  final appointment = format.parse(patient.appointmentTime);
  final arrived = format.parse(patient.arrivedTime);
  return arrived.isAfter(appointment)
      ? Duration.zero
      : appointment.difference(arrived);
}

Duration calculateConsultationTime(PatientModel patient) {
  if (patient.consultationStart == null || patient.consultationEnd == null) {
    return Duration.zero;
  }
  try {
    final format = DateFormat("h:mm a");
    final start = format.parse(patient.consultationStart!);
    final end = format.parse(patient.consultationEnd!);
    return end.difference(start);
  } catch (e) {
    print("Error parsing consultation time for ${patient.name}: $e");
    return Duration.zero;
  }
}

double avgWaitTime(List<PatientModel> fakePatients) => fakePatients.isEmpty
    ? 0
    : fakePatients
              .map((p) => calculateWaitTime(p).inMinutes)
              .reduce((a, b) => a + b) /
          fakePatients.length;

double avgConsultationTime(List<PatientModel> fakePatients) =>
    fakePatients.isEmpty
    ? 0
    : fakePatients
              .map((p) => calculateConsultationTime(p).inMinutes)
              .reduce((a, b) => a + b) /
          fakePatients.length;

double avgPatientSatisfaction(List<PatientModel> fakePatients) {
  final ratings = fakePatients
      .where((p) => p.patientRating != null)
      .map((p) => p.patientRating!)
      .toList();
  if (ratings.isEmpty) return 0;
  return ratings.reduce((a, b) => a + b) / ratings.length;
}
