import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package

class PublicViewDonations extends StatefulWidget {
  const PublicViewDonations({super.key});

  @override
  State<PublicViewDonations> createState() => _PublicViewDonationsState();
}

class _PublicViewDonationsState extends State<PublicViewDonations> {
  List<Map<String, dynamic>> donationsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDonations();
  }

  Future<void> fetchDonations() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";
      String url = ip + "public_view_donations?lid=$lid";
      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> donations = List<Map<String, dynamic>>.from(jsonData['data']);

        setState(() {
          donationsList = donations;
          isLoading = false;
        });
      } else {
        print("Error: ${jsonData['message']}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteDonation(int index) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String id = donationsList[index]['id'].toString(); // Assuming 'id' is the primary key
      String url = ip + "delete_donation?id=$id";
      print("Deleting data from: $url");

      var response = await http.delete(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        setState(() {
          donationsList.removeAt(index);
        });

        // Show Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print("Error: ${jsonData['message']}");

        // Show Snackbar for error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete donation: ${jsonData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error deleting data: $e");

      // Show Snackbar for exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper function to format date
  String _formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('MMM d, y').format(dateTime); // Example: "Oct 5, 2023"
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.red;
      case 'ready for pickup':
        return Colors.orange;
      case 'donated':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Donations",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700], // Blue 700 color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[700]))
          : donationsList.isEmpty
          ? Center(
        child: Text(
          "No donations available.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: donationsList.length,
        itemBuilder: (context, index) {
          var item = donationsList[index];
          String formattedDate = _formatDate(item['donated_on']);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['product'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Product Name: ${item['name']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quantity: ${item['quantity']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Donated on: $formattedDate",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      item['status'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _getStatusColor(item['status']),
                  ),
                  if (item['status'].toLowerCase() == 'ready for pickup' ||
                      item['status'].toLowerCase() == 'donated')
                    const SizedBox(height: 8),
                  if (item['status'].toLowerCase() == 'ready for pickup' ||
                      item['status'].toLowerCase() == 'donated')
                    Text(
                      "Volunteer: ${item['volunteer_name']} (${item['volunteer_phone']})",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (item['status'].toLowerCase() == 'pending')
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () => deleteDonation(index),
                        icon: Icon(Icons.delete, color: Colors.white),
                        label: Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
