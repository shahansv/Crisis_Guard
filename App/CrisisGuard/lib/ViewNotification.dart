import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package

class ViewNotificationPage extends StatefulWidget {
  const ViewNotificationPage({super.key});

  @override
  State<ViewNotificationPage> createState() => _ViewNotificationPageState();
}

class _ViewNotificationPageState extends State<ViewNotificationPage> {
  List<Map<String, dynamic>> notificationsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String url = ip + "view_notification";
      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> notifications = List<Map<String, dynamic>>.from(jsonData['data']);

        // Sort notifications by posted_date and posted_time in descending order
        notifications.sort((a, b) {
          DateTime dateTimeA = DateTime.parse("${a['posted_date']} ${a['posted_time']}");
          DateTime dateTimeB = DateTime.parse("${b['posted_date']} ${b['posted_time']}");
          return dateTimeB.compareTo(dateTimeA); // Descending order
        });

        setState(() {
          notificationsList = notifications;
          isLoading = false;
        });
      } else {
        print("Error: ${jsonData['status']}");
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
  String _formatDateTime(String date, String time) {
    DateTime dateTime = DateTime.parse("$date $time");
    return DateFormat('MMM d, y  - h:mm a').format(dateTime); // Example: "Oct 5, 2023 3:30 PM"
  }

  // Helper function to categorize notifications
  String _getCategory(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime startOfThisWeek = today.subtract(Duration(days: now.weekday - 1));
    DateTime startOfLastWeek = startOfThisWeek.subtract(Duration(days: 7));

    if (dateTime.year == today.year && dateTime.month == today.month && dateTime.day == today.day) {
      return "Today";
    } else if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day) {
      return "Yesterday";
    } else if (dateTime.isAfter(startOfThisWeek) && dateTime.isBefore(today)) {
      return "This Week";
    } else if (dateTime.isAfter(startOfLastWeek) && dateTime.isBefore(startOfThisWeek)) {
      return "Last Week";
    } else {
      return "Earlier";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500], // Light blue color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[500]))
          : notificationsList.isEmpty
          ? Center(
        child: Text(
          "No notifications available.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notificationsList.length,
        itemBuilder: (context, index) {
          var item = notificationsList[index];
          DateTime dateTime = DateTime.parse("${item['posted_date']} ${item['posted_time']}");
          String category = _getCategory(dateTime);
          String formattedDateTime = _formatDateTime(item['posted_date'], item['posted_time']);

          // Display category header
          if (index == 0 || _getCategory(DateTime.parse("${notificationsList[index - 1]['posted_date']} ${notificationsList[index - 1]['posted_time']}")) != category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Set the color to black
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      // Add tap functionality if needed
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['notification'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              formattedDateTime, // Display formatted date and time without "Posted on"
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // Add tap functionality if needed
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['notification'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedDateTime, // Display formatted date and time without "Posted on"
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
