import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package

class PublicViewPayments extends StatefulWidget {
  const PublicViewPayments({super.key});

  @override
  State<PublicViewPayments> createState() => _PublicViewPaymentsState();
}

class _PublicViewPaymentsState extends State<PublicViewPayments> {
  List<dynamic> payments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    final sh = await SharedPreferences.getInstance();
    String? baseUrl = sh.getString("url");
    String? lid = sh.getString("lid");

    if (baseUrl != null && lid != null) {
      // Ensure baseUrl does not end with a slash
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Construct the full URL
      final fullUrl = Uri.parse('$baseUrl/public_view_payments?lid=$lid');

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
              payments = responseData['data'].reversed.toList();
              isLoading = false;
            });
          } else {
            // Handle error
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to load payments'),
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
              content: Text('Failed to load payments'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "View Payments",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : payments.isEmpty
          ? const Center(
        child: Text(
          'No payments found.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final formattedDate = _formatDate(payment['payment_date']);
          final formattedTime = _formatTime(payment['payment_time']);

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
                  // Amount at the top with larger font size
                  Text(
                    '\₹${payment['amount']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Payment ID below the amount with smaller font size
                  Text(
                    'Payment ID: ${payment['id']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Date and time at the bottom-right corner
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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