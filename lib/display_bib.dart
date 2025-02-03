import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'background_provider.dart';
import 'home_page.dart';

class BibDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bibDetails;

  BibDetailsPage({required this.bibDetails});

  @override
  _BibDetailsPageState createState() => _BibDetailsPageState();
}

class _BibDetailsPageState extends State<BibDetailsPage> {
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
    final File? backgroundImage = backgroundProvider.displayBackgroundImage;

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
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 1440, // Adjust this value as needed
                    ),
                    decoration: BoxDecoration(
                      color: backgroundImage != null
                          ? Colors.black.withOpacity(0.6)
                          : Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_currentBibDetails!['first_name']} ${_currentBibDetails!['last_name']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 36),
                          Text(
                            '${_currentBibDetails!['bib_number']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 120,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            '${_currentBibDetails!['category']}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 120,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
