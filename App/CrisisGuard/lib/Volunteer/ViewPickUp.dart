import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VolViewPickupPage extends StatefulWidget {
  const VolViewPickupPage({super.key});

  @override
  State<VolViewPickupPage> createState() => _VolViewPickupPageState();
}

class _VolViewPickupPageState extends State<VolViewPickupPage> {
  List<Map<String, dynamic>> pickupList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPickupData();
  }

  Future<void> fetchPickupData() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";

      String url = ip + "vol_view_pickup?lid=$lid";

      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));

      // Log the response status code and body for debugging
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['status'] == "ok" && jsonData['data'] is List) {
          setState(() {
            pickupList = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
          });
        } else {
          print("Error: Unexpected data format or status not ok");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Error: Received non-200 status code");
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

  // Function to handle the "Collected" button press
  Future<void> markAsCollected(String gid) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String url = ip + "vol_collected_goods/"; // Update the URL to match your Django endpoint

      var response = await http.post(
        Uri.parse(url),
        body: {'gid': gid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == "ok") {
          print("Item marked as collected");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Item marked as collected"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3), // Show SnackBar for 3 seconds
            ),
          );
          fetchPickupData(); // Refresh the list
        } else {
          print("Error: ${jsonData['message']}");
        }
      } else {
        print("Error: Received non-200 status code");
      }
    } catch (e) {
      print("Error marking item as collected: $e");
    }
  }

  // Function to handle the "Cancel" button press
  // Future<void> cancelPickup(String gid) async {
  //   try {
  //     final pref = await SharedPreferences.getInstance();
  //     String ip = pref.getString("url") ?? "";
  //     String url = ip + "cancel_pickup";
  //
  //     var response = await http.post(
  //       Uri.parse(url),
  //       body: {'gid': gid},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var jsonData = json.decode(response.body);
  //       if (jsonData['status'] == "ok") {
  //         print("Pickup canceled");
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text("Pickup canceled"),
  //             backgroundColor: Colors.red,
  //             duration: Duration(seconds: 3), // Show SnackBar for 3 seconds
  //           ),
  //         );
  //         fetchPickupData(); // Refresh the list
  //       } else {
  //         print("Error: ${jsonData['message']}");
  //       }
  //     } else {
  //       print("Error: Received non-200 status code");
  //     }
  //   } catch (e) {
  //     print("Error canceling pickup: $e");
  //   }
  // }


  Future<void> cancelPickup(String gid) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String url = "$ip/vol_cancel_pickup";

      var response = await http.post(
        Uri.parse(url),
        body: {'gid': gid},
      );

      print("Request sent to: $url");
      print("Sent data: gid=$gid");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        print("Response: ${response.body}");

        if (jsonData['status'] == "ok") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Pickup canceled"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          fetchPickupData(); // Refresh the list
        } else {
          print("Error: ${jsonData['message']}");
        }
      } else {
        print("Error: Received non-200 status code");
      }
    } catch (e) {
      print("Error canceling pickup: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pickup Items",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue[500]))
          : pickupList.isEmpty
          ? Center(child: Text("No items available for pickup", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pickupList.length,
        itemBuilder: (context, index) {
          var item = pickupList[index];
          DateTime donatedOn = DateTime.parse(item['donated_on']);
          String formattedDate = DateFormat('MMMM dd, yyyy - hh:mm a').format(donatedOn);

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 10),
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
                    "Quantity: ${item['quantity']}",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Donated On: $formattedDate",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Public Name: ${item['public_name']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Public Phone: ${item['public_phone']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          markAsCollected(item['id'].toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Collected",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     cancelPickup(item['id'].toString());
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.red,
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //     ),
                      //   ),
                      //   child: const Text(
                      //     "Cancel",
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),

                      ElevatedButton(
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Cancel Pickup"),
                              content: Text("Are you sure you want to cancel this pickup?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false), // Cancel
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true), // Confirm
                                  child: Text("Yes"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            setState(() {
                              isLoading = true; // Disable button while processing
                            });

                            await cancelPickup(item['id'].toString());

                            setState(() {
                              isLoading = false; // Enable button after request completion
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
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
