import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:real_time_signal_strength_checker/Screens/color_constants.dart';
import 'package:real_time_signal_strength_checker/Screens/register_screen.dart';
import 'package:real_time_signal_strength_checker/main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String errorMessage = '';

  Future<void> _handleLogin() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // If login is successful, you can access user information via userCredential.user
      print('Login successful: ${userCredential.user?.email}');

      // Clear any previous error message
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
      setState(() {
        errorMessage = '';
      });
    } on FirebaseAuthException catch (e) {
      String errorText = '';
      if (e.code == 'user-not-found') {
        errorText = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorText = 'Wrong password provided for that user.';
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
                'Welcome back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in to access your account',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 100),
              buildInputField('Enter your email', Icons.email, emailController),
              const SizedBox(height: 20),
              buildInputField('Password', Icons.lock, passwordController,
                  obscureText: true),
              const SizedBox(height: 10),
              buildRememberMeRow(),
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
              buildRegisterNowRow(),
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
        borderRadius: BorderRadius.circular(5.0),
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

  Widget buildRememberMeRow() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: false,
          onChanged: (value) {},
          activeColor: ColorConstants.primary,
        ),
        const Text('Remember me', style: TextStyle(color: Colors.grey)),
        const Spacer(),
        Text('Forget password?',
            style: TextStyle(color: ColorConstants.primary)),
      ],
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
          _handleLogin();
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

  Widget buildRegisterNowRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'New Member? ',
            style: TextStyle(color: Colors.grey),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()));
            },
            child: Text(
              'Register now',
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
