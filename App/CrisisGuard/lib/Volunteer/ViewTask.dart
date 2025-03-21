// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
//
// class VolViewTasksPage extends StatefulWidget {
//   const VolViewTasksPage({super.key});
//
//   @override
//   State<VolViewTasksPage> createState() => _VolViewTasksPageState();
// }
//
// class _VolViewTasksPageState extends State<VolViewTasksPage> {
//   List<Map<String, dynamic>> incompleteTasks = [];
//   List<Map<String, dynamic>> completedTasks = [];
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTasks();
//   }
//
//   Future<void> fetchTasks() async {
//     try {
//       final pref = await SharedPreferences.getInstance();
//       String ip = pref.getString("url") ?? "";
//       String lid = pref.getString("lid") ?? "";
//
//       String url = ip + "volunteer_view_task?lid=$lid";  // Pass lid as a query parameter
//
//       print("Fetching data from: $url");
//
//       var response = await http.get(Uri.parse(url));
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == "ok") {
//         List<Map<String, dynamic>> tasksList = List<Map<String, dynamic>>.from(jsonData['data']);
//
//         // Separate tasks into incomplete and completed lists
//         incompleteTasks = tasksList.where((task) => task['status'] == false).toList();
//         completedTasks = tasksList.where((task) => task['status'] == true).toList();
//
//         setState(() {});
//       } else {
//         print("Error: ${jsonData['status']}");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }
//
//   Future<void> updateTaskStatus(String taskId, bool newStatus) async {
//     try {
//       final pref = await SharedPreferences.getInstance();
//       String ip = pref.getString("url") ?? "";
//
//       String url = ip + "toggle_status";  // Update the URL to your endpoint
//
//       var response = await http.post(
//         Uri.parse(url),
//         body: {'tid': taskId},  // Send tid as form data
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       );
//
//       var jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == "ok") {
//         // Refresh the task list
//         fetchTasks();
//       } else {
//         print("Error updating task status: ${jsonData['message']}");
//       }
//     } catch (e) {
//       print("Error updating task status: $e");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Volunteer Tasks",
//           style: TextStyle(fontSize: 22, color: Colors.white),
//         ),
//         backgroundColor: Colors.blue[500], // Light blue color for AppBar
//         elevation: 4, // Add a slight shadow
//       ),
//       body: (incompleteTasks.isEmpty && completedTasks.isEmpty)
//           ? Center(
//         child: const Text("No data available", style: TextStyle(fontSize: 16, color: Colors.grey)),
//       )
//           : ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           if (incompleteTasks.isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Incomplete Tasks",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
//                 ),
//                 const SizedBox(height: 8),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: incompleteTasks.length,
//                   itemBuilder: (context, index) {
//                     var task = incompleteTasks[index];
//                     DateTime assignedOn = DateTime.parse(task['assigned_on']);
//                     String formattedDate = DateFormat('MMMM dd, yyyy').format(assignedOn); // Format the date
//
//                     return Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 10),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: () {
//                           // Add tap functionality if needed
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Checkbox(
//                                 value: task['status'] == '1', // Ensure this matches the backend's status representation
//                                 onChanged: (bool? value) {
//                                   if (value != null) {
//                                     // Determine the new status based on the current value
//                                     bool newStatus = value;
//                                     // Update the task status in the backend
//                                     updateTaskStatus(task['id'].toString(), newStatus);
//                                   }
//                                 },
//                               ),
//
//
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       task['task'],
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey[800],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       formattedDate,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           if (completedTasks.isNotEmpty)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Completed Tasks",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
//                 ),
//                 const SizedBox(height: 8),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: completedTasks.length,
//                   itemBuilder: (context, index) {
//                     var task = completedTasks[index];
//                     DateTime assignedOn = DateTime.parse(task['assigned_on']);
//                     String formattedDate = DateFormat('MMMM dd, yyyy').format(assignedOn); // Format the date
//
//                     return Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       margin: const EdgeInsets.only(bottom: 10),
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(10),
//                         onTap: () {
//                           // Add tap functionality if needed
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               Checkbox(
//                                 value: task['status'] == true,
//                                 onChanged: (bool? value) {
//                                   if (value != null) {
//                                     updateTaskStatus(task['id'].toString(), value);
//                                   }
//                                 },
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       task['task'],
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w500,
//                                         color: Colors.grey[800],
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       formattedDate,
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }





import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VolViewTasksPage extends StatefulWidget {
  const VolViewTasksPage({super.key});

  @override
  State<VolViewTasksPage> createState() => _VolViewTasksPageState();
}

class _VolViewTasksPageState extends State<VolViewTasksPage> {
  List<Map<String, dynamic>> incompleteTasks = [];
  List<Map<String, dynamic>> completedTasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";
      String lid = pref.getString("lid") ?? "";

      String url = "$ip/volunteer_view_task?lid=$lid"; // Pass lid as a query parameter

      print("Fetching data from: $url");

      var response = await http.get(Uri.parse(url));
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        List<Map<String, dynamic>> tasksList =
        List<Map<String, dynamic>>.from(jsonData['data']);

        // Separate tasks into incomplete and completed lists
        incompleteTasks = tasksList.where((task) => task['status'] == false).toList();
        completedTasks = tasksList.where((task) => task['status'] == true).toList();

        setState(() {});
      } else {
        print("Error: ${jsonData['status']}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> updateTaskStatus(String taskId, bool newStatus) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";

      String url = "$ip/toggle_status"; // Update the URL to your endpoint

      var response = await http.post(
        Uri.parse(url),
        body: {'tid': taskId}, // Send tid as form data
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        // Refresh the task list
        fetchTasks();
      } else {
        print("Error updating task status: ${jsonData['message']}");
      }
    } catch (e) {
      print("Error updating task status: $e");
    }
  }

  Future<void> updateTaskStatus_old(String taskId, bool newStatus) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url") ?? "";

      String url = "$ip/toggle_status_old"; // Update the URL to your endpoint

      var response = await http.post(
        Uri.parse(url),
        body: {'tid': taskId}, // Send tid as form data
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        // Refresh the task list
        fetchTasks();
      } else {
        print("Error updating task status: ${jsonData['message']}");
      }
    } catch (e) {
      print("Error updating task status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Volunteer Tasks",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500], // Light blue color for AppBar
        elevation: 4, // Add a slight shadow
      ),
      body: (incompleteTasks.isEmpty && completedTasks.isEmpty)
          ? const Center(
        child: Text("No data available",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (incompleteTasks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Incomplete Tasks",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: incompleteTasks.length,
                  itemBuilder: (context, index) {
                    var task = incompleteTasks[index];
                    DateTime assignedOn = DateTime.parse(task['assigned_on']);
                    String formattedDate =
                    DateFormat('MMMM dd, yyyy').format(assignedOn);

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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: task['status'] == true,
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    // Update the task status in the backend
                                    await updateTaskStatus_old(
                                        task['id'].toString(), value);

                                    // Update the local state immediately
                                    setState(() {
                                      task['status'] = value;
                                    });

                                    // Refresh the task list
                                    fetchTasks();
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['task'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
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
          if (completedTasks.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Completed Tasks",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800]),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: completedTasks.length,
                  itemBuilder: (context, index) {
                    var task = completedTasks[index];
                    DateTime assignedOn = DateTime.parse(task['assigned_on']);
                    String formattedDate =
                    DateFormat('MMMM dd, yyyy').format(assignedOn);

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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: task['status'] == true,
                                onChanged: (bool? value) async {
                                  if (value != null) {
                                    // Update the task status in the backend
                                    await updateTaskStatus(
                                        task['id'].toString(), value);

                                    // Update the local state immediately
                                    setState(() {
                                      task['status'] = value;
                                    });

                                    // Refresh the task list
                                    fetchTasks();
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['task'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
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
        ],
      ),
    );
  }
}