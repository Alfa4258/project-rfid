import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: RFIDTagCheckPage()));

class RFIDTagCheckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCDC4C4), // Background color from the mockup
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Add your logo image to assets
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
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                hintText: "Enter BIP Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          
          // Updated part: IconButton with dropdown included
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.black),
            onSelected: (value) {
              // Handle selection, for now, print the selected value
              print('Selected: $value');
              // You can navigate to other pages based on the selection
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailPage(option: value)),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Option 1',
                child: Text('Option 1'),
              ),
              PopupMenuItem<String>(
                value: 'Option 2',
                child: Text('Option 2'),
              ),
              PopupMenuItem<String>(
                value: 'Option 3',
                child: Text('Option 3'),
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
              'Scan RFID Tag or Enter BIP Number',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New page for displaying selected option details
class DetailPage extends StatelessWidget {
  final String option;

  DetailPage({required this.option});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected: $option'),
        backgroundColor: Colors.grey[200],
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      body: Center(
        child: Text(
          'You selected: $option',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
