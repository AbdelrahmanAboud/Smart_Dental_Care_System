import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_dental_care_system/pages/doctor/Doctor_Dashboard.dart';
import 'package:smart_dental_care_system/pages/pateint/Patient_Home.dart';
import 'package:smart_dental_care_system/pages/receptionist/Receptionist_Dashboard.dart';
import 'package:smart_dental_care_system/services/auth_service.dart';
import 'package:smart_dental_care_system/services/database_service.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final String password;
  final String name;
  final String age;
  final String role;
  final String correctOTP;

  const OTPScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.role,
    required this.correctOTP,
  });
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  void verifyAndSignUp() async {
    if (pinController.text == widget.correctOTP) {
      setState(() => isLoading = true);

      try {
        AuthService authService = AuthService();
        var user = await authService.signUp(
          widget.email,
          widget.password,
          (error) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error))),
        );

        if (user != null) {
          await DatabaseService().saveUserData(
            uid: user.uid,
            name: widget.name,
            age: widget.age,
            email: widget.email,
            role: widget.role,
          );
          if (!mounted) return;
          if (widget.role.trim().toLowerCase() == 'doctor') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => DoctorDashboard()),
              (route) => false,
            );
          } else if (widget.role.trim().toLowerCase() == 'patient') {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => PatientHome()),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ReceptionistDashboard()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registration Failed!")));
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP Code!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: Color(0xFF0077b6),
            ),
            const SizedBox(height: 20),
            Text(
              "We sent a code to ${widget.email}",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            Pinput(
              length: 6,
              controller: pinController,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 55,
                textStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onCompleted: (pin) => verifyAndSignUp(),
            ),

            SizedBox(height: 30),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyAndSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0077b6),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      "Verify & Register",
                      style: TextStyle(color: Colors.white),
                    ),
           ),
          ],
        ),
      ),
    );
  }
}
