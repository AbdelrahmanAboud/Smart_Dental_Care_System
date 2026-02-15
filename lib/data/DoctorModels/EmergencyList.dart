class Emergencylist {
  final String uid;
  final String name;
  final String resons;
  final String contact;
  final String time;
  final int spend;


  Emergencylist({
    required this.uid,
    required this.name,
    required this.resons,
    required this.contact,
    required this.time,
    required this.spend,
  });
}
final List<Emergencylist> emergencylist = [
  Emergencylist(
    uid: "u1",
    name: "Ahmed Ali",
    resons: "Severe Toothache",
    contact: "01012345678",
    time: "09:00 AM",
    spend: 120, // القيمة دي اللي بتظهر في الـ Charts
  ),
  Emergencylist(
    uid: "u2",
    name: "Sarah Hassan",
    resons: "Broken Crown",
    contact: "01122334455",
    time: "10:30 AM",
    spend: 85,
  ),
  Emergencylist(
    uid: "u3",
    name: "Mohamed Omar",
    resons: "Gum Bleeding",
    contact: "01233445566",
    time: "11:45 AM",
    spend: 45,
  ),
  Emergencylist(
    uid: "u4",
    name: "Nour Eldin",
    resons: "Abscess Treatment",
    contact: "01544556677",
    time: "02:15 PM",
    spend: 150,
  ),
  Emergencylist(
    uid: "u5",
    name: "Laila Mahmoud",
    resons: "Emergency Extraction",
    contact: "01099887766",
    time: "04:00 PM",
    spend: 200,
  ),
  Emergencylist(
    uid: "u6",
    name: "Youssef Ibrahim",
    resons: "Impacted Tooth",
    contact: "01277889900",
    time: "05:30 PM",
    spend: 110,
  ),
  Emergencylist(
    uid: "u7",
    name: "Mariam Ahmed",
    resons: "Loose Implant",
    contact: "01144553322",
    time: "07:00 PM",
    spend: 95,
  ),
];
