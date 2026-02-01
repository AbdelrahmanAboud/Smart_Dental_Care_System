import 'package:flutter/material.dart';

// موديل الخدمات الفرعية داخل كل فاتورة
class ServiceItem {
  final String name;
  final double price;

  ServiceItem({required this.name, required this.price});
}

// الموديل الأساسي للسجلات المالية
class FinancialRecord {
  final String title;
  final String date;
  final List<ServiceItem> items; // شيلنا الـ subTitle والـ amount القدام
  final IconData icon;
  final Color iconColor;
  final bool isInvoice;

  FinancialRecord({
    required this.title,
    required this.date,
    this.items = const [], // ضفنا قيمة افتراضية عشان نمنع الـ Null Error
    required this.icon,
    required this.iconColor,
    this.isInvoice = true,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.price);
}

final List<FinancialRecord> financialrecord = [
  // موعد Oct 26, 2023
  FinancialRecord(
    title: "Invoice",
    date: "Oct 26, 2023",
    icon: Icons.attach_money,
    iconColor: Colors.deepPurpleAccent,
    items: [
      ServiceItem(name: "Routine Check-up", price: 50.0),
      ServiceItem(name: "Consultation Fee", price: 45.0),
      ServiceItem(name: "Routine Check-up", price: 50.0),
      ServiceItem(name: "Consultation Fee", price: 45.0),
      ServiceItem(name: "Routine Check-up", price: 50.0),
      ServiceItem(name: "Consultation Fee", price: 45.0),
    ],
  ),
  // موعد Sep 14, 2023
  FinancialRecord(
    title: "Invoice",
    date: "Sep 14, 2023",
    icon: Icons.attach_money,
    iconColor: Colors.deepPurpleAccent,
    items: [
      ServiceItem(name: "Professional Cleaning", price: 120.0),
    ],
  ),
  // موعد Aug 02, 2023
  FinancialRecord(
    title: "Invoice",
    date: "Aug 02, 2023",
    icon: Icons.attach_money,
    iconColor: Colors.deepPurpleAccent,
    items: [
      ServiceItem(name: "Composite Filling", price: 150.0),
      ServiceItem(name: "Dental X-Ray", price: 30.0),
    ],
  ),
  // موعد Jul 18, 2023 (Treatment Plan)
  FinancialRecord(
    title: "Treatment Plan",
    date: "Jul 18, 2023",
    isInvoice: false,
    icon: Icons.assignment_outlined,
    iconColor: Colors.orangeAccent,
    items: [
      ServiceItem(name: "Root Canal Therapy", price: 500.0),
      ServiceItem(name: "Root Canal Therapy", price: 500.0),
      ServiceItem(name: "Root Canal Therapy", price: 500.0),
      ServiceItem(name: "Root Canal Therapy", price: 500.0),
      ServiceItem(name: "Root Canal Therapy", price: 500.0),
      ServiceItem(name: "Root Canal Therapy", price: 500.0),
    ],
  ),
  // موعد Jun 05, 2023
  FinancialRecord(
    title: "Invoice",
    date: "Jun 05, 2023",
    icon: Icons.attach_money,
    iconColor: Colors.deepPurpleAccent,
    items: [
      ServiceItem(name: "Full Mouth X-Ray", price: 150.0),
    ],
  ),
];