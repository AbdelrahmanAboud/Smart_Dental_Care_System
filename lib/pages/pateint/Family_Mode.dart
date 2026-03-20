import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class FamilyMember {
  final String id;
  final String name;
  final String relation;
  final int age;
  final String gender;
  final String bloodGroup;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    required this.gender,
    required this.bloodGroup,
  });
}

class FamilyScreen extends StatefulWidget {
  @override
  _FamilyScreenState createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);

  final List<String> relations = [
    "Son",
    "Daughter",
    "Father",
    "Mother",
    "Wife",
    "Husband",
  ];
  final List<String> genders = ["Male", "Female"];
  final List<String> bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "O+",
    "O-",
    "AB+",
    "AB-",
  ];

  CollectionReference get familyRef => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('family');

  void _showMemberDialog({FamilyMember? member}) {
    final _nameController = TextEditingController(text: member?.name ?? "");
    final _ageController = TextEditingController(
      text: member?.age.toString() ?? "",
    );
    String selectedRelation = member?.relation ?? relations[0];
    String selectedGender = member?.gender ?? genders[0];
    String selectedBlood = member?.bloodGroup ?? bloodGroups[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                member == null ? "Add Family Member" : "Edit Details",
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(_nameController, "Full Name", Icons.person),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _ageController,
                            "Age",
                            Icons.cake,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildDropdown(
                            "Blood",
                            selectedBlood,
                            bloodGroups,
                            (val) => setDialogState(() => selectedBlood = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      "Relation",
                      selectedRelation,
                      relations,
                      (val) => setDialogState(() => selectedRelation = val!),
                    ),
                    const SizedBox(height: 15),
                    _buildDropdown(
                      "Gender",
                      selectedGender,
                      genders,
                      (val) => setDialogState(() => selectedGender = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_nameController.text.isEmpty ||
                        _ageController.text.isEmpty)
                      return;

                    Map<String, dynamic> data = {
                      'name': _nameController.text.trim(),
                      'relation': selectedRelation,
                      'gender': selectedGender,
                      'bloodGroup': selectedBlood,
                      'age': int.parse(_ageController.text.trim()),
                      'updatedAt': FieldValue.serverTimestamp(),
                    };

                    if (member == null) {
                      await familyRef.add(data);
                    } else {
                      await familyRef.doc(member.id).update(data);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    member == null ? "Add" : "Save",
                    style: TextStyle(
                      color: bgColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Family Members",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.transparent,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
          ),
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0B1C2D)),
          label: const Text(
            "Add New Member",
            style: TextStyle(
              color: Color(0xFF0B1C2D),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onPressed: () => _showMemberDialog(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder<QuerySnapshot>(
          stream: familyRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                FamilyMember member = FamilyMember(
                  id: doc.id,
                  name: data['name'] ?? '',
                  relation: data['relation'] ?? '',
                  age: data['age'] ?? 0,
                  gender: data['gender'] ?? '',
                  bloodGroup: data['bloodGroup'] ?? '',
                );
                return _buildMemberCard(member);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: primaryBlue.withOpacity(0.1),
          child: Icon(
            member.gender == "Male" ? Icons.face : Icons.face_3,
            color: primaryBlue,
            size: 30,
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Row(
              children: [
                _buildBadge(member.relation, primaryBlue),
                const SizedBox(width: 8),
                _buildBadge(member.bloodGroup, Colors.redAccent),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${member.age} Years Old",
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          color: cardColor,
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text("Edit", style: TextStyle(color: Colors.white)),
              onTap: () => Future.delayed(
                Duration.zero,
                () => _showMemberDialog(member: member),
              ),
            ),
            PopupMenuItem(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => familyRef.doc(member.id).delete(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryBlue.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: primaryBlue, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: cardColor,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: primaryBlue.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            color: Colors.white.withOpacity(0.05),
            size: 100,
          ),
          const SizedBox(height: 20),
          Text(
            "No members added yet",
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}
