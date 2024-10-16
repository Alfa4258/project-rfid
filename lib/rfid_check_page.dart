import 'package:flutter/material.dart';
import 'api_service.dart';  // Import the ApiService
import 'display_bib.dart'; // Import the BibDetailsPage
import 'home_page.dart';   // Import the HomePage
import 'display_settings_page.dart';  // Import the ChangeBackgroundPage

class RFIDTagCheckPage extends StatefulWidget {
  @override
  _RFIDTagCheckPageState createState() => _RFIDTagCheckPageState();
}

class _RFIDTagCheckPageState extends State<RFIDTagCheckPage> {
  final TextEditingController _bibController = TextEditingController();
  final ApiService apiService = ApiService(); // Create an instance of ApiService

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
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                height: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Labsco Sport',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'RFID Tag Check',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
            Container(
              width: 200,
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _bibController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  hintText: "Enter BIB Number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                String bibNumber = _bibController.text.trim();

                try {
                  // Fetch BIB details from the API
                  Map<String, dynamic>? bibDetails = await apiService.fetchBibDetails(bibNumber);

                  if (bibDetails != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BibDetailsPage(
                          bibDetails: bibDetails,
                        ),
                      ),
                    );
                  } else {
                    // Show a dialog if BIB number is not found
                    _showErrorDialog('BIB Number not found');
                  }
                } catch (e) {
                  // Handle any errors here
                  _showErrorDialog('Error fetching BIB details');
                }
              },
              color: Colors.black,
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.black),
              onSelected: (value) {
                if (value == 'Home') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false, // Navigate to the home screen
                  );
                } else if (value == 'RFID Tag Check') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RFIDTagCheckPage()),
                  );
                } else if (value == 'Display Settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeBackgroundPage()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'Home',
                  child: ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'RFID Tag Check',
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('RFID Tag Check'),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Display Settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Display Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_tethering,
                size: 100,
                color: Colors.black54,
              ),
              SizedBox(height: 20),
              Text(
                'Scan RFID Tag or Enter BIB Number',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
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
