import 'package:flutter/material.dart';
import 'dart:async'; // For the Timer function
import 'home_page.dart'; // Import the main page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RFID Tag Check',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Splash screen as the initial page
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Show the splash screen for 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(), // Redirect to your main page
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/regulus.png'), // Your logo image
            fit: BoxFit.cover, // Make the image cover the entire screen
          ),
        ),
        child: Center(
          // You can place any widgets here, e.g., a loading indicator
          child: CircularProgressIndicator(
            color: Colors.white, // Optional: change the color of the loading indicator
          ),
        ),
      ),
    );
  }
}
