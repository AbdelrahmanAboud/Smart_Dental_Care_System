import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Map<String, int> weeklyActivity = {};
  // 1. إضافة Cleaning للـ Map الأساسية
  Map<String, int> dentalIssues = {"Filling": 0, "Extraction": 0, "Root Canal": 0, "Cleaning": 0};

  int totalPatients = 0;
  double avgRiskScore = 0.0;
  double avgRating = 0.0;
  int patientsWithScoreCount = 0;

  int lowRiskCount = 0;
  int midRiskCount = 0;
  int hRiskCount = 0;

  int emergencyAccepted = 0;
  int emergencyRejected = 0;
  int emergencyTotal = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    _loadFirebaseAnalytics();
  }

  Future<void> _loadFirebaseAnalytics() async {
    final String doctorId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (doctorId.isEmpty) return;

    try {
      final appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      Map<String, int> weekMap = {"Mon": 0, "Tue": 0, "Wed": 0, "Thu": 0, "Fri": 0, "Sat": 0, "Sun": 0};
      // 2. إضافة Cleaning هنا لضمان تصفيرها قبل الحساب
      Map<String, int> issuesMap = {"Filling": 0, "Extraction": 0, "Root Canal": 0, "Cleaning": 0};
      final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

      double totalRiskSum = 0;
      int scoredPatients = 0;
      int lCount = 0, mCount = 0, hCount = 0;
      Set<String> uniquePatients = {};

      for (var doc in appointmentsSnapshot.docs) {
        final data = doc.data();
        if (data['patientId'] != null) uniquePatients.add(data['patientId']);

        if (data['date'] != null) {
          DateTime date = (data['date'] as Timestamp).toDate();
          String dayName = dayNames[date.weekday - 1];
          weekMap[dayName] = (weekMap[dayName] ?? 0) + 1;
        }

        String rawTreatment = (data['treatment'] ?? data['type'] ?? "").toString().trim();
        String finalKey = "";

        // 3. إضافة منطق الفحص لكلمة Cleaning
        if (rawTreatment.contains("Filling")) {
          finalKey = "Filling";
        } else if (rawTreatment.contains("Extraction")) {
          finalKey = "Extraction";
        } else if (rawTreatment.contains("Root Canal")) {
          finalKey = "Root Canal";
        } else if (rawTreatment.contains("Cleaning")) {
          finalKey = "Cleaning";
        }

        if (finalKey.isNotEmpty && issuesMap.containsKey(finalKey)) {
          issuesMap[finalKey] = issuesMap[finalKey]! + 1;
        }

        if (data['riskScore'] != null) {
          int s = (data['riskScore'] as num).toInt();
          totalRiskSum += s;
          scoredPatients++;
          if (s >= 80) lCount++; else if (s >= 60) mCount++; else hCount++;
        }
      }

      final reviewsSnapshot = await FirebaseFirestore.instance.collection('reviews').where('doctorId', isEqualTo: doctorId).get();
      double sumRating = reviewsSnapshot.docs.fold(0, (sum, doc) => sum + (doc.data()['rating'] as num).toDouble());

      final emergencySnapshot = await FirebaseFirestore.instance.collection('emergencies').where('doctorId', isEqualTo: doctorId).get();
      int acc = 0, rej = 0;
      for (var doc in emergencySnapshot.docs) {
        String status = (doc.data()['status'] ?? "").toString().toLowerCase();
        if (status == 'accepted' || status == 'approved') acc++;
        else if (status == 'rejected' || status == 'declined') rej++;
      }

      if (mounted) {
        setState(() {
          totalPatients = uniquePatients.length;
          patientsWithScoreCount = scoredPatients;
          avgRiskScore = scoredPatients == 0 ? 0 : totalRiskSum / scoredPatients;
          avgRating = reviewsSnapshot.docs.isEmpty ? 0 : sumRating / reviewsSnapshot.docs.length;
          lowRiskCount = lCount; midRiskCount = mCount; hRiskCount = hCount;
          weeklyActivity = weekMap; dentalIssues = issuesMap;
          emergencyTotal = emergencySnapshot.docs.length;
          emergencyAccepted = acc; emergencyRejected = rej;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
        backgroundColor: Analytics.bgColor, elevation: 0,
        title: const Text("Doctor Analytics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.1,
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              children: [
                AnalyticsCard(icon: Icons.group, iconColor: const Color(0xFF4CAF50), value: totalPatients.toString(), title: "My Patients"),
                AnalyticsCard(icon: Icons.trending_up, iconColor: const Color(0xFF4CAF50), value: avgRiskScore.toStringAsFixed(0), title: "Avg Risk Score"),
                AnalyticsCard(icon: Icons.star_border, iconColor: const Color(0xFFFFC107), value: avgRating.toStringAsFixed(1), title: "My Rating"),
                AnalyticsCard(icon: Icons.warning_amber_rounded, iconColor: const Color(0xFFFF5252), value: emergencyTotal.toString(), title: "Total Emergencies"),
              ],
            ),
            const SizedBox(height: 20),
            _buildEmergencyDetailCard(),
            const SizedBox(height: 28),
            _buildWeeklyBarChart(),
            const SizedBox(height: 28),
            _buildDentalIssuesPie(),
            const SizedBox(height: 28),
            _buildRiskDistribution(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    double maxVal = weeklyActivity.values.fold(0, (max, v) => v > max ? v : max).toDouble();
    double topLimit = maxVal < 5 ? 5 : (maxVal + 1);

    return Container(
      height: 260, padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(color: Analytics.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        const Text("Weekly Patient Count", style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 20),
        Expanded(
          child: BarChart(BarChartData(
            maxY: topLimit,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey,
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  rod.toY.round().toString(),
                  const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            barGroups: dayNames.asMap().entries.map((e) => _neonBar(e.key, (weeklyActivity[e.value] ?? 0).toDouble())).toList(),
            titlesData: FlTitlesData(
              show: true,
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.white38, fontSize: 10)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(dayNames[v.toInt()], style: const TextStyle(color: Colors.white54, fontSize: 10))))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10, strokeWidth: 1)),
            borderData: FlBorderData(show: true, border: const Border(bottom: BorderSide(color: Colors.white24), left: BorderSide(color: Colors.white24))),
          )),
        ),
      ]),
    );
  }

  BarChartGroupData _neonBar(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y * _animation.value, width: 18, borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00FFA3)], begin: Alignment.bottomCenter, end: Alignment.topCenter))
    ]);
  }

  Widget _buildEmergencyDetailCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Analytics.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        const Row(children: [Icon(Icons.info_outline, color: Colors.redAccent, size: 20), SizedBox(width: 8), Text("Emergencies Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _miniStat("Accepted", emergencyAccepted, Colors.greenAccent),
          Container(width: 1, height: 30, color: Colors.white10),
          _miniStat("Rejected", emergencyRejected, Colors.redAccent),
        ])
      ]),
    );
  }

  Widget _miniStat(String label, int val, Color col) => Column(children: [
    Text(val.toString(), style: TextStyle(color: col, fontSize: 22, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
  ]);

  Widget _buildDentalIssuesPie() {
    return Container(
      height: 220, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Analytics.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        const Text("Treatment Breakdown", style: TextStyle(color: Colors.white, fontSize: 16)),
        const SizedBox(height: 10),
        Expanded(child: Row(children: [
          Expanded(flex: 3, child: PieChart(PieChartData(sectionsSpace: 4, centerSpaceRadius: 35, sections: [
            _pieSection("Filling", Colors.cyanAccent),
            _pieSection("Extraction", Colors.pinkAccent),
            _pieSection("Root Canal", Colors.orangeAccent),
            // 4. إضافة قسم Cleaning في الرسم الدائري
            _pieSection("Cleaning", Colors.purpleAccent),
          ]))),
          Expanded(flex: 2, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _legendDot(Colors.cyanAccent, "Filling", "${dentalIssues['Filling']}"),
            _legendDot(Colors.pinkAccent, "Extraction", "${dentalIssues['Extraction']}"),
            _legendDot(Colors.orangeAccent, "Root Canal", "${dentalIssues['Root Canal']}"),
            // 5. إضافة Cleaning في القائمة التوضيحية
            _legendDot(Colors.purpleAccent, "Cleaning", "${dentalIssues['Cleaning']}"),
          ])),
        ])),
      ]),
    );
  }

  PieChartSectionData _pieSection(String key, Color color) {
    double val = (dentalIssues[key] ?? 0).toDouble();
    return PieChartSectionData(value: val == 0 ? 0.001 : val, color: color, radius: 22, showTitle: false);
  }

  Widget _buildRiskDistribution() {
    int safeMax = patientsWithScoreCount == 0 ? 1 : patientsWithScoreCount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Analytics.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Risk Distribution", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        RiskRangeBar(range: "80-100 (Low Risk)", count: lowRiskCount, color: Colors.greenAccent, maxCount: safeMax),
        RiskRangeBar(range: "60-79 (Moderate)", count: midRiskCount, color: Colors.orangeAccent, maxCount: safeMax),
        RiskRangeBar(range: "0-59 (Critical)", count: hRiskCount, color: Colors.redAccent, maxCount: safeMax),
      ]),
    );
  }

  Widget _legendDot(Color color, String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      const Spacer(),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    ]),
  );
}

class AnalyticsCard extends StatelessWidget {
  final IconData icon; final Color iconColor; final String value; final String title;
  const AnalyticsCard({super.key, required this.icon, required this.iconColor, required this.value, required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Analytics.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
    );
  }
}

class RiskRangeBar extends StatelessWidget {
  final String range; final int count; final Color color; final int maxCount;
  const RiskRangeBar({super.key, required this.range, required this.count, required this.color, required this.maxCount});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(range, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text("$count patients", style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 6),
        Stack(children: [
          Container(height: 8, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            height: 8, width: (maxCount == 0) ? 0 : (count / maxCount) * (MediaQuery.of(context).size.width - 60),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          ),
        ]),
      ]),
    );
  }
}