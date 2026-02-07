class Riskscoremodel {
  final int score; 
  final String riskLevel;
  final int cavityRisk;
  final int gumRisk;
  final int enamelRisk;
  final int hygieneScore;
  final int monthlyImprovement;

  Riskscoremodel({
    required this.score,
    required this.riskLevel,
    required this.cavityRisk,
    required this.gumRisk,
    required this.enamelRisk,
    required this.hygieneScore,
    required this.monthlyImprovement,
  });
}

final oralRiskFake = Riskscoremodel(
  score: 82,
  riskLevel: "Low Risk",
  cavityRisk: 90,
  gumRisk: 85,
  enamelRisk: 72,
  hygieneScore: 88,
  monthlyImprovement: 5,
);