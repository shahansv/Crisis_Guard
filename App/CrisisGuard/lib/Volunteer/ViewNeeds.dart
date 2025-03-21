import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class VolViewNeedsPage extends StatefulWidget {
  const VolViewNeedsPage({super.key});

  @override
  State<VolViewNeedsPage> createState() => _VolViewNeedsPageState();
}

class _VolViewNeedsPageState extends State<VolViewNeedsPage> {
  Map<String, List<Map<String, dynamic>>> groupedNeeds = {};

  @override
  void initState() {
    super.initState();
    fetchNeeds();
  }

  Future<void> fetchNeeds() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";

      String url = ip+"volunteer_view_needs?lid=$lid";  // Pass lid as a query parameter

      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> needsList = List<Map<String, dynamic>>.from(jsonData['data']);

        // Ensure CAMP key exists
        for (var item in needsList) {
          item['CAMP'] = item['CAMP'] ?? "Unknown Camp"; // Default value if CAMP is null
          item['added_on'] = item['added_on'] ?? "1970-01-01 00:00:00"; // Default date
        }

        setState(() {
          groupedNeeds = groupBy(needsList, (item) => item['CAMP'] as String);
        });
      } else {
        print("Error: ${jsonData['status']}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Volunteer Needs",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500], // Light blue color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: groupedNeeds.isEmpty
          ? Center(
        child: groupedNeeds.isEmpty
            ? const Text("No data available", style: TextStyle(fontSize: 16, color: Colors.grey))
            : CircularProgressIndicator(color: Colors.blue[500]),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: groupedNeeds.keys.map((camp) {
          List<Map<String, dynamic>> campNeeds = groupedNeeds[camp]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centered Camp Name
                Center(
                  child: Text(
                    camp, // Display camp name without "CAMP:"
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: campNeeds.length,
                  itemBuilder: (context, index) {
                    var item = campNeeds[index];
                    DateTime addedOn = DateTime.parse(item['added_on']);
                    String formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(addedOn);

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
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
                                "Category: ${item['category']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Product: ${item['product']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Product Name: ${item['name']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Quantity: ${item['quantity']} ${item['unit']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Added On: $formattedDate",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
