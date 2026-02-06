import 'package:flutter/material.dart';
import 'package:smart_dental_care_system/data/PateintModels/FinancialRecord.dart';

class VisitDetailsPage extends StatelessWidget {
  final String visitDate;

  const VisitDetailsPage({super.key, required this.visitDate});

  @override
  Widget build(BuildContext context) {
    final filteredRecords = financialrecord.where((f) => f.date == visitDate).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1C2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Visit Details", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Financials & Plans",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Record for visit on $visitDate",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredRecords.isEmpty
                ? const Center(
                    child: Text(
                      "No financial records for this date",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      return FinancialCard(filteredRecords[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

Widget FinancialCard(FinancialRecord record) {
  return Container(
    margin:  EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    decoration: BoxDecoration(
      color:  Color(0xFF112B3C),
      borderRadius: BorderRadius.circular(16),
    ),
    child: ExpansionTile(
      
      iconColor: Colors.white,
      collapsedIconColor: Colors.grey,
      shape:  RoundedRectangleBorder(side: BorderSide.none),
      collapsedShape:  RoundedRectangleBorder(side: BorderSide.none),
      leading: Container(
        padding:  EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: record.iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(record.icon, color: record.iconColor),
      ),
      title: Text(
        record.title,
        style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            record.isInvoice
                ? "\$${record.totalAmount.toStringAsFixed(2)}"
                : "Plan",
            style: TextStyle(
              color: record.isInvoice ?  Color(0xFF2EC4FF) : Colors.greenAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
           SizedBox(width: 8),
           Icon(Icons.expand_more, color: Colors.grey, size: 18),
        ],
      ),
      children: record.items.map((service) {
        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service.name,
                style:  TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                "\$${service.price.toStringAsFixed(2)}",
                style:  TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}