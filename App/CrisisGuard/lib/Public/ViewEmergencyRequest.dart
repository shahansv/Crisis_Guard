import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class PublicViewEmergencyRequests extends StatefulWidget {
  const PublicViewEmergencyRequests({super.key});

  @override
  State<PublicViewEmergencyRequests> createState() => _PublicViewEmergencyRequestsState();
}

class _PublicViewEmergencyRequestsState extends State<PublicViewEmergencyRequests> {
  List<dynamic> emergencyRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyRequests();
  }

  Future<void> _fetchEmergencyRequests() async {
    final sh = await SharedPreferences.getInstance();
    String? baseUrl = sh.getString("url");
    String? lid = sh.getString("lid");

    if (baseUrl != null && lid != null) {
      // Ensure baseUrl does not end with a slash
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Construct the full URL
      final fullUrl = Uri.parse('$baseUrl/public_view_emergency_request?lid=$lid');

      // Print the full URL for debugging
      print("Full URL: $fullUrl");

      try {
        final response = await http.get(fullUrl);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print("Response Data: $responseData"); // Debugging line
          if (responseData['status'] == 'ok') {
            setState(() {
              // Reverse the list to show new data at the top
              emergencyRequests = responseData['data'].reversed.toList();
              isLoading = false;
            });
          } else {
            // Handle error
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load emergency requests'),
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
              content: Text('Failed to load emergency requests'),
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
          content: Text('Missing URL or LID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to format date and time
  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dateTime); // Date format: 12 Oct 2023
    } catch (e) {
      return date; // Fallback to original format if parsing fails
    }
  }

  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse('1970-01-01 $time'); // Use a dummy date
      return DateFormat('hh:mm a').format(dateTime); // Time format: 02:30 PM
    } catch (e) {
      return time; // Fallback to original format if parsing fails
    }
  }

  // Helper function to get badge color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.red;
      case 'On the Way':
        return Colors.orange;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Function to open Google Maps with the specified location
  Future<void> _openMap(double latitude, double longitude) async {
    final Uri mapUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl);
    } else {
      throw 'Could not launch $mapUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Emergency Requests",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : emergencyRequests.isEmpty
          ? const Center(
        child: Text(
          'No emergency requests found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: emergencyRequests.length,
        itemBuilder: (context, index) {
          final request = emergencyRequests[index];
          final formattedPostedDate = _formatDate(request['posted_date']);
          final formattedPostedTime = _formatTime(request['posted_time']);
          final formattedUpdatedDate = _formatDate(request['updated_date']);
          final formattedUpdatedTime = _formatTime(request['updated_time']);

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
                  // Request description at the top
                  Text(
                    request['request'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status in a badge with color based on status
                  Chip(
                    label: Text(
                      request['status'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _getStatusColor(request['status']),
                  ),
                  const SizedBox(height: 8),
                  // Posted date and time
                  Text(
                    'Posted: $formattedPostedDate, $formattedPostedTime',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  // Updated date and time, if status is not 'Pending'
                  if (request['status'] != 'Pending')
                    Text(
                      'Updated: $formattedUpdatedDate, $formattedUpdatedTime',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Latitude and Longitude with clickable location
                  GestureDetector(
                    onTap: () => _openMap(request['latitude'], request['longitude']),
                    child: Text(
                      'Location: ${request['latitude']}, ${request['longitude']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
