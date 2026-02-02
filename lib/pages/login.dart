import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smart_dental_care_system/pages/register.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  bool patientSelected = true;
  bool doctorSelected = false;
  bool receptionistSelected = false;
  bool isObscure = true;
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
                  // Patient Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        patientSelected = true;
                        doctorSelected = false;
                        receptionistSelected = false;
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
                color: const Color.fromARGB(255, 13, 12, 12), // لون الخط
                thickness: 2, // سمك الخط
                indent: 20, // مسافة البداية من اليسار
                endIndent: 20, // مسافة النهاية من اليمين
              ),
              SizedBox(height: 15),

              Padding(
                padding: EdgeInsets.only(left: 12.0, right: 12.0),
                child: TextFormField(
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
                    onPressed: () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                    Register()
                
                )
                );
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
                          onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:  [
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
              // Text.rich(
              //   textAlign: TextAlign.center,
              //   TextSpan(
              //     style: TextStyle(color: Color(0xFFA0AAB8), fontSize: 12),
              //     children: [
              //       TextSpan(text: "By logging in, you agree to our "),
              //       TextSpan(
              //         text: "Terms of Service",
              //         style: TextStyle(
              //           color: Color(0xFF00CCFF),
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //       TextSpan(text: " and "),
              //       TextSpan(
              //         text: "Privacy Policy",
              //         style: TextStyle(
              //           color: Color(0xFF00CCFF),
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //       TextSpan(text: "."),
              //     ],
              //   ),
              // ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
