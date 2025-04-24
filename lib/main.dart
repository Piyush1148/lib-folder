import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:furnituresapp/screens/product/products_screen.dart';
import 'package:furnituresapp/screens/signup.dart';
import 'package:furnituresapp/screens/login.dart';
import 'package:furnituresapp/screens/forgot_password.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:furnituresapp/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furniture App',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primaryColor: kPrimaryColor,
        hintColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Use SplashScreen as initial screen
      routes: {
        '/login': (context) => LogIn(),
        '/signup': (context) => SignUp(),
        '/forgot_password': (context) => ForgotPassword(),
        '/products': (context) => ProductsScreen(),
      },
    );
  }
}

// Keep the AuthFlow class for reference, but it's not used as home anymore
class AuthFlow extends StatelessWidget {
  const AuthFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return ProductsScreen(); // User is logged in, navigate to main app
        } else {
          return LogIn(); // User is not logged in, show login screen
        }
      },
    );
  }
}