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
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  // Floating BIB Number Container (Box A)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 60),
                    decoration: BoxDecoration(
                      color: backgroundImage != null
                          ? Colors.black.withOpacity(0.6) // Semi-transparent
                          : Colors.black, // Fully opaque
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
                      padding: EdgeInsets.symmetric(vertical: 120),
                      child: Center(
                        child: Text(
                          '${_currentBibDetails!['bib_number']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 120,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom Row Containers (Box B and C)
                  Row(
                    children: [
                      // Name Container (Box B)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: backgroundImage != null
                                ? Colors.white
                                    .withOpacity(0.6) // Semi-transparent
                                : Colors.white, // Fully opaque
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(36),
                            child: Column(
                              children: [
                                Icon(Icons.person, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  '${_currentBibDetails!['first_name']} ${_currentBibDetails!['last_name']}',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Category Container (Box C)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 12),
                          decoration: BoxDecoration(
                            color: backgroundImage != null
                                ? Colors.white
                                    .withOpacity(0.6) // Semi-transparent
                                : Colors.white, // Fully opaque
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(36),
                            child: Column(
                              children: [
                                Icon(Icons.flag, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  '${_currentBibDetails!['category']}',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
