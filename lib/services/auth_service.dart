import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> sendOTP({required String email, required String otpCode}) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: json.encode({
          'service_id': 'service_u1rzxxn',
          'template_id': 'template_t8p3sxp',
          'user_id': 'J3QBUJ9LUs-OEmcLk',
          'template_params': {'user_email': email, 'otp_code': otpCode},
        }),
      );
      if (response.statusCode == 200) {
        print("Success! Email sent successfully to the mobile device.");
        return true;
      } else {
        print(" Server Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print(" Connection Error (Check internet or permissions): $e");
      return false;
    }
  }

  Future<User?> signUp(
    String email,
    String password,
    Function(String) showError,
  ) async {
    try {
      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showError("This email is already registered. Try logging in instead.");
      } else if (e.code == 'weak-password') {
        showError("Password is too weak. Please use at least 6 characters.");
      } else if (e.code == 'invalid-email') {
        showError("The email address is invalid. Please check and try again.");
      } else {
        showError(e.message ?? "Authentication failed. Please try again.");
      }
    } catch (e) {
      showError("An unexpected error occurred. Please try again.");
    }
    return null;
  }

  Future<User?> login(
    String email,
    String password,
    Function(String) showError,
  ) async {
    try {
      UserCredential result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showError("Invalid email or password. Please try again.");
      } else {
        showError("Login failed: ${e.message}");
      }
      return null;
    } catch (e) {
      showError("An unexpected error occurred.");
      return null;
    }
  }

  Future<User?> signUpWithGoogle(Function(String) showError) async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      bool isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (!isNewUser) {
        await GoogleSignIn().signOut();
        await auth.signOut();
        showError(
          "This email is already registered. Please go to the Login page.",
        );
        return null;
      }
      return result.user;
    } catch (e) {
      showError("An error occurred during Google Sign Up.");
      return null;
    }
  }

  Future<User?> signInWithGoogleForLogin(Function(String) showError) async {
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      bool isNewUser = result.additionalUserInfo?.isNewUser ?? false;

      if (isNewUser) {
        await result.user?.delete();
        await auth.signOut();
        await GoogleSignIn().signOut();
        showError("This account doesn't exist. Please sign up first.");
        return null;
      }
      return result.user;
    } catch (e) {
      showError("An error occurred during Google login.");
      return null;
    }
  }
}
