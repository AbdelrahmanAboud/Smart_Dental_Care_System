import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsReceptionist extends StatefulWidget {
  const AnalyticsReceptionist({super.key});

  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);
  static const Color primaryBlue = Color(0xFF2EC4FF);

  @override
  State<AnalyticsReceptionist> createState() => _AnalyticsReceptionistState();
}

class _AnalyticsReceptionistState extends State<AnalyticsReceptionist>
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
      backgroundColor: AnalyticsReceptionist.bgColor,
      appBar: AppBar(
        backgroundColor: AnalyticsReceptionist.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Analytics & Reports",
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
            padding: const EdgeInsets.only(right: 13.0),
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
            /// ================= GRID CARDS =================
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                AnalyticsCard(
                  icon: Icons.group,
                  iconColor: AnalyticsReceptionist.primaryBlue,
                  value: "1,245",
                  title: "Total Patients",
                  period: "last 30 days",
                ),
                AnalyticsCard(
                  icon: Icons.trending_up,
                  iconColor: AnalyticsReceptionist.primaryBlue,
                  value: "\$45K",
                  title: "Total Revenue",
                  period: "This Month",
                ),
                AnalyticsCard(
                  icon: Icons.star_border,
                  iconColor: AnalyticsReceptionist.primaryBlue,
                  value: "89%",
                  title: "Positive Feedback",
                  period: "Overall sentiment",
                ),
                AnalyticsCard(
                  icon: Icons.warning_amber_rounded,
                  iconColor: AnalyticsReceptionist.primaryBlue,
                  value: "7",
                  title: "Emergency cases",
                  period: "last Week",
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
                  Center(
                    child: const Text(
                      "Patient per Week",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, _) {
                        return BarChart(
                          BarChartData(
                            maxY: 60,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              checkToShowHorizontalLine: (value) =>
                                  value % 10 == 0,
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
                                  interval: 10,
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
                                      'week1',
                                      'week2',
                                      'week3',
                                      'week4',
                                      'week5',
                                      'week6',
                                      'week7',
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
                              _compareBars(
                                0,
                                45 * _animation.value,
                                17 * _animation.value,
                              ),
                              _compareBars(
                                1,
                                30 * _animation.value,
                                33 * _animation.value,
                              ),
                              _compareBars(
                                2,
                                22 * _animation.value,
                                37 * _animation.value,
                              ),
                              _compareBars(
                                3,
                                18 * _animation.value,
                                46 * _animation.value,
                              ),
                              _compareBars(
                                4,
                                30 * _animation.value,
                                11 * _animation.value,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _legend(Color(0xFF00FFA3), "New"),
                      SizedBox(width: 20),
                      _legend(Color(0xFF7C4DFF), "Revisit"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Monthly Revenue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),

                  Expanded(
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 5,
                        minY: 0,
                        maxY: 100,

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: Colors.white10, strokeWidth: 1),
                        ),

                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 25,
                              getTitlesWidget: (value, meta) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  space: 8,
                                  child: Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
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
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const months = [
                                  'Jan',
                                  'Feb',
                                  'Mar',
                                  'Apr',
                                  'May',
                                  'Jun',
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    months[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        borderData: FlBorderData(show: false),

                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            curveSmoothness: 0.35,
                            spots: const [
                              FlSpot(0, 10),
                              FlSpot(1, 35),
                              FlSpot(2, 45),
                              FlSpot(3, 60),
                              FlSpot(4, 85),
                              FlSpot(5, 95),
                            ],
                            barWidth: 4,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2EC4FF), Color(0xFF2EC4FF)],
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2EC4FF).withOpacity(0.3),
                                  const Color(0xFF2EC4FF).withOpacity(0.05),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
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
                color: AnalyticsReceptionist.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FeedBack Sentiment",
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
                                  sectionsSpace: 3,
                                  startDegreeOffset: -90,
                                  sections: [
                                    PieChartSectionData(
                                      value: 20 * animValue,
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
                                      value: 55 * animValue,
                                      color: Colors.cyanAccent,
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
                              _legendDot(Colors.cyanAccent, "positive", "55%"),
                              _legendDot(Colors.pinkAccent, "negative", "20%"),
                              _legendDot(Colors.amber, "natural", "25%"),
                            ],
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
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.white70)),
      ],
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

  BarChartGroupData _compareBars(int x, double newY, double revisitY) {
    return BarChartGroupData(
      x: x,
      barsSpace: 6, 
      barRods: [
        /// 🟢 NEW
        BarChartRodData(
          toY: newY,
          width: 12,
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF00FFA3)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),

        BarChartRodData(
          toY: revisitY,
          width: 12,
          borderRadius: BorderRadius.circular(6),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF7C4DFF), 
              Color(0xFFE040FB),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}

class AnalyticsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String title;
  final String period;

  const AnalyticsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.title,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AnalyticsReceptionist.cardColor,
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
        margin: const EdgeInsets.all(1.5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AnalyticsReceptionist.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AnalyticsReceptionist.primaryBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    period,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(icon, color: iconColor, size: 26),
          ],
        ),
      ),
    );
  }
}

/// ================= RISK RANGE BAR =================
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
