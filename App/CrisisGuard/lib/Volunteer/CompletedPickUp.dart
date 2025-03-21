import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting

class VolCompletedPickUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Completed Pickups",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
      ),
      body: VolCompletedPickUp(),
    );
  }
}

class Goods {
  final int id;
  final String category;
  final String product;
  final String name;
  final int quantity;
  final DateTime donatedOn;
  final String publicName;
  final int publicPhone; // Changed to int

  Goods({
    required this.id,
    required this.category,
    required this.product,
    required this.name,
    required this.quantity,
    required this.donatedOn,
    required this.publicName,
    required this.publicPhone, // Changed to int
  });
}

class VolCompletedPickUp extends StatefulWidget {
  @override
  _VolCompletedPickUpState createState() => _VolCompletedPickUpState();
}

class _VolCompletedPickUpState extends State<VolCompletedPickUp> {
  List<Goods> goodsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGoods();
  }

  Future<void> fetchGoods() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? ""; // Get the logged-in user's ID
      String url = ip + "vol_show_completed_pickup";

      print("Fetching data from: $url");

      // Make a POST request with the 'lid' parameter
      var response = await http.post(
        Uri.parse(url),
        body: {'lid': lid},
      );

      if (response.statusCode == 200) {
        print("Response Body: ${response.body}"); // Debugging: Print the response
        // Parse the response into a list of Goods objects
        List<Goods> goods = _parseGoodsFromResponse(response.body);

        // Sort goods by donated_on in descending order
        goods.sort((a, b) => b.donatedOn.compareTo(a.donatedOn));

        setState(() {
          goodsList = goods;
          isLoading = false;
        });
      } else {
        print("Error: ${response.statusCode}");
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

  // Parse the response into a list of Goods objects
  List<Goods> _parseGoodsFromResponse(String responseBody) {
    // Decode the JSON response
    final Map<String, dynamic> responseMap = json.decode(responseBody);

    if (responseMap['status'] == "ok") {
      List<dynamic> data = responseMap['data'];
      return data.map((item) {
        return Goods(
          id: item['id'] as int,
          category: item['category'] as String,
          product: item['product'] as String,
          name: item['name'] as String,
          quantity: item['quantity'] as int,
          donatedOn: DateTime.parse(item['donated_on'] as String),
          publicName: item['public_name'] as String,
          publicPhone: item['public_phone'] as int, // Parse as int
        );
      }).toList();
    } else {
      throw Exception("Failed to load data: ${responseMap['status']}");
    }
  }

  // Helper function to format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y  - h:mm a').format(dateTime); // Example: "Oct 5, 2023 3:30 PM"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[500]))
          : goodsList.isEmpty
          ? Center(
        child: Text(
          "No completed pickups available.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: goodsList.length,
        itemBuilder: (context, index) {
          var item = goodsList[index];
          String formattedDateTime = _formatDateTime(item.donatedOn);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Category: ${item.category}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Product: ${item.product}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Quantity: ${item.quantity}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Donated on: $formattedDateTime",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Donor: ${item.publicName}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Donor Contact: ${item.publicPhone}", // Display as int
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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