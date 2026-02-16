import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TreatmentPlan extends StatefulWidget {
  final String patientId;

  const TreatmentPlan({super.key, required this.patientId});

  @override
  State<TreatmentPlan> createState() => _TreatmentPlanState();
}

class _TreatmentPlanState extends State<TreatmentPlan> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color primaryBlue = const Color(0xFF2EC4FF);
  final Color cardColor = const Color(0xFF112B3C);

  List<Map<String, dynamic>> medications = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();
  List<Map<String, dynamic>> postVisitInstructions = [];
  String selectedHideDuration = "48 hours";
  final List<String> durationOptions = [
    "24 hours",
    "48 hours",
    "72 hours",
    "1 week",
  ];
  List<String> selectedTimes = [];

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: primaryBlue,
              onPrimary: bgColor,
              surface: cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedTimes.add(picked.format(context));
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Treatment Plan",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 15),
                child: Text(
                  "Add New medication ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Medication Name ",
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: bgColor.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: dosageController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Dosage (500mg)",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: bgColor.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: durationController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Days",
                              hintStyle: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: bgColor.withOpacity(0.4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: primaryBlue),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: primaryBlue,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Time",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: selectedTimes
                                  .map(
                                    (time) => Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Chip(
                                        backgroundColor: bgColor,
                                        label: Text(
                                          time,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        onDeleted: () => setState(
                                          () => selectedTimes.remove(time),
                                        ),
                                        deleteIconColor: Colors.redAccent,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            durationController.text.isNotEmpty) {
                          setState(() {
                            medications.add({
                              "name": nameController.text,
                              "dosage": dosageController.text,
                              "times": List.from(selectedTimes),
                              "duration": int.parse(durationController.text),
                              "startDate": DateTime.now(),
                            });
                            nameController.clear();
                            dosageController.clear();
                            durationController.clear();
                            selectedTimes.clear();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please enter medical information"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Add to Table",
                        style: TextStyle(
                          color: bgColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 15),
                child: Text(
                  "Current Treatment Table ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              _buildMedicationTable(),

              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 15),
                child: Text(
                  "Post-Visit Instructions ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ...postVisitInstructions.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var data = entry.value;

                      return Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: primaryBlue.withOpacity(0.2),
                              child: Text(
                                "${idx + 1}",
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['text'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        size: 12,
                                        color: Colors.white38,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Visible for ${data['duration']}",
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => postVisitInstructions.removeAt(idx),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add New Instruction",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 10),

                          // الصف الأول: حقل النص
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: TextField(
                              controller: instructionController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    "Enter instruction (e.g., Avoid hot beverages)",
                                hintStyle: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: bgColor.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),

                          // الصف الثاني: الدروب داون وزر الإضافة
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: bgColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedHideDuration,
                                    isExpanded: true,
                                    dropdownColor: cardColor,
                                    underline: SizedBox(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    items: durationOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(
                                      () => selectedHideDuration = val!,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  if (instructionController.text.isNotEmpty) {
                                    setState(() {
                                      postVisitInstructions.add({
                                        "text": instructionController.text,
                                        "duration": selectedHideDuration,
                                      });
                                      instructionController.clear();
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, color: bgColor, size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      "Add",
                                      style: TextStyle(
                                        color: bgColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
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
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,

                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF112B3C),
                    side: const BorderSide(color: Color(0xFF00D2FF), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

onPressed: () async {
  if (medications.isEmpty && postVisitInstructions.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Add at least one medication or instruction"),
      ),
    );
    return;
  }
  final medsData = medications.map((med) => {
        "name": med['name'],
        "dosage": med['dosage'],
        "times": List<String>.from(med['times']),
        "duration": med['duration'],
        "startDate": (med['startDate'] as DateTime),
        "taken": List<bool>.filled((med['times'] as List).length, false),
        "completionPercentage": 0.0,
      }).toList();
  final instData = postVisitInstructions.map((inst) => {
        "text": inst['text'],
        "duration": inst['duration'],
        "completed": false,
      }).toList();

  DateTime validUntilDate;
  if (medsData.isNotEmpty) {
    validUntilDate = medsData.map((m) {
      final start = m['startDate'] as DateTime;
      final days = m['duration'] as int;
      return start.add(Duration(days: days));
    }).reduce((a, b) => a.isAfter(b) ? a : b);
  } else {
    validUntilDate = DateTime.now().add(const Duration(days: 7));
  }
  try {
    await FirebaseFirestore.instance
        .collection('patient_treatments')
        .doc(widget.patientId)
        .set({
      'medications': medsData.map((m) {
        final map = Map<String, dynamic>.from(m);
        map['startDate'] = Timestamp.fromDate(map['startDate'] as DateTime);
        return map;
      }).toList(),
      'instructions': instData,
      'pushedAt': FieldValue.serverTimestamp(),
      'validUntil': Timestamp.fromDate(validUntilDate),
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
content: Text("Treatment plan sent to patient"),       
 backgroundColor: cardColor,
      ),
    );
    Navigator.of(context).pop();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("error : $e")),
    );
  }
},
                  icon: Icon(Icons.send, color: Colors.white),
                  label: Text(
                    "Push to Patient App",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildMedicationTable() {
  if (medications.isEmpty) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(Icons.medication_outlined, color: Colors.white24, size: 40),
          SizedBox(height: 10),
          Text(
            "No medications added yet",
            style: TextStyle(color: Colors.white24),
          ),
        ],
      ),
    );
  }

  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(15),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 50,
        dataRowMaxHeight: 80, 
        headingRowHeight: 45,
        headingRowColor: MaterialStateProperty.all(
          Colors.white.withOpacity(0.05),
        ),
        columnSpacing: 15, 
        columns: [
          DataColumn(label: Text("Med", style: TextStyle(color: primaryBlue))),
          DataColumn(label: Text("Dose", style: TextStyle(color: primaryBlue))),
          DataColumn(label: Text("Times", style: TextStyle(color: primaryBlue))),
          DataColumn(label: Text("End", style: TextStyle(color: primaryBlue))),
          DataColumn(label: Text("", style: TextStyle(color: primaryBlue))),
        ],
        rows: medications.asMap().entries.map((entry) {
          int index = entry.key;
          var med = entry.value;
          DateTime endDate = med['startDate'].add(
            Duration(days: med['duration']),
          );

          return DataRow(
            cells: [
              DataCell(
                Text(
                  med['name'],
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              DataCell(
                Text(
                  med['dosage'],
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              DataCell(
                Container(
                  width: 130, 
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (med['times'] as List).map((time) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.1),
                          border: Border.all(color: primaryBlue.withOpacity(0.3), width: 0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          time.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              DataCell(
                Text(
                  DateFormat('dd/MM').format(endDate),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              DataCell(
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent.withOpacity(0.8),
                    size: 18,
                  ),
                  onPressed: () => setState(() => medications.removeAt(index)),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}
}