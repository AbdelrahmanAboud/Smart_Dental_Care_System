import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/pages/doctor/Tooth_Chart.dart';
import 'package:smart_dental_care_system/pages/doctor/Treatment_Plan.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient-Record.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class PatientClinicalView extends StatefulWidget {
  @override
  State<PatientClinicalView> createState() => _PatientClinicalViewState();
}

class _PatientClinicalViewState extends State<PatientClinicalView> {
  Color toothDefault = Color(0xFF1B263B);
  Color cavity = Color(0xFFFF4D6D);
  Color filling = Color(0xFF00E5FF);
  Color crown = Color(0xFFFFC300);
  Color healthy = Color(0xFF06D6A0);
  final List<Map<String, dynamic>> patientTeethData = [
    {"id": 1, "status": "none"},
    {"id": 2, "status": "none"},
    {"id": 3, "status": "healthy"},
    {"id": 4, "status": "none"},
    {"id": 5, "status": "none"},
    {"id": 6, "status": "filling"},
    {"id": 7, "status": "none"},
    {"id": 8, "status": "cavity"},
    {"id": 9, "status": "none"},
    {"id": 10, "status": "none"},
    {"id": 11, "status": "filling"},
    {"id": 12, "status": "none"},
    {"id": 13, "status": "none"},
    {"id": 14, "status": "crown"},
    {"id": 15, "status": "none"},
    {"id": 16, "status": "none"},
    {"id": 17, "status": "none"},
    {"id": 18, "status": "none"},
    {"id": 19, "status": "cavity"},
    {"id": 20, "status": "none"},
    {"id": 21, "status": "none"},
    {"id": 22, "status": "healthy"},
    {"id": 23, "status": "none"},
    {"id": 24, "status": "none"},
    {"id": 25, "status": "none"},
    {"id": 26, "status": "none"},
    {"id": 27, "status": "filling"},
    {"id": 28, "status": "none"},
    {"id": 29, "status": "none"},
    {"id": 30, "status": "crown"},
    {"id": 31, "status": "none"},
    {"id": 32, "status": "none"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          "Patient Profile",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryBlue.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            "lib/assets/profile.jpeg",
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text(
                        "3boooood",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "ID: 12345",
                        style: TextStyle(
                          color: primaryBlue.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.phone,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "0152345678",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.email,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 8),

                          Text(
                            "Aboud123456@gmail.com",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),
                    ],
                  ),
                ),
                SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        SizedBox(height: 20),

                        Text(
                          "Interactive Dental Chart",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 15),
                        Text(
                          "Upper Jaw",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 15),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < 16; i++)
                                Padding(
                                  padding:  EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Uppertooth(
                                    patientTeethData[i]["id"],
                                    patientTeethData[i]["status"],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),

                        Text(
                          "Low Jaw",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 16; i < 32; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: Lowertooth(
                                    patientTeethData[i]["id"],
                                    patientTeethData[i]["status"],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                         Divider(
                          color: Colors.white10,
                          indent: 10,
                          endIndent: 10,
                        ),
                        SizedBox(height: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFF4D6D),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Cavity",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 47.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF00E5FF),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Filling",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFC300),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Crown",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 40.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF06D6A0),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          "Healthy",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.only(left: 18.0, right: 18),
                          child: SizedBox(
                            width: double.infinity,

                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primaryBlue, width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Toothchart()));
                              },
                              child: Text(
                                "View Detailed Chart ",
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                        onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TreatmentPlan()));
                              },
                    child:  Text(
                      "Start New Treatment",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PatientRecord(),
                        ),
                      );
                    },
                    child: Text(
                      "View Records",
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget Uppertooth(int number, String status) {
  Color toothDefault = Color(0xFF1B263B);
  Color cavity = Color(0xFFFF4D6D);
  Color filling = Color(0xFF00E5FF);
  Color crown = Color(0xFFFFC300);
  Color healthy = Color(0xFF06D6A0);
  Color color = toothDefault;
  if (status == "cavity") {
    color = cavity;
  } else if (status == "filling") {
    color = filling;
  } else if (status == "crown") {
    color = crown;
  } else if (status == "healthy") {
    color = healthy;
  }
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          boxShadow: [
            if (color != toothDefault)
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
      ),
            SizedBox(height: 4),
      Text("$number", style: TextStyle(color: Colors.grey[600], fontSize: 10)),

    ],
  );
}

Widget Lowertooth(int number, String status) {
  Color toothDefault = Color(0xFF1B263B);
  Color cavity = Color(0xFFFF4D6D);
  Color filling = Color(0xFF00E5FF);
  Color crown = Color(0xFFFFC300);
  Color healthy = Color(0xFF06D6A0);
  Color color = toothDefault;

  if (status == "cavity") {
    color = cavity;
  } else if (status == "filling") {
    color = filling;
  } else if (status == "crown") {
    color = crown;
  } else if (status == "healthy") {
    color = healthy;
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 25,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10), 
            bottomRight: Radius.circular(10), 
          ),
          boxShadow: [
            if (color != toothDefault)
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
      ),
      SizedBox(height: 4),
      Text("$number", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
    ],
  );
}