import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'send alert.dart'; // Import the intl package

class PublicViewEmergencyTeam extends StatefulWidget {
  const PublicViewEmergencyTeam({super.key});

  @override
  State<PublicViewEmergencyTeam> createState() => _PublicViewEmergencyTeamState();
}

class _PublicViewEmergencyTeamState extends State<PublicViewEmergencyTeam> {
  List<dynamic> emergencyTeams = [];
  List<dynamic> filteredEmergencyTeams = [];
  bool isLoading = true;
  String? selectedDistrict; // Selected district for filtering
  List<String> districts = []; // List of unique districts

  @override
  void initState() {
    super.initState();
    _fetchEmergencyTeams();
  }

  Future<void> _fetchEmergencyTeams() async {
    final sh = await SharedPreferences.getInstance();
    String? baseUrl = sh.getString("url");

    if (baseUrl != null) {
      // Ensure baseUrl does not end with a slash
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Construct the full URL
      final fullUrl = Uri.parse('$baseUrl/public_view_emergency_team');

      // Print the full URL for debugging
      print("Full URL: $fullUrl");

      try {
        final response = await http.get(fullUrl);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print("Response Data: $responseData"); // Debugging line
          if (responseData['status'] == 'ok') {
            setState(() {
              emergencyTeams = responseData['data'];
              filteredEmergencyTeams = emergencyTeams; // Initialize filtered list
              isLoading = false;

              // Extract unique districts
              districts = emergencyTeams
                  .map<String>((team) => team['district'].toString())
                  .toSet() // Remove duplicates
                  .toList();
              districts.insert(0, 'All'); // Add "All" option
            });
          } else {
            // Handle error
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load emergency teams'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Handle error
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load emergency teams'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Handle error
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Handle error
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to filter emergency teams based on selected district
  void _filterEmergencyTeams(String? district) {
    setState(() {
      selectedDistrict = district;
      if (district == 'All' || district == null) {
        filteredEmergencyTeams = emergencyTeams; // Show all teams
      } else {
        filteredEmergencyTeams = emergencyTeams
            .where((team) => team['district'] == district)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Teams",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
      ),
      body: Column(
        children: [
          // Dropdown Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Select District',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: districts.map((String district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: _filterEmergencyTeams,
            ),
          ),
          // List of Emergency Teams
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEmergencyTeams.isEmpty
                ? const Center(
              child: Text(
                'No emergency teams found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredEmergencyTeams.length,
              itemBuilder: (context, index) {
                final team = filteredEmergencyTeams[index];
                return EmergencyTeamCard(team: team);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmergencyTeamCard extends StatelessWidget {
  final dynamic team;

  EmergencyTeamCard({required this.team});

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(team['joined_date']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team['department'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${team['district']}, ${team['city']}, ${team['pin'].toString()}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${team['email']}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            Text(
              'Contact: ${team['contact_no'].toString()}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Joined: $formattedDate',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(onPressed: ()async{
              final sh = await SharedPreferences.getInstance();
              sh.setString('tid', team['id'].toString());
              Navigator.push(context, MaterialPageRoute(builder: (context) => SentRequest(),));

            }, child: Text('Request'))
          ],
        ),
      ),
    );
  }
}
