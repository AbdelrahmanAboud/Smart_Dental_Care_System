import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/OTPScreen.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Dashboard.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Home.dart';
import 'package:smart_dental_care_system/pages/pateint/navigation_bar.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Dashboard.dart';
import 'package:smart_dental_care_system/services/auth_service.dart';
import 'package:smart_dental_care_system/services/database_service.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final Color bgColor = const Color(0xFF0B1C2D);
  final Color cardColor = const Color(0xFF112B3C);
  final Color primaryBlue = const Color(0xFF2EC4FF);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController ConfirmPasswordController =
      TextEditingController();
  final TextEditingController accessCodeController = TextEditingController();
  final String doctorSecret = "DOC123";
  final String receptionistSecret = "REC456";
  String selectedRole = "Patient";
  bool isPasswordObscure = true;
  bool isConfirmPasswordObscure = true;
  String? selectedBloodType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Container(
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

              const SizedBox(height: 20),

              const Text(
                "Choose your role",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  roleCard("Patient", Icons.person),
                  roleCard("Doctor", FontAwesomeIcons.stethoscope),
                  roleCard("Receptionist", Icons.business_center_outlined),
                ],
              ),

              SizedBox(height: 15),
              Divider(
                color: const Color.fromARGB(255, 13, 12, 12),
                thickness: 2,
                indent: 20,
                endIndent: 20,
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Full name...",
                    labelText: "Full Name",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 16),
                    prefixIcon: Icon(Icons.person, color: Colors.grey),

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
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: TextFormField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter your age...",
                    labelText: "Age",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.cake, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Age is required";
                    }
                    final age = int.tryParse(value);
                    if (age == null) {
                      return "Enter a valid number";
                    }
                    if (age < 1 || age > 120) {
                      return "Enter a valid age";
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextFormField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter your email...",
                    labelText: "Email",
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
                  obscureText: isPasswordObscure,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "Enter your password...",
                    labelText: "Password",

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
                          isPasswordObscure = !isPasswordObscure;
                        });
                      },
                      icon: Icon(
                        isPasswordObscure
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextFormField(
                  controller: ConfirmPasswordController,
                  obscureText: isConfirmPasswordObscure,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: "confirm your password...",
                    labelText: "confirm Password",

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
                          isConfirmPasswordObscure = !isConfirmPasswordObscure;
                        });
                      },
                      icon: Icon(
                        isConfirmPasswordObscure
                            ? Icons.visibility
                            : Icons.visibility_off,
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
              Visibility(
                visible: selectedRole != "Patient", 
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 15,
                  ),
                  child: TextFormField(
                    controller: accessCodeController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Enter Authorization Code...",
                      labelText: "Security Code",
                      labelStyle:  TextStyle(color: Colors.grey),
                      prefixIcon:  Icon(
                        Icons.verified_user,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
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
  String name = nameController.text.trim();
  String age = ageController.text.trim();
  String email = emailController.text.trim();
  String pass = passwordController.text.trim();
  String confirmpass = ConfirmPasswordController.text.trim();
  String enteredCode = accessCodeController.text.trim();

  if (name.isEmpty || email.isEmpty || pass.isEmpty || age.isEmpty) {
    showError("Please fill in all fields!");
    return;
  }
  if (selectedRole != "Patient") {
    String requiredCode = (selectedRole == "Doctor")
        ? doctorSecret
        : receptionistSecret;
    if (enteredCode != requiredCode) {
      showError("Unauthorized! Invalid code for $selectedRole registration.");
      return;
    }
  }

  if (!email.contains('@')) {
    showError("Please enter a valid email address!");
    return;
  }
  if (pass.length < 6) {
    showError("Password must be at least 6 characters!");
    return;
  }
  if (pass != confirmpass) {
    showError("Passwords do not match!");
    return;
  }

  
  showLoading(context); 

  try {
    String generatedOtp = (Random().nextInt(900000) + 100000).toString();

    AuthService authService = AuthService();
    bool isSent = await authService.sendOTP(
      email: email,
      otpCode: generatedOtp,
    );

    if (context.mounted) Navigator.pop(context); 

    if (isSent) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            email: email,
            password: pass,
            name: name,
            age: age,
            role: selectedRole,
            correctOTP: generatedOtp,
          ),
        ),
      );
    } else {
      showError("Failed to send verification email. Please try again.");
    }

  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    showError("An unexpected error occurred. Please try again.");
  }
},

                    child: Text(
                      "Signup ",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
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
                      "OR Sign up with",
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

  if (selectedRole != "Patient") {
    String enteredKey = "";
    String requiredCode = (selectedRole == "Doctor") ? doctorSecret : receptionistSecret;

    bool isAuthorized = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Security Verification", style: TextStyle(color: primaryBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter the secret key for $selectedRole", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 15),
            TextField(
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Secret Key",
                hintStyle: const TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryBlue)),
              ),
              onChanged: (value) => enteredKey = value.trim(),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text("Verify", style: TextStyle(color: Colors.black)),
            onPressed: () {
              if (enteredKey == requiredCode) {
                Navigator.pop(context, true);
              } else {
                showError("Wrong Secret Key!");
              }
            },
          ),
        ],
      ),
    ) ?? false;

    if (!isAuthorized) return;
  }

  showLoading(context);
  try {
    AuthService authService = AuthService();
    User? user = await authService.signUpWithGoogle(showError);

    if (user != null) {
  
      await DatabaseService().saveUserData(
        uid: user.uid,
        name: nameController.text.trim().isEmpty ? (user.displayName ?? "User") : nameController.text.trim(),
        age: " ",
        email: user.email ?? "",
        role: selectedRole,
      );

      if (context.mounted) {
        Navigator.pop(context); 

        if (selectedRole == 'Doctor') {
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>DoctorDashboard()));
        } else if (selectedRole == 'Receptionist') {
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>ReceptionistDashboard()));
        } else {
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>PatientHome()));
        }
      }
    } else {
      if (context.mounted) Navigator.pop(context);
      showError("Google Sign-In was cancelled or failed.");
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    print("Error during Google Sign-In: $e"); 
    showError("Error: ${e.toString()}"); 
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
                            children: const [
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
                    "Already have an account?  ",
                    style: TextStyle(color: Color(0xFFA0AAB8), fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF00CCFF),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget roleCard(String role, IconData icon) {
    bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: isSelected ? cardColor : Color(0xFF141C2F),
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(width: 1, color: primaryBlue)
                : null,
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected ? primaryBlue : Colors.white70,
              ),
              const SizedBox(height: 8),
              Text(
                role,
                style: TextStyle(
                  color: isSelected ? primaryBlue : Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          Center(child: CircularProgressIndicator(color: Color(0xFF2EC4FF))),
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
}
