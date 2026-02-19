import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController visitTypeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  Future<String?> uploadToCloudinary(File file) async {
    String cloudName = "ddrjzbrwp";
    String uploadPreset = "Smart Dental Care System";

    var uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
    );
    var request = http.MultipartRequest("POST", uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    request.fields['upload_preset'] = uploadPreset;

    request.fields['flags'] = 'attachment';

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);
      var jsonResponse = jsonDecode(responseString);
      return jsonResponse['secure_url'];
    } else {
      print("Cloudinary Error: ${response.statusCode}");
    }
    return null;
  }

  File? _selectedFile;
  final ImagePicker _picker = ImagePicker();

  String visitStatus = "Completed";

  String doctorName = "";

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
              SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 15),
                child: Text(
                  "Visit Details",
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
                      controller: visitTypeController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Visit Type (Cleaning, Filling...)",
                        hintStyle: TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: bgColor.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Doctor Notes about this visit...",
                        hintStyle: TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: bgColor.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Attachments",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              FilePickerResult? result = await FilePicker
                                  .platform
                                  .pickFiles(type: FileType.any);

                              if (result != null &&
                                  result.files.single.path != null) {
                                setState(() {
                                  _selectedFile = File(
                                    result.files.single.path!,
                                  );
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: cardColor.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: primaryBlue.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: _selectedFile == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_file_rounded,
                                          color: primaryBlue,
                                          size: 40,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Click to add file or document",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          [
                                                'jpg',
                                                'jpeg',
                                                'png',
                                                'gif',
                                                'webp',
                                              ].contains(
                                                _selectedFile!.path
                                                    .split('.')
                                                    .last
                                                    .toLowerCase(),
                                              )
                                              ? Image.file(
                                                  _selectedFile!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  color: Colors.black26,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.description,
                                                        color: Colors.white70,
                                                        size: 40,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                            ),
                                                        child: Text(
                                                          _selectedFile!.path
                                                              .split('/')
                                                              .last,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                          Positioned(
                                            right: 8,
                                            top: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedFile = null;
                                                });
                                              },
                                              child: const CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.red,
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: visitStatus,
                      dropdownColor: cardColor,
                      items: ["Completed", "Pending"]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => visitStatus = val!),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: bgColor.withOpacity(0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),

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
                            keyboardType: TextInputType.number,

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

              SizedBox(height: 15),
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
                          content: Text(
                            "Add at least one medication or instruction",
                          ),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      ),
                    );

                    try {
                      String formattedDate = DateFormat(
                        'MMM dd, yyyy',
                      ).format(DateTime.now());
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final doctorName = currentUser?.displayName ?? "Doctor";
                      String? fileUrl;

                      if (_selectedFile != null) {
                        fileUrl = await uploadToCloudinary(_selectedFile!);
                      }

                      final batch = FirebaseFirestore.instance.batch();

                      final medsData = medications
                          .map(
                            (med) => {
                              'name': med['name'],
                              'dosage': med['dosage'],
                              'times': med['times'],
                              'duration': med['duration'],
                              'startDate': med['startDate'],
                            },
                          )
                          .toList();

                      final instData = postVisitInstructions
                          .map(
                            (inst) => {
                              'text': inst['text'],
                              'duration': inst['duration'],
                            },
                          )
                          .toList();

                      final treatmentRef = FirebaseFirestore.instance
                          .collection('patient_treatments')
                          .doc(widget.patientId);

                      batch.set(treatmentRef, {
                        'medications': medsData,
                        'instructions': instData,
                        'pushedAt': FieldValue.serverTimestamp(),
                      });

                      final historyRef = FirebaseFirestore.instance
                          .collection('patient_records')
                          .doc(widget.patientId)
                          .collection('visits')
                          .doc();

                      batch.set(historyRef, {
                        'doctorName': doctorName,
                        'date': DateFormat(
                          'MMM dd, yyyy',
                        ).format(DateTime.now()),
                        'status': visitStatus,
                        'notes': notesController.text.trim(),
                        'visitType': visitTypeController.text.trim(),
                        'attachmentUrl': _selectedFile != null
                            ? await uploadToCloudinary(_selectedFile!)
                            : null,
                        'attachmentName': _selectedFile != null
                            ? _selectedFile!.path.split('/').last
                            : null,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      await batch.commit();

                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Visit recorded successfully!"),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      if (context.mounted)
                        Navigator.of(context, rootNavigator: true).pop();

                      print("Error during saving: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
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
            DataColumn(
              label: Text("Med", style: TextStyle(color: primaryBlue)),
            ),
            DataColumn(
              label: Text("Dose", style: TextStyle(color: primaryBlue)),
            ),
            DataColumn(
              label: Text("Times", style: TextStyle(color: primaryBlue)),
            ),
            DataColumn(
              label: Text("End", style: TextStyle(color: primaryBlue)),
            ),
            DataColumn(
              label: Text("", style: TextStyle(color: primaryBlue)),
            ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            border: Border.all(
                              color: primaryBlue.withOpacity(0.3),
                              width: 0.5,
                            ),
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
                    onPressed: () =>
                        setState(() => medications.removeAt(index)),
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
