import 'package:crisisguard/Volunteer/Drawer.dart';
import 'package:crisisguard/Volunteer/ViewNeeds.dart';
import 'package:crisisguard/Volunteer/Home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../ViewNotification.dart';
import 'ViewGoods.dart';
import 'ViewTask.dart';

class VolunteerHome extends StatefulWidget {
  const VolunteerHome({Key? key}) : super(key: key);

  @override
  State<VolunteerHome> createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  List<Map<String, dynamic>> incompleteTasks = [];

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

        // Filter tasks to show only incomplete tasks
        incompleteTasks = tasksList.where((task) => task['status'] == false).toList();

        setState(() {});
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            const Text(
              "Crisis Guard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 10,
      ),
      drawer: const VolunteerDrawerClass(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Quick Access Section
                Text(
                  "Quick Access",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.assignment_outlined,
                        title: "View Needs",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewNeedsPage()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.volunteer_activism_outlined,
                        title: "View Goods",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewGoods()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.task_alt,
                        title: "Tasks",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewTasksPage()));
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionCard(
                        icon: Icons.notifications_outlined,
                        title: "Notifications",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNotificationPage()));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Tasks Section
                Text(
                  "Your Tasks",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 20),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.pending_actions,
                                    color: Colors.blue[500],
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
                          );
                        },
                      ),
                    ],
                  ),
                if (incompleteTasks.isEmpty)
                  const Center(
                    child: Text("No incomplete tasks available",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.blue[500],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
