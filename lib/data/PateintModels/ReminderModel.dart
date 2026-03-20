import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime; 
  final String iconType;
  final bool isDone;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    required this.iconType,
    required this.isDone,
  });

  factory ReminderModel.fromMap(String docId, Map<String, dynamic> map) {
    return ReminderModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      iconType: map['iconType'] ?? 'bell',
      isDone: map['isDone'] ?? false,
    );
  }
}