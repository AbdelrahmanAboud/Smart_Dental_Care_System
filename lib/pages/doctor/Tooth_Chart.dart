import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/main.dart';

import '../../services/database_service.dart';

/// 🎨 Colors
final Color bgColor =     Color(0xFF0B1C2D);
final Color cardColor =   Color(0xFF112B3C);
final Color primaryBlue = Color(0xFF2EC4FF);
Color toothDefault = Color(0xFF1B263B);
Color cavity =  Color(0xFFFF4D6D);
Color filling = Color(0xFF00E5FF);
Color crown =   Color(0xFFFFC300);
Color healthy = Color(0xFF06D6A0);

/// 🦷 Tooth Chart Screen
class Toothchart extends StatefulWidget {
  final String patientId; // 1. ضيف السطر ده عشان يستلم الـ ID

  // 2. حدث الـ Constructor بالشكل ده
  const Toothchart({super.key, required this.patientId});

  @override
  State<Toothchart> createState() => _ToothchartState();
}

class _ToothchartState extends State<Toothchart> {
  // ... باقي كود الصفحة عندك ...

  int? selectedTooth;
  bool showNoteCard = false;
  bool showStatusCard = false;
  String status = "";
  final TextEditingController notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgColor,
    appBar:  AppBar(
       leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(
              context,
            ).pop();
          },
        ),
      backgroundColor: bgColor,
      elevation: 0,
      titleSpacing: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tooth Chart",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

        ],
      ),
    ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: DatabaseService().getTeethStream(widget.patientId),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                // كود لتحديث قائمة الـ teeth المحلية من بيانات فايربيز
                var data = snapshot.data!.data() as Map<String, dynamic>;
                if (data.containsKey('teeth_chart')) {
                  var chart = data['teeth_chart'] as Map<String, dynamic>;
                  chart.forEach((key, value) {
                    int index = int.parse(key) - 1;
                    teeth[index].status = value['status'];
                    teeth[index].notes = value['notes'];
                    teeth[index].isTreated = true;
                  });
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 28),
                    _buildTeethChart(),
                    buildStatusCard(),
                    buildNotesCard(),
                    buildRecentTreatments(),
                  ],
                ),
              );
            },
        ),
    );
  }

  /// 🦷 Header Card
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Text(
                "Tooth Chart",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                "Risk Score",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "Last Visit : Jan 15, 2026",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              const Text(
                "82",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🦷 Teeth Chart
  Widget _buildTeethChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text(
            "Teeth Chart",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "upper jaw",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: teeth
                  .take(16)
                  .map((t) => buildTooth(t, isUpperJaw: true))
                  .toList(),
            ),
          ),

          const SizedBox(height: 22),
          Text(
            "lower jaw",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: teeth
                  .skip(16)
                  .take(16)
                  .map((t) => buildTooth(t, isUpperJaw: false))
                  .toList(),
            ),
          ),
          SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Divider(color: Colors.grey, thickness: 1),
                 SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF4D6D),
                                  borderRadius: BorderRadius.circular(2),
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
                                    borderRadius: BorderRadius.circular(2),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFC300),
                                  borderRadius: BorderRadius.circular(2),
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
                                    borderRadius: BorderRadius.circular(2),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🦷 Single Tooth
  Widget buildTooth(ToothModel tooth, {bool isUpperJaw = true}) {
    Color toothColor = getToothColor(tooth);
    bool isSelected = selectedTooth == tooth.number;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTooth = tooth.number;
          showStatusCard = true;
          showNoteCard = false;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 25,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: toothColor,
              borderRadius: BorderRadius.only(
                topLeft: isUpperJaw ? Radius.circular(8) : Radius.zero,
                topRight: isUpperJaw ? Radius.circular(8) : Radius.zero,
                bottomLeft: !isUpperJaw ? Radius.circular(8) : Radius.zero,
                bottomRight: !isUpperJaw ? Radius.circular(8) : Radius.zero,
              ),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,

              boxShadow: tooth.isTreated
                  ? [
                      BoxShadow(
                        color: toothColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tooth.number.toString(),
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? primaryBlue : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Tooth Color
  Color getToothColor(ToothModel tooth) {
    if (!tooth.isTreated) return const Color(0xFF1E2D3D);

    switch (tooth.status) {
      case "cavity":
        return cavity;
      case "filling":
        return filling;
      case "crown":
        return crown;
      case "healthy":
        return healthy;
      default:
        return toothDefault;

    }
  }

  ///  Status Card
  Widget buildStatusCard() {
    if (!showStatusCard || selectedTooth == null) return const SizedBox();

    final tooth = teeth[selectedTooth! - 1];

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 0),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tooth #${tooth.number}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Mark tooth condition:",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                statusButton("cavity", cavity),
                statusButton("crown", crown),
                statusButton("filling", filling),
                statusButton("healthy", healthy),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!tooth.isTreated) return;
                setState(() {
                  status = tooth.status;
                  showStatusCard = false;
                  showNoteCard = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: tooth.isTreated
                    ? primaryBlue
                    : const Color(0xFF162A3D),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: tooth.isTreated ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget buildRecentTreatments() {
  final treatedTeeth = teeth
      .where((t) => t.isTreated)
      .toList()
      .reversed
      .toList();

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white10),
    ),

      child: ExpansionTile(
        iconColor: primaryBlue,
        shape: RoundedRectangleBorder(side: BorderSide.none),
collapsedShape: RoundedRectangleBorder(side: BorderSide.none),
        collapsedIconColor: Colors.white54,
        title: const Text(
          "Recent Treatments",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Icon(Icons.history, color: primaryBlue, size: 20),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (treatedTeeth.isEmpty)
                   Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "No treatments yet",
                        style: TextStyle(color: Colors.white38),
                      ),
                    ),
                  ),

                ...treatedTeeth.map((tooth) {
                  Color statusColor;
                  switch (tooth.status) {
                    case "cavity": statusColor = cavity; break;
                    case "crown": statusColor = crown; break;
                    case "filling": statusColor = filling; break;
                    case "healthy": statusColor = healthy; break;
                    default: statusColor = toothDefault;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Tooth #${tooth.number}  ",
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  TextSpan(
                                    text: tooth.status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            "Today",
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                          ),
                        ],
                      ),
                      if (tooth.notes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "note: ${tooth.notes}",
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                       Divider(color: Colors.white12, height: 20),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),

  );
}

  Widget buildNotesCard() {
    if (!showNoteCard || selectedTooth == null) return const SizedBox();

    final tooth = teeth[selectedTooth! - 1];
    notesController.text = tooth.notes;

    Color statusColor;
    switch (status) {
      case "cavity":
        statusColor = cavity;
        break;
      case "crown":
        statusColor = crown;
        break;
      case "filling":
        statusColor = filling;
        break;
      default:
        statusColor = healthy;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.25),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tooth #$selectedTooth",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add treatment notes...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              // ابحث عن GestureDetector بتاع Save Changes وغير الـ onTap
              onTap: () async {
                final user = widget.patientId;

                if (user == null) return;

                // 1. حفظ في فايربيز
                await DatabaseService().updateToothStatus(
                  patientId: widget.patientId, // أو الـ ID بتاع المريض لو اللي داخل دكتور
                  toothNumber: selectedTooth!,
                  status: status,
                  notes: notesController.text,
                );

                // 2. تحديث الـ UI المحلي (اختياري لأن الـ StreamBuilder هيحدثها أوتوماتيك)
                setState(() {
                  teeth[selectedTooth! - 1].notes = notesController.text;
                  teeth[selectedTooth! - 1].isTreated = true;
                  showNoteCard = false;
                });
              },
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget statusButton(String buttonStatus, Color color) {
    bool isSelected =
        teeth[selectedTooth! - 1].status == buttonStatus &&
        teeth[selectedTooth! - 1].isTreated;

    return GestureDetector(
      onTap: () {
        setState(() {
          teeth[selectedTooth! - 1].status = buttonStatus;
          teeth[selectedTooth! - 1].isTreated = true;
          status = buttonStatus;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          buttonStatus.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  
}

class ToothModel {
  final int number;
  String status;
  String notes;
  bool isTreated;

  ToothModel({
    required this.number,
    this.status = "healthy",
    this.notes = "",
    this.isTreated = false,
  });
}

List<ToothModel> teeth = List.generate(
  32,
  (index) => ToothModel(number: index + 1),
);
