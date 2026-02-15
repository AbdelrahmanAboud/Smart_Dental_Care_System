import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_dental_care_system/main.dart';
import 'package:smart_dental_care_system/pages/pateint/BookingPage.dart';
import 'package:smart_dental_care_system/pages/pateint/Family_Mode.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Feedback%20.dart';

final Color bgColor = const Color(0xFF06101E);
final Color cardColor = const Color(0xFF102136);
final Color primaryBlue = const Color(0xFF2EC4FF);

class PateintProfile extends StatefulWidget {
  @override
  State<PateintProfile> createState() => _PateintProfileState();
}

class _PateintProfileState extends State<PateintProfile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    setState(() {
      userData = doc.data() as Map<String, dynamic>;
      isLoading = false;
    });
  }

  Future<void> uploadAndSaveImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
      ),
    );

    try {
      String cloudName = "ddrjzbrwp";
      String uploadPreset = "Smart Dental Care System";

      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");
      var request = http.MultipartRequest("POST", uri);

      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      request.fields['upload_preset'] = uploadPreset;

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        String url = jsonResponse['secure_url'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"profileImage": url});

        Navigator.pop(context);
        fetchData();
        print("Upload successful: $url");
      } else {
        Navigator.pop(context);

        print("Upload failed: ${jsonResponse['error']['message']}");
      }
    } catch (e) {
      Navigator.pop(context);

      print("Connection error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> dataToEncode = Map.from(userData ?? {});

    if (dataToEncode.containsKey('createdAt') &&
        dataToEncode['createdAt'] is Timestamp) {
      dataToEncode['createdAt'] = dataToEncode['createdAt'].toDate().toString();
    }

    String qrData = jsonEncode(dataToEncode);
    String imageUrl = userData?['profileImage'] ?? "";

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: imageUrl.isEmpty
                        ? const CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              "lib/assets/user_logo.png",
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: userData?['profileImage'] ?? "",
                            imageBuilder: (context, imageProvider) =>
                                CircleAvatar(
                                  radius: 65,
                                  backgroundImage: imageProvider,
                                ),

                            placeholder: (context, url) => CircleAvatar(
                              radius: 65,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryBlue,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFF5F5F5),
                                  radius: 65,
                                  backgroundImage: AssetImage(
                                    'assets/default_user.png',
                                  ),
                                ),
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        uploadAndSaveImage();
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: cardColor, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),
            Text(
              userData?["name"] ?? " Loading...",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Patient ID: ${userData?["id"] ?? "---"}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),

            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personal Information",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 25),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Email  ",
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            userData?["email"] ?? "-",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Age",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          userData?["age"] ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Blood Type",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          userData?["bloodType"] ?? "-",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Phone",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          userData?["phone"] ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date of Birth",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          userData?["dob"] ?? "-",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF00D2FF),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                TextEditingController ageController =
                                    TextEditingController(
                                      text: userData?["age"],
                                    );
                                TextEditingController phoneController =
                                    TextEditingController(
                                      text: userData?["phone"],
                                    );
                                TextEditingController bloodController =
                                    TextEditingController(
                                      text: userData?["bloodType"],
                                    );
                                TextEditingController dobController =
                                    TextEditingController(
                                      text: userData?["dob"],
                                    );

                                return AlertDialog(
                                  backgroundColor: const Color(0xFF102136),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  title: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF00E5FF,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.edit_note_rounded,
                                          color: Color(0xFF00E5FF),
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        "Update Profile",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(height: 15),
                                        TextField(
                                          controller: ageController,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.calendar_today,
                                              color: primaryBlue,
                                              size: 20,
                                            ),
                                            labelText: "Age",
                                            labelStyle: TextStyle(
                                              color: Colors.grey,
                                            ),
                                            filled: true,
                                            fillColor: Color(0xFF06101E),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        TextField(
                                          controller: bloodController,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.bloodtype,
                                              color: primaryBlue,
                                              size: 20,
                                            ),
                                            labelText: "Blood Type",
                                            labelStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF06101E),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        TextField(
                                          controller: phoneController,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.phone,
                                              color: primaryBlue,
                                              size: 20,
                                            ),
                                            labelText: "Phone",
                                            labelStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF06101E),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        TextField(
                                          controller: dobController,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.event,
                                              color: primaryBlue,
                                              size: 20,
                                            ),
                                            labelText: "Date of Birth",
                                            labelStyle: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFF06101E),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide(
                                                color: primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actionsPadding: const EdgeInsets.fromLTRB(
                                    15,
                                    0,
                                    15,
                                    20,
                                  ),
                                  actions: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryBlue,

                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              "Save",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) => Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: primaryBlue,
                                                      ),
                                                ),
                                              );

                                              try {
                                                String uid = FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid;
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(uid)
                                                    .update({
                                                      "age": ageController.text,
                                                      "phone":
                                                          phoneController.text,
                                                      "bloodType":
                                                          bloodController.text,
                                                      "dob": dobController.text,
                                                    });

                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                fetchData();
                                              } catch (e) {
                                                Navigator.pop(context);
                                                print("Error: $e");
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.edit, size: 24),
                              SizedBox(width: 10),
                              Text(
                                "Update Information ",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 70),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.circle,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.circle,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(15.0),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PatientFeedback(),
                      ),
                    );
                  },

                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(
                          Icons.star_border,
                          size: 25,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Share Feedback",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Help us improve our service",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PatientFeedback(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15.0, right: 15),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 2,
                    ),
                  ],
                ),

                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => FamilyScreen()),
                    );
                  },

                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(
                          Icons.family_restroom,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Family mode",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FamilyScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
