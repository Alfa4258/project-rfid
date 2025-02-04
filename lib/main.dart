import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'background_provider.dart';
import 'connection_provider.dart';
import 'timeout_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi

void main() {
  // Initialize sqflite for desktop platforms
  sqfliteFfiInit(); // Initialize the sqflite ffi package
  databaseFactory =
      databaseFactoryFfi; // Set the FFI database factory for SQLite

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BackgroundProvider()),
        ChangeNotifierProvider(
            create: (context) => ConnectionSettingsProvider()),
        ChangeNotifierProvider(create: (context) => TimeoutProvider()),
      ],
      child: MyApp(),
    ),
  );
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
      home: SplashScreen(),
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

    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
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
            image: AssetImage('assets/marathon.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
