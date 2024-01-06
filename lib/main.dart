import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:real_time_signal_strength_checker/Screens/admin_page.dart';
import 'package:real_time_signal_strength_checker/Screens/opening_screen.dart';
import 'package:real_time_signal_strength_checker/Screens/register_screen.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location and phone state permissions
  await requestPermissions();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  // Request location permission
  var status = await Permission.location.request();
  if (status.isDenied) {
    ScaffoldMessenger.of(navigatorKey.currentContext!)
        .showSnackBar(const SnackBar(
      content: Text(
          "This app needs location permission to function properly,Please provide it manually"),
      duration: Duration(seconds: 2),
    ));
    print('Location permission is denied');
  }

  // Request phone state permission
  status = await Permission.phone.request();
  if (status.isDenied) {
    ScaffoldMessenger.of(navigatorKey.currentContext!)
        .showSnackBar(const SnackBar(
      content: Text(
          "This app needs phone state permission to function properly,Please provide it manually"),
      duration: Duration(seconds: 2),
    ));
    print('Phone state permission is denied');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: TextTheme(
            bodyLarge: GoogleFonts.notoSans(),
            bodySmall: GoogleFonts.notoSans(),
            bodyMedium: GoogleFonts.notoSans()),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return const AdminPage();
          } else {
            return const RegisterScreen();
          }
        },
      ),
    );
  }
}
