import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'rfid_check_page.dart';
import 'display_settings_page.dart';
import 'race_result_page.dart';
import 'upload_excel.dart';
import 'background_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final File? backgroundImage = backgroundProvider.homeBannerImage;

    return Scaffold(
      backgroundColor: Color(0xFFCDC4C4),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
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
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.black),
            onSelected: (value) async {
              if (value == 'Home') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
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
              } else if (value == 'Upload Excel') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExcelUploadPage()),
                );
              } else if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeBackgroundPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                  value: 'Home',
                  child:
                      ListTile(leading: Icon(Icons.home), title: Text('Home'))),
              PopupMenuItem<String>(
                  value: 'RFID Tag Check',
                  child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text('RFID Tag Check'))),
              PopupMenuItem<String>(
                  value: 'Race Result',
                  child: ListTile(
                      leading: Icon(Icons.insert_chart_outlined),
                      title: Text('Race Result'))),
              PopupMenuItem<String>(
                  value: 'Upload Excel',
                  child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text('Upload Excel'))),
              PopupMenuItem<String>(
                  value: 'Settings',
                  child: ListTile(
                      leading: Icon(Icons.settings), title: Text('Settings'))),
            ],
          ),
        ],
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          height: 900,
          width: MediaQuery.of(context).size.width * 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: backgroundImage != null
                ? DecorationImage(
                    image: FileImage(backgroundImage),
                    fit: BoxFit.cover,
                  )
                : null,
            color:
                backgroundImage == null ? Colors.grey[300] : Colors.transparent,
          ),
          child: backgroundImage == null
              ? Center(
                  child: Text(
                    'No Background Available',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
