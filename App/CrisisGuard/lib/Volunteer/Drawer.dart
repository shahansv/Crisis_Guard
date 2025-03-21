import 'package:crisisguard/Volunteer/ViewNeeds.dart';
import 'package:crisisguard/Volunteer/Home.dart';
import 'package:flutter/material.dart';
import '../Login.dart';
import '../ViewNotification.dart';
import 'CompletedPickUp.dart';
import 'GroupChat.dart';
import 'ViewGoods.dart';
import 'Profile.dart';
import 'ViewMissingAsset.dart';
import 'ViewPickUp.dart';
import 'ViewTask.dart';
// import 'GroupChat.dart';

class VolunteerDrawerClass extends StatelessWidget {
  const VolunteerDrawerClass({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280, // Set a custom width for the drawer
      elevation: 0, // Remove shadow for a flat, minimal look
      child: Container(
        color: Colors.white, // White background for minimalism
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!], // Blue gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/logo/logo.png', // Path to your logo image
                    width: 60, // Adjust the width as needed
                    height: 60, // Adjust the height as needed
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => const VolunteerHome()));
              },
            ),
            _buildListTile(
              icon: Icons.assignment_outlined,
              title: "View Needs",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewNeedsPage()));
              },
            ),
            _buildExpansionTile(
              icon: Icons.volunteer_activism_outlined, // More relatable icon for donations
              title: "Goods",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.add_circle_outline,
                    title: "View Goods",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewGoods()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.list_alt_outlined,
                    title: "My Pick Up",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewPickupPage()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.list_alt_outlined,
                    title: "Completed Pick Up",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VolCompletedPickUpPage()));
                    },
                  ),
                ),
              ],
            ),
            _buildListTile(
              icon: Icons.task_alt,
              title: "Task",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewTasksPage()));
              },
            ),
            _buildListTile(
              icon: Icons.web_asset,
              title: "Missing Asset",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewMissingAsset()));
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
              icon: Icons.chat,
              title: "Chat",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GroupChat()));
              },
            ),
            _buildListTile(
              icon: Icons.person_outlined,
              title: "Profile",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VolViewProfile()));
              },
            ),
            Divider(
              color: Colors.grey[300], // Light grey divider
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            _buildListTile(
              icon: Icons.logout_outlined,
              title: "Logout",
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build ListTile with consistent styling
  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withOpacity(0.1), // Subtle background for icons
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue[800], // Blue icons for consistency
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800], // Dark grey text for readability
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Colors.blue[50], // Light blue hover effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // Helper method to build ExpansionTile with consistent styling
  Widget _buildExpansionTile({required IconData icon, required String title, required List<Widget> children}) {
    return ExpansionTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withOpacity(0.1), // Subtle background for icons
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.blue[800], // Blue icons for consistency
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.grey[800], // Dark grey text for readability
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: children,
    );
  }

  // Method to show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to perform logout and show snackbar
  void _performLogout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You have been logged out."),
        backgroundColor: Colors.blue[700], // Blue snackbar color
      ),
    );
  }
}
