class Emergencylist {
  final String name;
  final String resons;
  final String contact;
  final String time;
  final int spend;


  Emergencylist({
    required this.name,
    required this.resons,
    required this.contact,
    required this.time,
    required this.spend,
  });
}

List<Emergencylist> emergencylist = [
  Emergencylist(
    name: "Sarah Johnson",
    resons: "Sudden severe toothache with swelling on right side.",
    contact: "+1 (555) 123-4567",
    time: "09:15 AM - 2 mins ago",
    spend :2,

  ),
  Emergencylist(
    name: "Ahmed Mansour",
    resons: "Heavy bleeding after wisdom tooth extraction.",
    contact: "+20 100 456 7890",
    time: "10:30 AM - 5 mins ago",
    spend :5,
  ),
  Emergencylist(
    name: "Ahmed Mansour",
    resons: "Traumatic injury: front tooth knocked out while playing.",
    contact: "+20 111 222 3334",
    time: "11:05 AM - 10 mins ago",
    spend :10,

  ),
  Emergencylist(
    name: "John Smith",
    resons: "Severe abscess causing difficulty in opening the jaw.",
    contact: "+1 (555) 987-6543",
    time: "12:20 PM - 1 min ago",
    spend :1,

  ),
];