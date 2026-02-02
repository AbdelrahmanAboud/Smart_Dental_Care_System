import 'package:flutter/material.dart';
import 'package:untitled1/register.dart';

import 'NavBar.dart';
import 'login.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Register Page",
      home: Login(),
    ),
  );
}
