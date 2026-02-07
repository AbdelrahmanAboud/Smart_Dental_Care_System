import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

// Model Class لكل عضو
class FamilyMember {
  String id;
  String name;
  String relation;
  int age; // بدل DOB خليها سن مباشرة
  String gender;
  Uint8List? profileImage; // بدل File عشان Web يشتغل

  FamilyMember({
    required this.id,
    required this.name,
    required this.relation,
    required this.age,
    required this.gender,
    this.profileImage,
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

  final picker = ImagePicker();

  int _idCounter = 1; 

  List<FamilyMember> familyMembers = [];

  final List<String> relations = ["Son", "Daughter", "Father", "Mother"];
  final List<String> genders = ["Male", "Female", "Other"];

  void _showMemberDialog({FamilyMember? member, int? index}) {
    final _nameController = TextEditingController(text: member?.name ?? "");
    String selectedRelation = member?.relation ?? relations[0];
    String selectedGender = member?.gender ?? genders[0];
    int? selectedAge = member?.age;
    Uint8List? profileImage = member?.profileImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              member == null ? "Add Family Member" : "Edit Family Member",
              style: TextStyle(color: primaryBlue),
            ),
            content: SingleChildScrollView(
              child: Column(
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
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedRelation,
                    dropdownColor: cardColor,
                    decoration: InputDecoration(
                      labelText: "Relation",
                      labelStyle: TextStyle(color: primaryBlue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    items: relations
                        .map((rel) => DropdownMenuItem(
                      value: rel,
                      child: Text(rel),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedRelation = val);
                    },
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    dropdownColor: cardColor,
                    decoration: InputDecoration(
                      labelText: "Gender",
                      labelStyle: TextStyle(color: primaryBlue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    items: genders
                        .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedGender = val);
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
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
                    onChanged: (val) {
                      int? ageVal = int.tryParse(val);
                      if (ageVal != null) setDialogState(() => selectedAge = ageVal);
                    },
                  ),
                  SizedBox(height: 10),
                ElevatedButton.icon(
  onPressed: () async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setDialogState(() {
        profileImage = bytes;
      });
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white.withOpacity(0.05), 
    foregroundColor: primaryBlue, 
    side: BorderSide(color: primaryBlue.withOpacity(0.5)), 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  ),
  icon: Icon(Icons.camera_alt_outlined, size: 20),
  label: Text("Select Photo", style: TextStyle(fontWeight: FontWeight.w600)),
),
                  if (profileImage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CircleAvatar(
                        radius: 50,
                    backgroundImage: MemoryImage(profileImage!),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: primaryBlue)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                onPressed: () {
                  String name = _nameController.text.trim();
                  if (name.isEmpty || selectedAge == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill all fields")));
                    return;
                  }

                  setState(() {
                    if (member == null) {
                      familyMembers.add(FamilyMember(
                        id: _idCounter.toString(),
                        name: name,
                        relation: selectedRelation,
                        gender: selectedGender,
                        age: selectedAge!,
                        profileImage: profileImage,
                      ));
                      _idCounter++;
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Member Added")));
                    } else {
                      familyMembers[index!] = FamilyMember(
                        id: member.id,
                        name: name,
                        relation: selectedRelation,
                        gender: selectedGender,
                        age: selectedAge!,
                        profileImage: profileImage,
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text("Member Updated")));
                    }
                  });

                  Navigator.pop(context);
                },
                child: Text(member == null ? "Add" : "Update",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  void _deleteMember(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text("Delete Member", style: TextStyle(color: primaryBlue)),
          content: Text(
            "Are you sure you want to delete ${familyMembers[index].name}?",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: primaryBlue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                setState(() => familyMembers.removeAt(index));
                Navigator.pop(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("Member Deleted")));
              },
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMemberCard(FamilyMember member, int index) {
    IconData genderIcon;
    Color iconColor;
    switch (member.gender) {
      case "Male":
        genderIcon = Icons.male;
        iconColor = Colors.blueAccent;
        break;
      case "Female":
        genderIcon = Icons.female;
        iconColor = Colors.pinkAccent;
        break;
      default:
        genderIcon = Icons.person;
        iconColor = Colors.grey;
    }

    return Card(
      color: cardColor,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor,
          backgroundImage:
          member.profileImage != null ? MemoryImage(member.profileImage!) : null,
          child: member.profileImage == null
              ? Icon(genderIcon, color: Colors.white)
              : null,
        ),
        title: Text(member.name,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${member.relation} • ${member.age} yrs",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 2),
            Text(
              "ID: ${member.id}",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () => _showMemberDialog(member: member, index: index),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _deleteMember(index),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Family Members", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: bgColor,
        elevation: 0,

        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
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
              onPressed: () => _showMemberDialog(),
            ),
            SizedBox(height: 12),
            Expanded(

              child: familyMembers.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_add_outlined, color: Colors.white10, size: 100),
              SizedBox(height: 16),
              Text(
                "No family members yet.\nStart by adding one!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            ],
          ),
        ):ListView.builder(
                itemCount: familyMembers.length,
                itemBuilder: (context, index) {
                  return _buildMemberCard(familyMembers[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}