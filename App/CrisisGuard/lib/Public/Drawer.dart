import 'package:crisisguard/Public/ViewDonation.dart';
import 'package:crisisguard/Public/home.dart';
import 'package:crisisguard/Public/viewneeds.dart';
import 'package:crisisguard/Public/DonateGoods.dart';
import 'package:crisisguard/ViewNotification.dart';
import 'package:crisisguard/Public/VolunteerRegistration.dart';
import 'package:flutter/material.dart';
import '../Login.dart';
import 'ViewEmergencyRequest.dart';
import 'ViewEmergencyTeam.dart';
import 'Payment.dart';
import 'Profile.dart';
import 'SendComplaint.dart';
import 'ViewComplaint.dart';
import 'ViewPayDonation.dart';

class Drawerclass extends StatelessWidget {
  const Drawerclass({Key? key}) : super(key: key);

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
              icon: Icons.card_giftcard_outlined, // More relatable icon for donations
              title: "Donate Goods",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.add_circle_outline,
                    title: "Donate",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DonateGoodsForm()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
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
              icon: Icons.currency_rupee_rounded, // More relatable icon for donations
              title: "Pay Donation",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.add_card_sharp,
                    title: "Donate",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
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
              icon: Icons.emergency_outlined, // More relatable icon for donations
              title: "Emergency Request",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.add_alert_outlined,
                    title: "Request",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicViewEmergencyTeam()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
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
              icon: Icons.error_outline, // More relatable icon for donations
              title: "Complaint",
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
                  child: _buildListTile(
                    icon: Icons.send_rounded,
                    title: "Send Complaint",
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PublicSendComplaint()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0), // Indent the children
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
              color: Colors.grey[300], // Light grey divider
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
}

class LogoutFeature {
  // Method to show logout confirmation dialog
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Logout"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                performLogout(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to perform logout and show snackbar
  static void performLogout(BuildContext context) {
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

  // Helper method to build ListTile for logout
  static Widget buildLogoutListTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[800]!.withOpacity(0.1), // Subtle background for icons
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.logout_outlined,
          color: Colors.blue[800], // Blue icons for consistency
          size: 24,
        ),
      ),
      title: Text(
        "Logout",
        style: TextStyle(
          color: Colors.grey[800], // Dark grey text for readability
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        showLogoutConfirmationDialog(context);
      },
      hoverColor: Colors.blue[50], // Light blue hover effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
