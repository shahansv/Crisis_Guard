import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import the intl package

class VolViewGoods extends StatefulWidget {
  const VolViewGoods({super.key});

  @override
  State<VolViewGoods> createState() => _VolViewGoodsState();
}

class _VolViewGoodsState extends State<VolViewGoods> {
  List<Map<String, dynamic>> goodsList = [];
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
      String url = ip + "vol_view_goods";
      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> goods = List<Map<String, dynamic>>.from(jsonData['data']);

        // Sort goods by donated_on in descending order
        goods.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(a['donated_on']);
          DateTime dateTimeB = DateTime.parse(b['donated_on']);
          return dateTimeB.compareTo(dateTimeA); // Descending order
        });

        setState(() {
          goodsList = goods;
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
  String _formatDateTime(String dateTime) {
    DateTime parsedDateTime = DateTime.parse(dateTime);
    return DateFormat('MMM d, y  - h:mm a').format(parsedDateTime); // Example: "Oct 5, 2023 3:30 PM"
  }

  // Function to handle the "Pick Up" button press
  Future<void> pickUpGoods(String gid, String lid) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";
      String url = ip + "update_pickup";

      var response = await http.post(
        Uri.parse(url),
        body: {'gid': gid, 'lid': lid},
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        print("Pick up successful");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pick up successful"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        fetchGoods();
        // Optionally, you can update the UI or show a success message
      }
      else {
        print("Error: ${jsonData['message']}");
        // Optionally, you can show an error message to the user
      }
    } catch (e) {
      print("Error picking up goods: $e");
      // Optionally, you can show an error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Collected Goods",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500], // Light blue color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[500]))
          : goodsList.isEmpty
          ? Center(
        child: Text(
          "No goods available.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: goodsList.length,
        itemBuilder: (context, index) {
          var item = goodsList[index];
          String formattedDateTime = _formatDateTime(item['donated_on']);

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
                      item['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Category: ${item['category']}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Product: ${item['product']}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Quantity: ${item['quantity']}",
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
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Call the pickUpGoods function with gid and lid
                          pickUpGoods(item['id'].toString(), "your_lid_here");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Pick Up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
