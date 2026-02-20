
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Assessment Survey.dart';

class RiskScore extends StatefulWidget {
  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);

  const RiskScore({super.key});

  @override
  State<RiskScore> createState() => _OralScoreState();
}

class _OralScoreState extends State<RiskScore> {
  Map<String, dynamic>? oralData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOralScore();
  }

  Future<void> _fetchOralScore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists && doc.data()!.containsKey('oralScore')) {
        setState(() {
          oralData = doc.data()!['oralScore'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  // --- دالة توليد النصائح الذكية بناءً على البيانات ---
  List<String> _generateAITips() {
    if (oralData == null) return ["Complete your assessment to get AI tips."];

    List<String> tips = [];
    int cavity = oralData!['cavityRisk'] ?? 0;
    int gum = oralData!['gumRisk'] ?? 0;
    int hygiene = oralData!['hygieneScore'] ?? 0;

    // نصيحة بناءً على التسوس
    if (cavity > 50) {
      tips.add("High cavity risk detected: Use fluoride toothpaste and limit sugar.");
    }
    // نصيحة بناءً على اللثة
    if (gum > 50) {
      tips.add("Gum sensitivity noted: Use a soft-bristled brush and floss gently.");
    }
    // نصيحة بناءً على النظافة العامة
    if (hygiene < 60) {
      tips.add("Improve hygiene: Ensure you're brushing for a full 2 minutes.");
    } else {
      tips.add("Great hygiene habits! Keep up the consistent flossing.");
    }

    // نصائح عامة ثابتة لتكملة القائمة
    tips.add("Visit your dentist every 6 months for a professional cleaning.");

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiskScore.bgColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: RiskScore.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Oral Score", style: TextStyle(color: Colors.white)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications_none, color: Colors.white),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _scoreCard()),
            const SizedBox(height: 24),
            const Text(
              "Risk Breakdown",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            riskBar("Cavity Risk", oralData?['cavityRisk'] ?? 0),
            riskBar("Gum Disease", oralData?['gumRisk'] ?? 0),
            riskBar("Enamel Health", oralData?['enamelRisk'] ?? 0),
            riskBar("Oral Hygiene", oralData?['hygieneScore'] ?? 0),
            const SizedBox(height: 20),
            _tipsCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard() {
    final int score = oralData?['score'] ?? 0;
    final Color scoreColor = getScoreColor(score.toDouble());
    final String riskLevelText = getRiskLevelText(score.toDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RiskScore.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Text("Your Oral Health Score", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 170, width: 170,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text("$score", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const Text("OUT OF 100", style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              )
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: scoreColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text(riskLevelText, style: TextStyle(color: scoreColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent.withOpacity(0.1),
              side: const BorderSide(color: Colors.cyanAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 45),
            ),
            icon: const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 18),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AssessmentSurvey()),
              ).then((_) => _fetchOralScore());
            },
            label: const Text("Retake AI Assessment", style: TextStyle(color: Colors.cyanAccent)),
          )
        ],
      ),
    );
  }

  Widget _tipsCard() {
    final List<String> aiTips = _generateAITips();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RiskScore.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                "Personalized AI Tips",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // عرض النصائح المتولدة ديناميكياً
          ...aiTips.map((tip) => TipRow(tip)).toList(),
        ],
      ),
    );
  }
}

// --- الـ Helper Widgets (تظل كما هي أو تعديلات بسيطة للجمالية) ---

Widget riskBar(String title, int value) {
  final Color color = getScoreColor(value.toDouble());
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: RiskScore.cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            Text("$value%", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    ),
  );
}

class TipRow extends StatelessWidget {
  final String text;
  const TipRow(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline, size: 14, color: Colors.greenAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

Color getScoreColor(double score) {
  if (score >= 80) return Colors.greenAccent;
  if (score >= 50) return Colors.orangeAccent;
  return Colors.redAccent;
}

String getRiskLevelText(double score) {
  if (score >= 80) return "Healthy";
  if (score >= 50) return "Moderate Risk";
  return "High Risk";
}


