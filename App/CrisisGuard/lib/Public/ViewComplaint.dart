import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package

class PublicViewComplaints extends StatefulWidget {
  const PublicViewComplaints({super.key});

  @override
  State<PublicViewComplaints> createState() => _PublicViewComplaintsState();
}

class _PublicViewComplaintsState extends State<PublicViewComplaints> {
  List<Map<String, dynamic>> complaintsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";
      String url = ip + "public_view_complaints?lid=$lid";
      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> complaints = List<Map<String, dynamic>>.from(jsonData['data']);

        setState(() {
          complaintsList = complaints;
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

  // Helper function to format date and time
  String _formatDateTime(String dateTime) {
    DateTime date = DateTime.parse(dateTime);
    return DateFormat('MMM d, y, h:mm a').format(date); // Example: "Oct 5, 2023, 2:30 PM"
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.red;
      case 'working':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Function to show reply dialog with highlighted labels
  void _showReplyDialog(String reply, String updatedOn) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Reply: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: reply,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  updatedOn,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete a complaint
  Future<void> deleteComplaint(int index) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String id = complaintsList[index]['id'].toString(); // Assuming 'id' is the primary key
      String url = ip + "public_delete_complaint";
      print("Deleting data from: $url");

      var response = await http.post(
        Uri.parse(url),
        body: {'cid': id},
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        setState(() {
          complaintsList.removeAt(index);
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
            content: Text('Failed to delete complaint: ${jsonData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error deleting data: $e");

      // Show Snackbar for exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting complaint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complaints",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700], // Blue 700 color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[700]))
          : complaintsList.isEmpty
          ? Center(
        child: Text(
          "No complaints available.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: complaintsList.length,
        itemBuilder: (context, index) {
          // Reverse the list to show new data at the top
          var item = complaintsList[complaintsList.length - 1 - index];
          String formattedPostedDateTime = _formatDateTime(item['posted_on']);
          String formattedUpdatedDateTime = _formatDateTime(item['updated_on']);

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
                  Align(
                    alignment: Alignment.topLeft,
                    child: Chip(
                      label: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _getStatusColor(item['status']),
                      padding: EdgeInsets.all(1), // Reduce the size of the badge
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['complaint'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formattedPostedDateTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showReplyDialog(item['reply'], formattedUpdatedDateTime),
                        child: Text("View Reply"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue[700], // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => deleteComplaint(complaintsList.length - 1 - index),
                        child: Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // Background color
                          onPrimary: Colors.white, // Text color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
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
