import 'package:flutter/material.dart';

class PatientTreatmentPage extends StatefulWidget {
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> instructions;

  PatientTreatmentPage({required this.medications, required this.instructions});

  @override
  _PatientTreatmentPageState createState() => _PatientTreatmentPageState();
}

class _PatientTreatmentPageState extends State<PatientTreatmentPage> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color primaryBlue = const Color(0xFF2EC4FF);
  final Color cardColor = const Color(0xFF112B3C);
  final Color greenAccent = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    for (var med in widget.medications) {
      if (!med.containsKey('taken')) {
        med['taken'] = List<bool>.filled(med['times'].length, false);
      }
      if (!med.containsKey('completionPercentage')) {
        med['completionPercentage'] = 0.0;
      }
    }

    for (var inst in widget.instructions) {
      if (!inst.containsKey('completed')) {
        inst['completed'] = false;
      }
    }
  }

  double get overallProgress {
    if (widget.medications.isEmpty && widget.instructions.isEmpty) return 0.0;

    double medProgress = 0.0;
    double instProgress = 0.0;

    if (widget.medications.isNotEmpty) {
      for (var med in widget.medications) {
        List<bool> takenList = List<bool>.from(med['taken']);
        int takenCount = takenList.where((t) => t).length;
        med['completionPercentage'] = takenList.isEmpty
            ? 0.0
            : (takenCount / takenList.length);
        medProgress += med['completionPercentage'];
      }
      medProgress = medProgress / widget.medications.length;
    }

    if (widget.instructions.isNotEmpty) {
      int completedInst = widget.instructions
          .where((inst) => inst['completed'] == true)
          .length;
      instProgress = completedInst / widget.instructions.length;
    }

    if (widget.medications.isEmpty) return instProgress;
    if (widget.instructions.isEmpty) return medProgress;

    return (medProgress + instProgress) / 2;
  }

  Map<String, int> get todayMedicationStats {
    int takenCount = 0;
    int totalCount = 0;

    for (var med in widget.medications) {
      List<bool> takenList = List<bool>.from(med['taken']);
      takenCount += takenList.where((t) => t).length;
      totalCount += takenList.length;
    }

    return {'taken': takenCount, 'total': totalCount};
  }

  @override
  Widget build(BuildContext context) {
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
                        widget.medications.length.toString(),
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
                        widget.instructions.length.toString(),
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

            if (widget.medications.isNotEmpty)
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
                      children: widget.medications.map((med) {
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
                                      },
                                      child: Container(
                                        
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isTaken
                                              ? Colors.green.withOpacity(0.3)
                                              :  primaryBlue.withOpacity(0.1), 
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isTaken
                                                ? Colors.green
                                                :  primaryBlue.withOpacity(0.1), 
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

            if (widget.instructions.isNotEmpty)
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
                          "${widget.instructions.where((inst) => inst['completed'] == true).length}/${widget.instructions.length}",
                          style: TextStyle(
                            color: primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    ...widget.instructions.asMap().entries.map((entry) {
                      int index = entry.key;
                      var instruction = entry.value;
                      bool isCompleted = instruction['completed'] == true;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            instruction['completed'] = !isCompleted;
                          });
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
                                    value: widget.instructions.isEmpty
                                        ? 0
                                        : widget.instructions
                                                  .where(
                                                    (inst) =>
                                                        inst['completed'] ==
                                                        true,
                                                  )
                                                  .length /
                                              widget.instructions.length,
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
                                  "${(widget.instructions.where((inst) => inst['completed'] == true).length / widget.instructions.length * 100).toStringAsFixed(0)}%",
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
