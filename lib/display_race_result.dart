import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_page.dart';
import 'rfid_check_page.dart';
import 'display_settings_page.dart';
import 'race_result_page.dart';

class RaceResultsDetailsPage extends StatefulWidget {
  final Map<String, dynamic> RaceResultsDetails;
  final ApiService apiService = ApiService();

  RaceResultsDetailsPage({required this.RaceResultsDetails});

  @override
  _RaceResultsDetailsPageState createState() => _RaceResultsDetailsPageState();
}

class _RaceResultsDetailsPageState extends State<RaceResultsDetailsPage> {
  final TextEditingController _bibController = TextEditingController();
  Map<String, dynamic>? _currentBibDetails;
  bool _isOverviewSelected = true;

  @override
  void initState() {
    super.initState();
    _currentBibDetails = widget.RaceResultsDetails;
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
        backgroundColor: Color(0xFFE5E5E5),
        appBar: _buildAppBar(),
        body: _currentBibDetails != null
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBibHeader(),
                    _buildMainInfo(),
                    _buildTabs(),
                    _buildTimeInfo(),
                    _buildPaceInfo(),
                  ],
                ),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 40),
          SizedBox(width: 12),
          Text(
            'Labsco Sport',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          width: 220,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            controller: _bibController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              hintText: "Enter BIB Number",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: _handleSearch,
              ),
            ),
          ),
        ),
        _buildMenuButton(),
      ],
    );
  }

  Widget _buildBibHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'BIB ${_currentBibDetails!['bib_number']}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(  // Add this wrapper
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoColumn(
              Icons.person,
              'Name',
              '${_currentBibDetails!['first_name']} ${_currentBibDetails!['last_name']}',
            ),
            VerticalDivider(  // Replace Container with VerticalDivider
              color: Colors.grey[300],
              thickness: 1,
            ),
            _buildInfoColumn(
              Icons.flag,
              'Category',
              _currentBibDetails!['category'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue[700]),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('Overview', _isOverviewSelected, () {
              setState(() => _isOverviewSelected = true);
            }),
          ),
          Expanded(
            child: _buildTabButton('Split Times', !_isOverviewSelected, () {
              setState(() => _isOverviewSelected = false);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool isSelected, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue[700]! : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
              fontSize: 18,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimeColumn(
            Icons.play_circle,
            'Start Time',
            _currentBibDetails!['start_time'] ?? '08:00:00',
          ),
          Container(height: 80, width: 1, color: Colors.grey[300]),
          _buildTimeColumn(
            Icons.stop_circle,
            'Finish Time',
            _currentBibDetails!['finish_time'] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(IconData icon, String label, String time) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue[700]),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildPaceInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.speed, size: 32, color: Colors.blue[700]),
          SizedBox(height: 8),
          Text(
            'Pace',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '${_currentBibDetails!['average_pace'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.menu, color: Colors.black),
      onSelected: _handleMenuSelection,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildMenuItem('Home', Icons.home),
        _buildMenuItem('RFID Tag Check', Icons.info),
        _buildMenuItem('Race Result', Icons.insert_chart_outlined_outlined),
        _buildMenuItem('Display Settings', Icons.settings),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        leading: Icon(icon),
        title: Text(value),
      ),
    );
  }

  void _handleSearch() async {
    String bibNumber = _bibController.text.trim();
    if (bibNumber.isEmpty) {
      _showErrorDialog('Please enter a BIB number');
      return;
    }

    try {
      Map<String, dynamic>? bibDetails = await widget.apiService.fetchBibDetails(bibNumber);
      setState(() => _currentBibDetails = bibDetails);
      if (bibDetails == null) {
        _showErrorDialog('BIB Number not found');
      }
    } catch (e) {
      _showErrorDialog('Error fetching BIB details');
    }
  }

  void _handleMenuSelection(String value) {
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
          MaterialPageRoute(builder: (context) => RFIDTagCheckPage()),
        );
        break;
      case 'Race Result':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RaceResultPage()),
        );
        break;
      case 'Display Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChangeBackgroundPage()),
        );
        break;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}