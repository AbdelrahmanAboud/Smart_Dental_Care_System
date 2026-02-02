import 'package:flutter/material.dart';

class RecordsPage extends StatelessWidget {
  final Color bgColor = const Color(0xFF0B1C2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text(
          "Records",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Records Page Content", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
