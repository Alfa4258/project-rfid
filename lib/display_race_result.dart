import 'package:flutter/material.dart';
import 'api_service.dart';  // Import ApiService for searching BIBs again
import 'home_page.dart';   // Import HomePage for back navigation
import 'rfid_check_page.dart'; // Import RFIDTagCheckPage
import 'display_settings_page.dart';  // Import ChangeBackgroundPage
import 'race_result_page.dart';

class RaceResultsDetailsPage extends StatefulWidget {
  final Map<String, dynamic> RaceResultsDetails;
  final ApiService apiService = ApiService(); // Initialize ApiService

  RaceResultsDetailsPage({required this.RaceResultsDetails});

  @override
  _RaceResultsDetailsPageState createState() => _RaceResultsDetailsPageState();
}

class _RaceResultsDetailsPageState extends State<RaceResultsDetailsPage> {
  final TextEditingController _bibController = TextEditingController();  // Controller for the search bar
    Map<String, dynamic>? _currentBibDetails;

  @override
  void initState() {
    super.initState();
    _currentBibDetails = widget.RaceResultsDetails;  // Initialize with the passed BIB details
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
        return false;
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

                  // Update the current BIB details without navigating away
                  setState(() {
                    _currentBibDetails = bibDetails;
                  });
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
                } else if (value == 'Race Result') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RaceResultPage()),
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
                  value: 'Race Result',
                  child: ListTile(
                    leading: Icon(Icons.insert_chart_outlined_outlined),
                    title: Text('Race Result'),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          'BIB ${_currentBibDetails!['bib_number']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.person, color: Colors.black54),
                            Text('Name', style: TextStyle(color: Colors.black54)),
                            Text(
                              '${_currentBibDetails!['first_name']} ${_currentBibDetails!['last_name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.flag, color: Colors.black54),
                            Text('Category', style: TextStyle(color: Colors.black54)),
                            Text(
                              _currentBibDetails!['category'] ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('Overview', style: TextStyle(color: Colors.black)),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text('Split Times', style: TextStyle(color: Colors.black54)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.access_time, color: Colors.black54),
                            Text('Start Time', style: TextStyle(color: Colors.black54)),
                            Text(
                              _currentBibDetails!['start_time'] ?? '08:00:00',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.flag, color: Colors.black54),
                            Text('Finish Time', style: TextStyle(color: Colors.black54)),
                            Text(
                              _currentBibDetails!['finish_time'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.speed, color: Colors.black54),
                        SizedBox(width: 8.0),
                        Text('Pace', style: TextStyle(color: Colors.black54)),
                        SizedBox(width: 8.0),
                        Text(
                          '${_currentBibDetails!['average_pace'] ?? 'N/A'} min/km',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
