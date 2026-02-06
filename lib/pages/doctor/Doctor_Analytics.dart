import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/data/DoctorModels/EmergencyList.dart';
import 'package:smart_dental_care_system/data/PateintModels/Feedbaack_Rating.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Analytics.bgColor,
      appBar: AppBar(

      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(
              context,
            ).pop();
          },
        ),
      backgroundColor: Analytics.bgColor,
      elevation: 0,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Analytics",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        
        ],
      ),

      actions: [
        Padding(
          padding:  EdgeInsets.only(right: 13.0),
          child: IconButton(
            iconSize: 28,
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= GRID CARDS =================
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics:  NeverScrollableScrollPhysics(),
              children:  [
                AnalyticsCard(
                  icon: Icons.group,
                  iconColor: Color(0xFF4CAF50),
                  value: "82",
                  title: "Patients This Week",
                ),
                AnalyticsCard(
                  icon: Icons.trending_up,
                  iconColor: Color(0xFF4CAF50),
                  value: "75",
                  title: "Avg Risk Score",
                ),
                AnalyticsCard(
                  icon: Icons.star_border,
                  iconColor: Color(0xFFFFC107),
                  value: "4.8",
                  title: "Patient Rating",
                ),
                AnalyticsCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Color(0xFFFF5252),
                  value: "5",
                  title: "High Risk Cases",
                ),
              ],
            ),

            const SizedBox(height: 28),

            /// ================= WEEKLY OVERVIEW =================
            Container(
              height: 240,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0B1C2D),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.cyan.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Weekly Patient Count",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animation,

                      builder: (context, _) {
                        return BarChart(
                          BarChartData(
                            maxY: 20,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              checkToShowHorizontalLine: (value) =>
                                  value % 2 == 0,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.white.withOpacity(0.06),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1,
                                ),
                                top: BorderSide.none,
                                right: BorderSide.none,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5,
                                  reservedSize: 26,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const days = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        days[value.toInt()],
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: [
                              _neonBar(0, 12 * _animation.value),
                              _neonBar(1, 15 * _animation.value),
                              _neonBar(2, 10 * _animation.value),
                              _neonBar(3, 18 * _animation.value),
                              _neonBar(4, 14 * _animation.value),
                              _neonBar(5, 8 * _animation.value),
                              _neonBar(6, 5 * _animation.value),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ================= COMMON DENTAL ISSUES =================
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Analytics.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Common Dental issue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              double animValue = _controller.value;

                              return PieChart(
                                PieChartData(
                                  centerSpaceRadius: 45,
                                  sectionsSpace: 4,
                                  startDegreeOffset: -90,
                                  sections: [
                                    PieChartSectionData(
                                      value: 35 * animValue,
                                      color: Colors.pinkAccent,
                                      radius: 22,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 25 * animValue,
                                      color: Colors.amber,
                                      radius: 22,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 30 * animValue,
                                      color: Colors.cyanAccent,
                                      radius: 22,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 10 * animValue,
                                      color: Colors.greenAccent,
                                      radius: 22,
                                      showTitle: false,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _legendDot(Colors.pinkAccent, "Cavities", "35%"),
                              _legendDot(Colors.amber, "Gum Disease", "25%"),
                              _legendDot(Colors.cyanAccent, "Cleanings", "30%"),
                              _legendDot(Colors.greenAccent, "Cosmetic", "10%"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ================= RECENT REVIEWS =================  
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Analytics.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recent Past Reviews",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...pastReviews
                      .take(3)
                      .map((review) => _reviewCard(review))
                      .toList(),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ================= HIGH RISK PATIENTS ================= 
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Analytics.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Patient Risk Distribution",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RiskRangeBar(
                    range: "80-100",
                    count: 45,
                    color: Colors.green,
                    maxCount: 100,
                  ),
                  RiskRangeBar(
                    range: "60-79",
                    count: 30,
                    color: Colors.orange,
                    maxCount: 100,
                  ),
                  RiskRangeBar(
                    range: "0-59",
                    count: 15,
                    color: Colors.red,
                    maxCount: 100,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ================= EMERGENCY CASES =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Analytics.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Emergency Cases This Month",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total Emergencies
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                        "Total Emergencies",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "${emergencylist.length}",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Average Response Time
                  Builder(
                    builder: (context) {
                      double avgTime = 0;
                      final times = emergencylist
                          .map((e) => e.spend ?? 0)
                          .toList();

                      if (times.isNotEmpty) {
                        avgTime = times.reduce((a, b) => a + b) / times.length;
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Average Response Time",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            "${avgTime.toStringAsFixed(1)} min",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Most Common Issue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Most Common Issue ",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: Text(
                          getMostCommon(
                            emergencylist.map((e) => e.resons).toList(),
                          ),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
 

  /// ================= HELPER FUNCTIONS =================
  String getMostCommon(List<String> list) {
    if (list.isEmpty) return "No data";

    Map<String, int> freqMap = {};
    for (var item in list) {
      freqMap[item] = (freqMap[item] ?? 0) + 1;
    }

    String mostCommon = list[0];
    int maxCount = 0;
    freqMap.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostCommon = key;
      }
    });
    return mostCommon;
  }

  Widget _legendDot(Color color, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(Review r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Analytics.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundImage: AssetImage(r.image)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"${r.comment}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  r.date,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < r.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _neonBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 25,
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF00FFA3)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
            toY: 20,
            color: Colors.white10,
          ),
        ),
      ],
    );
  }
}

/// ================= ANALYTICS CARD =================
class AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;

  const AnalyticsCard({
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
        color: Analytics.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        margin:  EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Analytics.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        padding:  EdgeInsets.symmetric(vertical: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 28),
               SizedBox(height: 12),
              Text(
                value,
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style:  TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= RISK RANGE BAR =================
class RiskRangeBar extends StatelessWidget {
  final String range;
  final int count;
  final Color color;
  final int maxCount;

  const RiskRangeBar({
    super.key,
    required this.range,
    required this.count,
    required this.color,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    double progress = count / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(range, style: const TextStyle(color: Colors.white70)),
              Text("$count patients", style: TextStyle(color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
