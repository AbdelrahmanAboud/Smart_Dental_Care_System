import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssessmentSurvey extends StatefulWidget {
  const AssessmentSurvey({super.key});

  @override
  State<AssessmentSurvey> createState() => _AssessmentSurveyState();
}

class _AssessmentSurveyState extends State<AssessmentSurvey> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);

  // قائمة الأسئلة وتأثير كل سؤال على المخاطر
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Do you feel pain with cold or hot drinks?",
      "riskType": "enamel", // يؤثر على صحة المينا
      "value": 20,
      "answer": false
    },
    {
      "question": "Do your gums bleed when you brush?",
      "riskType": "gum", // يؤثر على أمراض اللثة
      "value": 25,
      "answer": false
    },
    {
      "question": "Do you see any visible dark spots on your teeth?",
      "riskType": "cavity", // يؤثر على التسوس
      "value": 30,
      "answer": false
    },
    {
      "question": "Do you brush your teeth at least twice a day?",
      "riskType": "hygiene", // يؤثر على النظافة الشخصية (إيجابي)
      "value": 40,
      "answer": false
    },
    {
      "question": "Do you use dental floss daily?",
      "riskType": "hygiene",
      "value": 30,
      "answer": false
    },
  ];

  bool isSaving = false;

  // دالة الحساب وحفظ البيانات في Firestore
  Future<void> _calculateAndSave() async {
    setState(() => isSaving = true);

    int cavityRisk = 10; // قيم أساسية (Minimum)
    int gumRisk = 15;
    int enamelRisk = 10;
    int hygieneScore = 30;

    for (var q in questions) {
      if (q['answer'] == true) {
        if (q['riskType'] == 'cavity') cavityRisk += q['value'] as int;
        if (q['riskType'] == 'gum') gumRisk += q['value'] as int;
        if (q['riskType'] == 'enamel') enamelRisk += q['value'] as int;
        if (q['riskType'] == 'hygiene') hygieneScore += q['value'] as int;
      }
    }

    // معادلة الـ Score العام (عكس متوسط المخاطر)
    int totalRisk = (cavityRisk + gumRisk + enamelRisk) ~/ 3;
    int finalScore = (100 - totalRisk + (hygieneScore ~/ 2)).clamp(0, 100);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'oralScore': {
          'score': finalScore,
          'cavityRisk': cavityRisk.clamp(0, 100),
          'gumRisk': gumRisk.clamp(0, 100),
          'enamelRisk': enamelRisk.clamp(0, 100),
          'hygieneScore': hygieneScore.clamp(0, 100),
          'monthlyImprovement': 5, // قيمة افتراضية للتحسن
          'lastAssessment': FieldValue.serverTimestamp(),
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oral Score Updated Successfully!")),
      );
      Navigator.pop(context); // العودة للصفحة السابقة
    } catch (e) {
      debugPrint("Update Error: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text("AI Oral Assessment", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isSaving
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          questions[index]['question'],
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                      Switch(
                        value: questions[index]['answer'],
                        activeColor: primaryBlue,
                        onChanged: (val) {
                          setState(() => questions[index]['answer'] = val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _calculateAndSave,
              child: const Text(
                "Generate My Score",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}