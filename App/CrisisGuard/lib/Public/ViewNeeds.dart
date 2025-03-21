import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class ViewNeedsPage extends StatefulWidget {
  const ViewNeedsPage({super.key});

  @override
  State<ViewNeedsPage> createState() => _ViewNeedsPageState();
}

class _ViewNeedsPageState extends State<ViewNeedsPage> {
  Map<String, List<Map<String, dynamic>>> groupedNeeds = {};
  List<String> campNames = [];
  String selectedCamp = '';

  @override
  void initState() {
    super.initState();
    fetchNeeds();
  }

  Future<void> fetchNeeds() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String url = ip + "public_view_needs";
      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> needsList = List<Map<String, dynamic>>.from(jsonData['data']);
        setState(() {
          groupedNeeds = groupBy(needsList, (Map<String, dynamic> item) => item['CAMP']);
          campNames = groupedNeeds.keys.toList();
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
          "Needs",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500], // Light blue color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: Column(
        children: [
          // Dropdown for Camp Selection
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                value: selectedCamp.isEmpty ? null : selectedCamp,
                hint: const Text("Select Camp", style: TextStyle(color: Colors.grey)),
                underline: Container(), // Remove the default underline
                isExpanded: true, // Make the dropdown take the full width
                items: campNames.map((String camp) {
                  return DropdownMenuItem<String>(
                    value: camp,
                    child: Text(
                      camp,
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCamp = newValue!;
                  });
                },
              ),
            ),
          ),
          // Needs List
          Expanded(
            child: groupedNeeds.isEmpty
                ? Center(
              child: groupedNeeds.isEmpty && campNames.isEmpty
                  ? const Text("No data available", style: TextStyle(fontSize: 16, color: Colors.grey))
                  : CircularProgressIndicator(color: Colors.blue[500]),
            )
                : ListView(
              padding: const EdgeInsets.all(16.0),
              children: groupedNeeds.keys.map((camp) {
                if (selectedCamp.isNotEmpty && camp != selectedCamp) {
                  return Container();
                }
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
          ),
        ],
      ),
    );
  }
}
