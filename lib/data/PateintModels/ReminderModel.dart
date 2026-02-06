class ReminderModel {
  final int id;
  final String title;
  final String description;
  final String time;
  final String date;
  final String iconType;
  final String status;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.iconType,
    required this.status,
  });
}


final List<ReminderModel> remindersList = [
  ReminderModel(
    id: 1,
    title: "Medication Reminder",
    description: "Take your prescribed Amoxicillin (500mg) after breakfast. Finish the full course.",
    time: "10:00 AM",
    date: "Today, Nov 27",
    iconType: "medication",
    status: "pending",
  ),
  ReminderModel(
    id: 2,
    title: "Post-Procedure Care",
    description: "Apply ice pack to reduce swelling for 15 minutes every 2 hours as instructed.",
    time: "02:00 PM",
    date: "Today, Nov 27",
    iconType: "ice_pack",
    status: "pending",
  ),
  ReminderModel(
    id: 3,
    title: "Oral Hygiene Check",
    description: "Evening teeth brushing and flossing routine. Ensure comprehensive coverage.",
    time: "09:30 PM",
    date: "Today, Nov 27",
    iconType: "hygiene",
    status: "pending",
  ),
  ReminderModel(
    id: 4,
    title: "Prescription Refill",
    description: "Don't forget to refill your prescription for Fluoride Mouthwash.",
    time: "Anytime",
    date: "Due Dec 05",
    iconType: "refill",
    status: "flexible",
  ),
];