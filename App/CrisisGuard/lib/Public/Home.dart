import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../Login.dart';
import '../ViewNotification.dart';
import 'DonateGoods.dart';
import 'Payment.dart';
import 'Profile.dart';
import 'SendComplaint.dart';
import 'ViewComplaint.dart';
import 'ViewDonation.dart';
import 'ViewEmergencyRequest.dart';
import 'ViewEmergencyTeam.dart';
import 'ViewNeeds.dart';
import 'ViewPayDonation.dart';
import 'VolunteerRegistration.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => homeState();
}

class homeState extends State<home> {
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

        notifications.sort((a, b) {
          DateTime dateTimeA = DateTime.parse("${a['posted_date']} ${a['posted_time']}");
          DateTime dateTimeB = DateTime.parse("${b['posted_date']} ${b['posted_time']}");
          return dateTimeB.compareTo(dateTimeA);
        });

        setState(() {
          notificationsList = notifications.take(5).toList();
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

  String _formatDateTime(String date, String time) {
    DateTime dateTime = DateTime.parse("$date $time");
    return DateFormat('MMM d, y  - h:mm a').format(dateTime);
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
      drawer: const Drawerclass(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to Crisis Guard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your Safety, Our Priority",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.assignment_outlined,
                      title: "View Needs",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNeedsPage()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: "Donate Goods",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DonateGoodsForm()));
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
                      icon: Icons.currency_rupee_rounded,
                      title: "Pay Donation",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.emergency_outlined,
                      title: "Emergency Request",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewEmergencyTeam()));
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
                      icon: Icons.error_outline,
                      title: "Send Complaint",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PublicSendComplaint()));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.people_outlined,
                      title: "Volunteer Registration",
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PublicVolunteerRegistration()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Recent Alerts",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.blue[500]))
                  : notificationsList.isEmpty
                  ? Center(
                child: Text(
                  "No notifications available.",
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: notificationsList.length,
                  itemBuilder: (context, index) {
                    var item = notificationsList[index];
                    String formattedDateTime = _formatDateTime(item['posted_date'], item['posted_time']);

                    return _buildAlertCard(
                      title: item['title'],
                      description: item['notification'],
                      date: formattedDateTime,
                    );
                  },
                ),
              ),
            ],
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

  Widget _buildAlertCard({
    required String title,
    required String description,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[500]!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.warning_amber_outlined,
            color: Colors.blue[500],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Drawerclass extends StatelessWidget {
  const Drawerclass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      elevation: 0,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Crisis Guard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Your Safety, Our Priority",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            _buildListTile(
              icon: Icons.home_outlined,
              title: "Home",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const home()));
              },
            ),
            _buildListTile(
              icon: Icons.assignment_outlined,
              title: "Camp Needs",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNeedsPage()));
              },
            ),
            _buildExpansionTile(
              icon: Icons.card_giftcard_outlined,
              title: "Donate Goods",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.add_circle_outline,
                    title: "Donate",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DonateGoodsForm()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.list_alt_outlined,
                    title: "My Donations",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewDonations()));
                    },
                  ),
                ),
              ],
            ),
            _buildExpansionTile(
              icon: Icons.currency_rupee_rounded,
              title: "Pay Donation",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.add_card_sharp,
                    title: "Donate",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.payments_outlined,
                    title: "Past Donation",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewPayments()));
                    },
                  ),
                ),
              ],
            ),
            _buildExpansionTile(
              icon: Icons.emergency_outlined,
              title: "Emergency Request",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.add_alert_outlined,
                    title: "Request",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewEmergencyTeam()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.crisis_alert_outlined,
                    title: "My Request",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewEmergencyRequests()));
                    },
                  ),
                ),
              ],
            ),
            _buildExpansionTile(
              icon: Icons.error_outline,
              title: "Complaint",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.send_rounded,
                    title: "Send Complaint",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicSendComplaint()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: _buildListTile(
                    icon: Icons.reviews_outlined,
                    title: "My Complaint",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewComplaints()));
                    },
                  ),
                ),
              ],
            ),
            _buildListTile(
              icon: Icons.people_outlined,
              title: "Volunteer Registration",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PublicVolunteerRegistration()));
              },
            ),
            _buildListTile(
              icon: Icons.notifications_outlined,
              title: "Notification",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ViewNotificationPage()));
              },
            ),
            _buildListTile(
              icon: Icons.person_outlined,
              title: "Profile",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewProfile()));
              },
            ),
            Divider(
              color: Colors.grey[300],
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            LogoutFeature.buildLogoutListTile(context),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue[800],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildExpansionTile({required IconData icon, required String title, required List<Widget> children}) {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue[800],
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: children,
    );
  }
}

class LogoutFeature {
  static void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout Confirmation"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop();
                performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  static void performLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You have been logged out."),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  static Widget buildLogoutListTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.logout_outlined,
          color: Colors.blue[800],
          size: 24,
        ),
      ),
      title: Text(
        "Logout",
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        showLogoutConfirmationDialog(context);
      },
      hoverColor: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
