import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'api_service.dart';
import 'home_page.dart';
import 'rfid_check_page.dart';
import 'display_settings_page.dart';
import 'background_provider.dart';

class BibDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bibDetails;
  final ApiService apiService = ApiService();

  BibDetailsPage({required this.bibDetails});

  @override
  _BibDetailsPageState createState() => _BibDetailsPageState();
}

class _BibDetailsPageState extends State<BibDetailsPage> {
  final TextEditingController _bibController = TextEditingController();
  Map<String, dynamic>? _currentBibDetails;

  @override
  void initState() {
    super.initState();
    _currentBibDetails = widget.bibDetails;

    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final File? backgroundImage = backgroundProvider.bibDisplayBackgroundImage;

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
        body: Container(
          decoration: BoxDecoration(
            image: backgroundImage != null
                ? DecorationImage(
                    image: FileImage(backgroundImage),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.grey[200]?.withOpacity(0.7),
                  child: Center(
                    child: Text(
                      "${_currentBibDetails!['bib_number']}",
                      style:
                          TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey[400]?.withOpacity(0.7),
                        child: Center(
                          child: Text(
                            "${_currentBibDetails!['first_name']} ${_currentBibDetails!['last_name']}",
                            style: TextStyle(
                                fontSize: 60, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey[500]?.withOpacity(0.7),
                        child: Center(
                          child: Text(
                            "${_currentBibDetails!['category']} Race",
                            style: TextStyle(
                                fontSize: 60, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[300]?.withOpacity(0.7),
                  child: Center(
                    child: Text(
                      "Sponsor Logo Section",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
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
