import 'package:flutter/material.dart';

class FamilyScreen extends StatefulWidget {
  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);

  List<Map<String, String>> familyMembers = [
    {"name": "Emma Johnson", "relation": "Daughter", "age": "8 years old"},
    {"name": "Michael Johnson", "relation": "Son", "age": "12 years old"},
  ];

  void _showAddMemberDialog() {
    final _nameController = TextEditingController();
    final _relationController = TextEditingController();
    final _ageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text("Add Family Member", style: TextStyle(color: primaryBlue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(color: primaryBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _relationController,
                decoration: InputDecoration(
                  labelText: "Relation",
                  labelStyle: TextStyle(color: primaryBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: "Age",
                  labelStyle: TextStyle(color: primaryBlue),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: primaryBlue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _relationController.text.isNotEmpty &&
                    _ageController.text.isNotEmpty) {
                  setState(() {
                    familyMembers.add({
                      "name": _nameController.text,
                      "relation": _relationController.text,
                      "age": _ageController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Family Members',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add Member", style: TextStyle(color: Colors.white)),
              onPressed: _showAddMemberDialog,
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  final member = familyMembers[index];
                  return Card(
                    color: cardColor,
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryBlue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        member["name"]!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        "${member["relation"]} • ${member["age"]}",
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: cardColor,
                              title: Text(member["name"]!,
                                  style: TextStyle(color: primaryBlue)),
                              content: Text(
                                "Relation: ${member["relation"]}\nAge: ${member["age"]}",
                                style: TextStyle(color: Colors.white),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Close",
                                      style: TextStyle(color: primaryBlue)),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}