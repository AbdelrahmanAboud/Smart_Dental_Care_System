import 'package:cloud_firestore/cloud_firestore.dart';
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
      duration: const Duration(seconds: 2),
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
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Patient').snapshots(),
      builder: (context, userSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
          builder: (context, reviewSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
              builder: (context, apptSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('invoices').snapshots(),
                  builder: (context, invoiceSnapshot) {

                    // 1. حساب الإيرادات اليومية (آخر 6 أيام)
                    double totalRevenueThisMonth = 0;
                    List<double> dailyRevenueData = [0, 0, 0, 0, 0, 0];
                    DateTime now = DateTime.now();

                    if (invoiceSnapshot.hasData) {
                      for (var doc in invoiceSnapshot.data!.docs) {
                        var data = doc.data() as Map<String, dynamic>;
                        if (data['status']?.toString().toLowerCase() == 'paid') {
                          double amount = (data['totalAmount'] ?? 0).toDouble();
                          Timestamp? ts = data['timestamp'];
                          if (ts != null) {
                            DateTime date = ts.toDate();

                            // إجمالي الشهر الحالي للكارت العلوي
                            if (date.month == now.month && date.year == now.year) {
                              totalRevenueThisMonth += amount;
                            }

                            // توزيع إيرادات آخر 6 أيام للجراف
                            for (int i = 0; i < 6; i++) {
                              DateTime targetDay = DateTime(now.year, now.month, now.day - (5 - i));
                              if (date.day == targetDay.day &&
                                  date.month == targetDay.month &&
                                  date.year == targetDay.year) {
                                dailyRevenueData[i] += amount;
                              }
                            }
                          }
                        }
                      }
                    }

                    // 2. الحالات الطارئة (آخر 7 أيام)
                    DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
                    int emergencyCount = 0;
                    if (apptSnapshot.hasData) {
                      emergencyCount = apptSnapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        Timestamp? ts = data['date'];
                        return data['type'] == 'Emergency' && ts != null && ts.toDate().isAfter(sevenDaysAgo);
                      }).length;
                    }

                    // 3. تحليل التقييمات (Sentiment)
                    int pos = 0, neg = 0, neu = 0;
                    double positivePercent = 0;
                    if (reviewSnapshot.hasData && reviewSnapshot.data!.docs.isNotEmpty) {
                      for (var doc in reviewSnapshot.data!.docs) {
                        double r = (doc['rating'] as num? ?? 0).toDouble();
                        if (r >= 4) pos++; else if (r <= 2) neg++; else neu++;
                      }
                      positivePercent = (pos / reviewSnapshot.data!.docs.length) * 100;
                    }

                    // 4. تحليل المرضى الأسبوعي
                    List<double> newPatientsWeek = [0, 0, 0, 0, 0];
                    List<double> revisitPatientsWeek = [0, 0, 0, 0, 0];
                    if (userSnapshot.hasData) {
                      for (var doc in userSnapshot.data!.docs) {
                        var data = doc.data() as Map<String, dynamic>;
                        Timestamp? ts = data['pushedAt'] ?? data['createdAt'];
                        if (ts != null) {
                          DateTime date = ts.toDate();
                          if (date.month == now.month && date.year == now.year) {
                            int week = ((date.day - 1) / 7).floor().clamp(0, 4);
                            if (data['status'] == 'Done') revisitPatientsWeek[week]++;
                            else newPatientsWeek[week]++;
                          }
                        }
                      }
                    }

                    return Scaffold(
                      backgroundColor: AnalyticsReceptionist.bgColor,
                      appBar: AppBar(
                        backgroundColor: AnalyticsReceptionist.bgColor,
                        elevation: 0,
                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        title: const Text("Analytics & Reports", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      ),
                      body: SingleChildScrollView(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 1.2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                AnalyticsCard(icon: Icons.group, iconColor: AnalyticsReceptionist.primaryBlue, value: (userSnapshot.data?.docs.length ?? 0).toString(), title: "Total Patients", period: "Overall"),
                                AnalyticsCard(icon: Icons.trending_up, iconColor: Colors.greenAccent, value: "\$${totalRevenueThisMonth.toStringAsFixed(0)}", title: "Total Revenue", period: "This Month"),
                                AnalyticsCard(icon: Icons.star_border, iconColor: Colors.amber, value: "${positivePercent.toStringAsFixed(0)}%", title: "Positive Feedback", period: "From Reviews"),
                                AnalyticsCard(icon: Icons.warning_amber_rounded, iconColor: Colors.redAccent, value: emergencyCount.toString(), title: "Emergency cases", period: "Last 7 days"),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _buildWeeklyChart(newPatientsWeek, revisitPatientsWeek),
                            const SizedBox(height: 28),
                            _buildRevenueChart(dailyRevenueData),
                            const SizedBox(height: 28),
                            _buildSentimentPie(pos, neg, neu),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyChart(List<double> newData, List<double> revisitData) {
    return Container(
      height: 240, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AnalyticsReceptionist.cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        const Text("Patient Traffic per Week", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Expanded(child: AnimatedBuilder(animation: _animation, builder: (context, _) {
          return BarChart(BarChartData(
            maxY: 15,
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white.withOpacity(0.05))),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(color: Colors.white38, fontSize: 10)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text("W${v.toInt()+1}", style: const TextStyle(color: Colors.white60, fontSize: 11)))),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(5, (i) => _compareBars(i, newData[i] * _animation.value, revisitData[i] * _animation.value)),
          ));
        })),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [_legend(const Color(0xFF00FFA3), "New"), const SizedBox(width: 20), _legend(const Color(0xFF7C4DFF), "Revisit")]),
      ]),
    );
  }

  Widget _buildRevenueChart(List<double> revenueData) {
    return Container(
      height: 240, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(children: [
        const Text("Daily Revenue (Last 6 Days)", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Expanded(child: LineChart(LineChartData(
          minY: 0,
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white10)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: (v, m) => Text("${v.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 10)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
              DateTime day = DateTime.now().subtract(Duration(days: 5 - v.toInt()));
              return Text("${day.day}/${day.month}", style: const TextStyle(color: Colors.white54, fontSize: 10));
            })),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [LineChartBarData(
            spots: List.generate(6, (i) => FlSpot(i.toDouble(), revenueData[i])),
            isCurved: true,
            barWidth: 4,
            color: AnalyticsReceptionist.primaryBlue,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: AnalyticsReceptionist.primaryBlue.withOpacity(0.1)),
          )],
        ))),
      ]),
    );
  }

  Widget _buildSentimentPie(int p, int n, int nu) {
    int total = p + n + nu;
    String pP = total == 0 ? "0%" : "${((p/total)*100).toStringAsFixed(0)}%";
    String nP = total == 0 ? "0%" : "${((n/total)*100).toStringAsFixed(0)}%";
    String nuP = total == 0 ? "0%" : "${((nu/total)*100).toStringAsFixed(0)}%";

    return Container(
      height: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AnalyticsReceptionist.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Feedback Sentiment", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(child: PieChart(PieChartData(centerSpaceRadius: 40, sections: [
                  PieChartSectionData(value: (p == 0 ? 1 : p).toDouble(), color: Colors.cyanAccent, radius: 20, showTitle: false),
                  PieChartSectionData(value: (n == 0 ? 1 : n).toDouble(), color: Colors.pinkAccent, radius: 20, showTitle: false),
                  PieChartSectionData(value: (nu == 0 ? 1 : nu).toDouble(), color: Colors.amber, radius: 20, showTitle: false),
                ]))),
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _legendDot(Colors.cyanAccent, "Positive", pP),
                  _legendDot(Colors.pinkAccent, "Negative", nP),
                  _legendDot(Colors.amber, "Neutral", nuP),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String t) => Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 6), Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
  Widget _legendDot(Color c, String t, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)), const SizedBox(width: 8), Text(t, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(width: 12), Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]));
  BarChartGroupData _compareBars(int x, double y1, double y2) => BarChartGroupData(x: x, barRods: [BarChartRodData(toY: y1, width: 10, borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00FFA3)])), BarChartRodData(toY: y2, width: 10, borderRadius: BorderRadius.circular(4), gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)]))]);
}

class AnalyticsCard extends StatelessWidget {
  final IconData icon; final Color iconColor; final String value; final String title; final String period;
  const AnalyticsCard({super.key, required this.icon, required this.iconColor, required this.value, required this.title, required this.period});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AnalyticsReceptionist.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(period, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ])),
        Icon(icon, color: iconColor, size: 22),
      ]),
    );
  }
}