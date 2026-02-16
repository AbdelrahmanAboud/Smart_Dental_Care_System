import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientTreatmentPage extends StatefulWidget {
  final String? patientUid;

  final List<Map<String, dynamic>>? medications;
  final List<Map<String, dynamic>>? instructions;

  PatientTreatmentPage({this.patientUid, this.medications, this.instructions});

  @override
  _PatientTreatmentPageState createState() => _PatientTreatmentPageState();
}

class _PatientTreatmentPageState extends State<PatientTreatmentPage> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color primaryBlue = const Color.fromARGB(255, 30, 91, 115);
  final Color cardColor = const Color(0xFF112B3C);

  List<Map<String, dynamic>>? _loadedMedications;
  List<Map<String, dynamic>>? _loadedInstructions;
  bool _isLoading = true;
  bool _hasNoData = false;

  List<Map<String, dynamic>> get _effectiveMedications =>
      _loadedMedications ?? _effectiveMedications ?? [];
  List<Map<String, dynamic>> get _effectiveInstructions =>
      _loadedInstructions ?? _effectiveInstructions ?? [];

  static int _instructionDurationDays(String? duration) {
    if (duration == null) return 7;
    final d = duration.toLowerCase();
    if (d.contains('24') || d == '24 hours') return 1;
    if (d.contains('48')) return 2;
    if (d.contains('72')) return 3;
    if (d.contains('week') || d.contains('1 week')) return 7;
    return 7;
  }

  @override
  void initState() {
    super.initState();
    if (widget.patientUid != null) {
      _loadFromFirestore();
      return;
    }
    _isLoading = false;
    final meds = _effectiveMedications ?? [];
    final inst = _effectiveInstructions ?? [];
    for (var med in meds) {
      if (!med.containsKey('taken')) {
        med['taken'] = List<bool>.filled((med['times'] as List).length, false);
      }
      if (!med.containsKey('completionPercentage')) {
        med['completionPercentage'] = 0.0;
      }
    }
    for (var inst in inst) {
      if (!inst.containsKey('completed')) inst['completed'] = false;
    }
  }

  Future<void> _loadFromFirestore() async {
    final uid = widget.patientUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasNoData = true;
      });
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('patient_treatments')
        .doc(uid)
        .get();
    if (!mounted) return;
    if (!doc.exists) {
      setState(() {
        _isLoading = false;
        _hasNoData = true;
      });
      return;
    }
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final pushedAt = data['pushedAt'] is Timestamp
        ? (data['pushedAt'] as Timestamp).toDate()
        : DateTime.now();
    final now = DateTime.now();

    final medsRaw = data['medications'] as List<dynamic>? ?? [];
    final instRaw = data['instructions'] as List<dynamic>? ?? [];

    final allMeds = medsRaw.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      if (map['startDate'] is Timestamp) {
        map['startDate'] = (map['startDate'] as Timestamp).toDate();
      }
      if (!map.containsKey('taken') && map['times'] != null) {
        map['taken'] = List<bool>.filled((map['times'] as List).length, false);
      }
      if (!map.containsKey('completionPercentage')) {
        map['completionPercentage'] = 0.0;
      }
      return map;
    }).toList();

    final activeMeds = allMeds.where((med) {
      final start = med['startDate'] as DateTime?;
      final days = med['duration'] is int ? med['duration'] as int : 0;
      if (start == null) return true;
      final endDate = start.add(Duration(days: days));
      return now.isBefore(endDate);
    }).toList();

    final allInst = instRaw.map((i) {
      final map = Map<String, dynamic>.from(i as Map);
      if (!map.containsKey('completed')) map['completed'] = false;
      return map;
    }).toList();

    final activeInst = allInst.where((inst) {
      final days = _instructionDurationDays(inst['duration'] as String?);
      final endDate = pushedAt.add(Duration(days: days));
      return now.isBefore(endDate);
    }).toList();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (activeMeds.isEmpty && activeInst.isEmpty) {
        _hasNoData = true;
      } else {
        _loadedMedications = activeMeds;
        _loadedInstructions = activeInst;
      }
    });
  }

  Future<void> _saveProgressToFirestore() async {
    final uid = widget.patientUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final medsForFirestore = _effectiveMedications.map((m) {
        final map = Map<String, dynamic>.from(m);
        if (map['startDate'] is DateTime) {
          map['startDate'] = Timestamp.fromDate(map['startDate'] as DateTime);
        }
        return map;
      }).toList();
      await FirebaseFirestore.instance
          .collection('patient_treatments')
          .doc(uid)
          .update({
            'medications': medsForFirestore,
            'instructions': _effectiveInstructions,
          });
    } catch (_) {}
  }

  double get overallProgress {
    if (_effectiveMedications.isEmpty && _effectiveInstructions.isEmpty)
      return 0.0;
    double medProgress = 0.0;
    double instProgress = 0.0;
    if (_effectiveMedications.isNotEmpty) {
      for (var med in _effectiveMedications) {
        List<bool> takenList = List<bool>.from(med['taken']);
        int takenCount = takenList.where((t) => t).length;
        med['completionPercentage'] = takenList.isEmpty
            ? 0.0
            : (takenCount / takenList.length);
        medProgress += med['completionPercentage'];
      }
      medProgress = medProgress / _effectiveMedications.length;
    }
    if (_effectiveInstructions.isNotEmpty) {
      int completedInst = _effectiveInstructions
          .where((inst) => inst['completed'] == true)
          .length;
      instProgress = completedInst / _effectiveInstructions.length;
    }
    if (_effectiveMedications.isEmpty) return instProgress;
    if (_effectiveInstructions.isEmpty) return medProgress;
    return (medProgress + instProgress) / 2;
  }

  Map<String, int> get todayMedicationStats {
    int takenCount = 0;
    int totalCount = 0;
    for (var med in _effectiveMedications) {
      List<bool> takenList = List<bool>.from(med['taken']);
      takenCount += takenList.where((t) => t).length;
      totalCount += takenList.length;
    }
    return {'taken': takenCount, 'total': totalCount};
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Treatment Progress",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: primaryBlue)),
      );
    }
    if (_hasNoData) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "My Treatment",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 64,
                  color: Colors.white24,
                ),
                SizedBox(height: 16),
                Text(
                  "No active treatment plan at the moment",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    var medStats = todayMedicationStats;
    int takenToday = medStats['taken']!;
    int totalToday = medStats['total']!;
    double progress = overallProgress;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Treatment Progress",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardColor, cardColor.withOpacity(0.8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Treatment Progress",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}% Complete",
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 8,
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryBlue,
                              ),
                            ),
                          ),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        _effectiveMedications.length.toString(),
                        "Medications",
                        Icons.medication,
                        primaryBlue,
                      ),
                      _buildStatItem(
                        "${takenToday}/${totalToday}",
                        "Taken Today",
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        _effectiveInstructions.length.toString(),
                        "Instructions",
                        Icons.info,
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            if (_effectiveMedications.isNotEmpty)
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Medications",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medication,
                                color: primaryBlue,
                                size: 14,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "$takenToday / $totalToday taken",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Column(
                      children: _effectiveMedications.map((med) {
                        List<String> times = List<String>.from(med['times']);
                        List<bool> taken = List<bool>.from(med['taken']);
                        double medProgress = med['completionPercentage'];

                        return Container(
                          margin: EdgeInsets.only(bottom: 15),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: bgColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.medication_liquid,
                                      color: primaryBlue,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          med['name'],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          med['dosage'],
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          value: medProgress,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.white12,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                medProgress >= 1.0
                                                    ? Colors.green
                                                    : primaryBlue,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        "${(medProgress * 100).toStringAsFixed(0)}%",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: Colors.white60,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Duration: ${med['duration']} days",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Icon(
                                    Icons.timer,
                                    size: 12,
                                    color: Colors.white60,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${times.length} times daily",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Dosage Times:",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 8),

                              Center(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,

                                  children: times.asMap().entries.map((
                                    timeEntry,
                                  ) {
                                    int timeIndex = timeEntry.key;
                                    String time = timeEntry.value;
                                    bool isTaken = taken[timeIndex];

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          taken[timeIndex] = !isTaken;
                                          med['taken'] = taken;

                                          int takenCount = taken
                                              .where((t) => t)
                                              .length;
                                          med['completionPercentage'] =
                                              takenCount / taken.length;
                                        });
                                        _saveProgressToFirestore();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isTaken
                                              ? Colors.green.withOpacity(0.3)
                                              : primaryBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isTaken
                                                ? Colors.green
                                                : primaryBlue.withOpacity(0.1),
                                            width: 1.5,
                                          ),
                                          boxShadow: isTaken
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.green
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isTaken
                                                  ? Icons.check_circle
                                                  : Icons.access_time,
                                              color: isTaken
                                                  ? Colors.green
                                                  : Colors.white70,
                                              size: 14,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              time,
                                              style: TextStyle(
                                                color: isTaken
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontSize: 12,
                                                fontWeight: isTaken
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 20),

            if (_effectiveInstructions.isNotEmpty)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: primaryBlue),
                        SizedBox(width: 10),
                        Text(
                          "Doctor's Instructions",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "${_effectiveInstructions.where((inst) => inst['completed'] == true).length}/${_effectiveInstructions.length}",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    ..._effectiveInstructions.asMap().entries.map((entry) {
                      int index = entry.key;
                      var instruction = entry.value;
                      bool isCompleted = instruction['completed'] == true;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            instruction['completed'] = !isCompleted;
                          });
                          _saveProgressToFirestore();
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.1)
                                : bgColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 1,
                            ),
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green.withOpacity(0.2)
                                      : primaryBlue.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : Icons.info,
                                  color: isCompleted
                                      ? Colors.green
                                      : primaryBlue,
                                  size: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            instruction['text'],
                                            style: TextStyle(
                                              color: isCompleted
                                                  ? Colors.green
                                                  : Colors.white,
                                              fontSize: 13,
                                              decoration: isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (isCompleted)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.timer,
                                          size: 12,
                                          color: Colors.white60,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          "Duration: ${instruction['duration']}",
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Spacer(),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? Colors.green.withOpacity(0.2)
                                                : primaryBlue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            isCompleted
                                                ? "Completed"
                                                : "Tap to mark",
                                            style: TextStyle(
                                              color: isCompleted
                                                  ? Colors.green
                                                  : primaryBlue,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                      );
                    }).toList(),

                    SizedBox(height: 10),

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Instructions Progress:",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    value: _effectiveInstructions.isEmpty
                                        ? 0
                                        : _effectiveInstructions
                                                  .where(
                                                    (inst) =>
                                                        inst['completed'] ==
                                                        true,
                                                  )
                                                  .length /
                                              _effectiveInstructions.length,
                                    backgroundColor: Colors.white12,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryBlue,
                                    ),
                                    minHeight: 8,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${(_effectiveInstructions.where((inst) => inst['completed'] == true).length / _effectiveInstructions.length * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white60, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
