import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolViewMissingAsset extends StatefulWidget {
  const VolViewMissingAsset({super.key});

  @override
  State<VolViewMissingAsset> createState() => _VolViewMissingAssetState();
}

class _VolViewMissingAssetState extends State<VolViewMissingAsset> {
  List<Map<String, dynamic>> assetsList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMissingAssets();
  }

  Future<void> fetchMissingAssets() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String url = ip + "vol_view_missing_asset";
      print("Fetching data from: $url");

      var response = await http.post(Uri.parse(url), body: {
        "lid": pref.getString("lid").toString()
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> assets = List<Map<String, dynamic>>.from(jsonData['data']);

        // Sort assets by missing_date in descending order
        assets.sort((a, b) {
          DateTime dateTimeA = DateTime.parse(a['missing_date']);
          DateTime dateTimeB = DateTime.parse(b['missing_date']);
          return dateTimeB.compareTo(dateTimeA); // Descending order
        });

        setState(() {
          assetsList = assets;
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

  Future<void> updateAssetStatus(String aid, String status) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String url = ip + (status == 'Lost' ? "vol_lost_asset" : "vol_found_asset");
      print("Updating asset status to: $status");

      var response = await http.post(Uri.parse(url), body: {
        "lid": pref.getString("lid").toString(),
        "aid": aid,
      });
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        print("Asset status updated successfully.");
        fetchMissingAssets(); // Refresh the list
      } else {
        print("Error updating asset status: ${jsonData['status']}");
      }
    } catch (e) {
      print("Error updating asset status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Missing Assets",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500], // Light blue color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[500]))
          : assetsList.isEmpty
          ? Center(
        child: Text(
          "No missing assets available.",
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: assetsList.length,
        itemBuilder: (context, index) {
          var item = assetsList[index];
          String formattedMissingDate = _formatDateTime(item['missing_date']);

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
                    item['asset'],
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
                    "Description: ${item['description']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Status: ${item['status']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Missing since: $formattedMissingDate",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => updateAssetStatus(item['id'].toString(), 'Lost'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: Text("Mark as Lost"),
                      ),
                      ElevatedButton(
                        onPressed: () => updateAssetStatus(item['id'].toString(), 'Found'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: Text("Mark as Found"),
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
