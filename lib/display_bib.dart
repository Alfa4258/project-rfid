import 'package:flutter/material.dart';
import 'api_service.dart'; // Import ApiService for searching BIBs again
import 'home_page.dart'; // Import HomePage for back navigation
import 'rfid_check_page.dart'; // Import RFIDTagCheckPage
import 'display_settings_page.dart'; // Import ChangeBackgroundPage

class BibDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bibDetails;
  final ApiService apiService = ApiService(); // Initialize ApiService

  BibDetailsPage({required this.bibDetails});

  @override
  _BibDetailsPageState createState() => _BibDetailsPageState();
}

class _BibDetailsPageState extends State<BibDetailsPage> {
  final TextEditingController _bibController =
      TextEditingController(); // Controller for the search bar
  Map<String, dynamic>? _currentBibDetails;

  @override
  void initState() {
    super.initState();
    _currentBibDetails =
        widget.bibDetails; // Initialize with the passed BIB details

    // Navigate back after a 3-second delay
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pop(
          context); // This pops the current page and returns to the previous page
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomePage when the back button is pressed
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false, // Remove all previous routes
        );
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        backgroundColor: Color(0xFFCDC4C4),
        body: Column(
          children: [
            // Top Section (takes up half the screen height)
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.grey[
                    200], // Change to whatever you want for the top section
                child: Center(
                    child: Text(
                  "${_currentBibDetails!['bib_number']}",
                  style: TextStyle(fontSize: 120),
                )),
              ),
            ),
            // Middle Section (smaller height section between top and bottom)
            // Bottom two sections (Left and Right side by side)
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  // Bottom Left Section
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.grey[400], // Change to suit
                      child: Center(
                          child: Text(
                              "${_currentBibDetails!['first_name']} ${_currentBibDetails!['last_name']}",
                              style: TextStyle(fontSize: 60))),
                    ),
                  ),
                  // Bottom Right Section
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.grey[500], // Change to suit
                      child: Center(
                          child: Text("${_currentBibDetails!['category']} Race",
                              style: TextStyle(fontSize: 60))),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.grey[300], // Change color to suit
                child: Center(child: Text("sponsor logo Section")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
