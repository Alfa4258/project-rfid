import 'package:flutter/material.dart';
import 'api_service.dart';  // Import ApiService for searching BIBs again
import 'home_page.dart';   // Import HomePage for back navigation
import 'rfid_check_page.dart'; // Import RFIDTagCheckPage
import 'display_settings_page.dart';  // Import ChangeBackgroundPage

class BibDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bibDetails;
  final ApiService apiService = ApiService(); // Initialize ApiService

  BibDetailsPage({required this.bibDetails});

  @override
  _BibDetailsPageState createState() => _BibDetailsPageState();
}

class _BibDetailsPageState extends State<BibDetailsPage> {
  final TextEditingController _bibController = TextEditingController();  // Controller for the search bar
  Map<String, dynamic>? _currentBibDetails;

  @override
  void initState() {
    super.initState();
    _currentBibDetails = widget.bibDetails;  // Initialize with the passed BIB details
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
            // Search bar inside the AppBar
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
                  Map<String, dynamic>? bibDetails = await widget.apiService.fetchBibDetails(bibNumber);

                  if (bibDetails != null) {
                    // Update the current BIB details without navigating away
                    setState(() {
                      _currentBibDetails = bibDetails;
                    });
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
        body: _currentBibDetails != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BIB Number: ${_currentBibDetails!['bib_number']}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'First Name: ${_currentBibDetails!['first_name']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Last Name: ${_currentBibDetails!['last_name']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Gender: ${_currentBibDetails!['gender']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Date of Birth: ${_currentBibDetails!['date_of_birth']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Address: ${_currentBibDetails!['address']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'City: ${_currentBibDetails!['city']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Province: ${_currentBibDetails!['province']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Country: ${_currentBibDetails!['country']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Email: ${_currentBibDetails!['email']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Cellphone: ${_currentBibDetails!['cellphone']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Category: ${_currentBibDetails!['category']}',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
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
