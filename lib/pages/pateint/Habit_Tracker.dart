import 'package:flutter/material.dart';

final Color bgColor = const Color(0xFF0B1C2D);
final Color primaryBlue = const Color(0xFF2EC4FF);
final Color cardColor = const Color(0xFF112B3C);

class HabitTracker extends StatefulWidget {
  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  final List<Map<String, dynamic>> dentalHabits = [
    {
      "title": "Brush Teeth",
      "subtitle": "2 minutes, twice a day",
      "icon": Icons.brush_rounded,
      "isTracked": false,
    },
    {
      "title": "Limit Sugar",
      "subtitle": "Avoid sweets & soda",
      "icon": Icons.coffee,
      "isTracked": false,
    },
    {
      "title": "Flossing",
      "subtitle": "Clean between teeth",
      "icon": Icons.straighten_rounded,
      "isTracked": false,
    },
    {
      "title": "Drink Water",
      "subtitle": "Keep your mouth hydrated",
      "icon": Icons.local_drink_rounded,
      "isTracked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    int completed = dentalHabits.where((h) => h['isTracked'] == true).length;
    double percentage = (completed / dentalHabits.length);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text(
          "Habit Tracker",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                 border: Border.all(color: Colors.white10),
                 boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2EC4FF).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Daily Compliance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${(percentage * 100).toInt()}%",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                   SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage,
                      minHeight: 10,
                      backgroundColor: Colors.white10,
                      valueColor:  AlwaysStoppedAnimation<Color>(
                        primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Almost there, stay consistent!",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.white10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                "Daily Habits ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            for (int i = 0; i < dentalHabits.length; i++)
              buildHabitCard(dentalHabits[i]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildHabitCard(Map<String, dynamic> habit) {
    bool done = habit['isTracked'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
          border: Border.all(
            color: done ? primaryBlue.withOpacity(0.5) : Colors.white10,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    habit['icon'],
                    color: done ? primaryBlue : Colors.white70,
                    size: 28,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit['title'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          habit['subtitle'],
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    done ? "Completed " : "Not yet tracked",
                    style: TextStyle(
                      color: done ? primaryBlue : Colors.white38,
                      fontWeight: done ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  Switch(
                    value: habit['isTracked'],
                    activeColor: Colors.white,
                    activeTrackColor: primaryBlue,
                    onChanged: (bool value) {
                      setState(() {
                        habit['isTracked'] = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
