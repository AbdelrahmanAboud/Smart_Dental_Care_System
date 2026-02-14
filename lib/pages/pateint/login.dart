import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Dashboard.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Home.dart';
import 'package:smart_dental_care_system/pages/pateint/Register.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Dashboard.dart';
import 'package:smart_dental_care_system/services/auth_service.dart';
import 'package:smart_dental_care_system/services/database_service.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool patientSelected = true;
  bool doctorSelected = false;
  bool receptionistSelected = false;
  bool isObscure = true;
  int index = 0;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1C2D),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.only(top: 50.0),

                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Color(0xFF2EC4FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    FontAwesomeIcons.stethoscope,
                    size: 48,
                    color: Colors.black,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsetsGeometry.all(30),
                child: Text(
                  "Chose your role",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        patientSelected = true;
                        doctorSelected = false;
                        receptionistSelected = false;
                        index = 0;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: patientSelected
                              ? Color(0xFF112B3C)
                              : Color(0xFF141C2F),
                          borderRadius: BorderRadius.circular(14),
                          border: patientSelected
                              ? Border.all(width: 1, color: Color(0xFF2EC4FF))
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2EC4FF).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: patientSelected
                                  ? Color(0xFF00AEEF)
                                  : Color(0xFFA0AAB8),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Patient",
                              style: TextStyle(
                                color: patientSelected
                                    ? Color(0xFF00CCFF)
                                    : Color(0xFFA0AAB8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Doctor Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        patientSelected = false;
                        doctorSelected = true;
                        receptionistSelected = false;
                        index = 1;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: doctorSelected
                              ? Color(0xFF112B3C)
                              : Color(0xFF141C2F),
                          borderRadius: BorderRadius.circular(14),
                          border: doctorSelected
                              ? Border.all(width: 1, color: Color(0xFF2EC4FF))
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2EC4FF).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.stethoscope,
                              color: doctorSelected
                                  ? Color(0xFF00AEEF)
                                  : Color(0xFFA0AAB8),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Doctor",
                              style: TextStyle(
                                color: doctorSelected
                                    ? Color(0xFF00CCFF)
                                    : Color(0xFFA0AAB8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Receptionist Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        patientSelected = false;
                        doctorSelected = false;
                        receptionistSelected = true;
                        index = 2;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: receptionistSelected
                              ? Color(0xFF112B3C)
                              : Color(0xFF141C2F),
                          borderRadius: BorderRadius.circular(14),
                          border: receptionistSelected
                              ? Border.all(width: 1, color: Color(0xFF2EC4FF))
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2EC4FF).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_center_outlined,
                              color: receptionistSelected
                                  ? Color(0xFF00AEEF)
                                  : Color(0xFFA0AAB8),
                              size: 28,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Receptionist",
                              style: TextStyle(
                                color: receptionistSelected
                                    ? Color(0xFF00CCFF)
                                    : Color(0xFFA0AAB8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(
                color: const Color.fromARGB(255, 13, 12, 12),
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 15),

              Padding(
                padding: EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter your ُEmail...",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                    prefixIcon: Icon(Icons.email, color: Colors.grey),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: isObscure,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter your password...",

                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 107, 105, 105),
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color.fromARGB(255, 107, 105, 105),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: Icon(
                        isObscure ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFFA0AAB8),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: Container(
                  width: 350,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Color(0xFF2EC4FF),
                      elevation: 20,
                      backgroundColor: Color(0xFF00AEEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      String email = emailController.text.trim();
                      String pass = passwordController.text.trim();

                      String selectedRole = "";
                      if (patientSelected)
                        selectedRole = "Patient";
                      else if (doctorSelected)
                        selectedRole = "Doctor";
                      else if (receptionistSelected)
                        selectedRole = "Receptionist";

                      if (email.isEmpty || pass.isEmpty) {
                        showError("Please fill all fields");
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            Center(child: CircularProgressIndicator()),
                      );

                      try {
                        AuthService authService = AuthService();
                        User? user = await authService.login(
                          email,
                          pass,
                          showError,
                        );

                        if (user != null) {
                          String? actualRole = await DatabaseService()
                              .getUserRole(user.uid);

                          Navigator.pop(context);

                          if (actualRole != null) {
                            if (actualRole == selectedRole) {
                              _navigateToDashboard(actualRole);
                            } else {
                              showError(
                                "Access Denied: You are registered as a $actualRole, not a $selectedRole.",
                              );
                            }
                          } else {
                            showError("User record not found in database.");
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        Navigator.pop(context);
                        showError("An unexpected error occurred.");
                      }
                    },
                    child: Text(
                      "Login ",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        endIndent: 10,
                      ),
                    ),
                    Text(
                      "OR Sign in with",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey,
                        thickness: 1,
                        indent: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            padding: EdgeInsets.zero,
                            backgroundColor: const Color(0xFF0B1C2D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            showLoading(context);

                            try {
                              User? user = await AuthService()
                                  .signInWithGoogleForLogin(showError);

                              if (user == null) {
                                if (context.mounted) Navigator.pop(context);
                                return;
                              }

                              if (context.mounted) {
                                var userDoc = await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .get();

                                if (context.mounted) Navigator.pop(context);

                                if (userDoc.exists) {
                                  String role = userDoc.get('role');

                                  if (role == 'Doctor') {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => DoctorDashboard(),
                                      ),
                                    );
                                  } else if (role == 'Receptionist') {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReceptionistDashboard(),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => PatientHome(),
                                      ),
                                    );
                                  }
                                } else {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => Register(),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              if (context.mounted) Navigator.pop(context);
                              showError("An unexpected error occurred.");
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.chrome,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Google",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            padding: EdgeInsets.zero,
                            backgroundColor: const Color(0xFF0B1C2D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                FontAwesomeIcons.apple,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Apple",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            padding: EdgeInsets.zero,
                            backgroundColor: const Color(0xFF0B1C2D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.facebookF,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Facebook",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Color(0xFFA0AAB8), fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text(
                      "Register Now",
                      style: TextStyle(
                        color: Color(0xFF00CCFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navigateToDashboard(String role) {
    Widget nextScreen;
    switch (role) {
      case 'Doctor':
        nextScreen = DoctorDashboard();
        break;
      case 'Receptionist':
        nextScreen = ReceptionistDashboard();
        break;
      default:
        nextScreen = PatientHome();
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => nextScreen));
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Color(0xFF2EC4FF))),
    );
  }
}
