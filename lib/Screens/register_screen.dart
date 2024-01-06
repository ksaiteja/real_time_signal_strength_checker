import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_time_signal_strength_checker/Screens/color_constants.dart';
import 'package:real_time_signal_strength_checker/Screens/login_screen.dart';
import 'package:real_time_signal_strength_checker/main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String errorMessage = '';

  Future<void> _handleRegistration() async {
    try {
      // Check if passwords match
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        setState(() {
          errorMessage = 'Passwords do not match.';
        });
        return;
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // If registration is successful, you can access user information via userCredential.user
      print('Registration successful: ${userCredential.user?.email}');

      // Store full name in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'fullName': fullNameController.text.trim(),
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));

      // Clear any previous error message
      setState(() {
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      String errorText = '';
      if (e.code == 'weak-password') {
        errorText = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorText = 'The account already exists for that email.';
      } else {
        errorText = 'Error: ${e.message}';
      }

      // Set the error message in the state
      setState(() {
        errorMessage = errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 80),
              const Text(
                'Get Started',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'By creating a free account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),
              buildInputField('Full Name', Icons.person, fullNameController),
              const SizedBox(height: 20),
              buildInputField('Valid email', Icons.email, emailController),
              const SizedBox(height: 20),
              buildInputField('Strong Password', Icons.lock, passwordController,
                  obscureText: true),
              const SizedBox(height: 20),
              buildInputField(
                'Confirm Password',
                Icons.lock,
                confirmPasswordController,
              ),
              const SizedBox(height: 10),
              const Spacer(),
              Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 5),
              buildLoginButton(),
              const SizedBox(height: 30),
              buildLoginRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField(
      String hintText, IconData iconData, TextEditingController controller,
      {bool obscureText = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorConstants.input_field,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: Icon(iconData, color: Colors.grey),
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        obscureText: obscureText,
      ),
    );
  }

  Widget buildLoginButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        ),
        onPressed: () {
          _handleRegistration();
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoginRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Already a Member? ',
            style: TextStyle(color: Colors.grey),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: Text(
              'Log In',
              style: TextStyle(
                color: ColorConstants.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
