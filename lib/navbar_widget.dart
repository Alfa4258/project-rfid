import 'package:flutter/material.dart';
import 'home_page.dart';
import 'rfid_check_page.dart';
import 'race_result_page.dart';
import 'upload_excel.dart';
import 'display_settings_page.dart';

class NavbarWidget extends StatelessWidget {
  final Widget body;
  final String title;

  const NavbarWidget({
    Key? key,
    required this.body,
    this.title = 'Labsco Sport',
  }) : super(key: key);

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
                height: 40,
              ),
              SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Colors.black),
              onSelected: (value) {
                switch (value) {
                  case 'Home':
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                    break;
                  case 'RFID Tag Check':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RFIDTagCheckPage()),
                    );
                    break;
                  case 'Race Result':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RaceResultPage()),
                    );
                    break;
                  case 'Upload Excel':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ExcelUploadPage()),
                    );
                    break;
                  case 'Display Settings':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangeBackgroundPage()),
                    );
                    break;
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
                  value: 'Upload Excel',
                  child: ListTile(
                    leading: Icon(Icons.upload_file),
                    title: Text('Upload Excel'),
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
        body: body,
      ),
    );
  }
}
