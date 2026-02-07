import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/data/PateintModels/RiskScoreModel.dart';

class RiskScore extends StatefulWidget {
  static const Color bgColor = Color(0xFF0B1C2D);
  static const Color cardColor = Color(0xFF0F2235);

  const RiskScore({super.key});

  @override
  State<RiskScore> createState() => _OralScoreState();
}

class _OralScoreState extends State<RiskScore> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RiskScore.bgColor,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: RiskScore.bgColor,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          "Oral Score",
          style: TextStyle(color: Colors.white),
        ),
        actions:  [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications_none, color: Colors.white),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: _scoreCard()),
            const SizedBox(height: 24),
            const Text(
              "Risk Breakdown",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            riskBar("Cavity Risk", oralRiskFake.cavityRisk),
            riskBar("Gum Disease", oralRiskFake.gumRisk),
            riskBar("Enamel Health", oralRiskFake.enamelRisk),
            riskBar("Oral Hygiene", oralRiskFake.hygieneScore),
            const SizedBox(height: 20),
            _tipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _scoreCard() {
    final double score = oralRiskFake.score.toDouble();
    final Color scoreColor = getScoreColor(score);
    final String riskLevelText = getRiskLevelText(score);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RiskScore.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Your Oral Health Score",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 170,
                width: 170,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    oralRiskFake.score.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "OUT OF 100",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              riskLevelText,
              style: TextStyle(
                  color: scoreColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "+ ${oralRiskFake.monthlyImprovement} points this month",
            style: TextStyle(color: scoreColor, fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RiskScore.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI Oral Care Tips",
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          TipRow("Brush twice daily for 2 minutes"),
          TipRow("Floss at least once per day"),
          TipRow("Reduce sugary intake especially before bed"),
          TipRow("Visit your dentist every 6 months"),
          TipRow("Consider using fluoride mouthwash"),
        ],
      ),
    );
  }
}

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
            Text("$value%", style: TextStyle(color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value / 100,
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.greenAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
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