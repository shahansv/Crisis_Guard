import 'dart:convert';
import 'package:crisisguard/Public/EditProfile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../ChangePassword.dart';
import 'EditProfile.dart';

class VolViewProfile extends StatefulWidget {
  const VolViewProfile({super.key});

  @override
  State<VolViewProfile> createState() => _PublicViewProfileState();
}

class _PublicViewProfileState extends State<VolViewProfile> {
  String name = "";
  String gender = "";
  String dob = "";
  String district = "";
  String city = "";
  String pin = "";
  String email = "";
  String contactNo = "";
  String photoUrl = "";
  String id = "";
  String aadhaarNumber = "";
  String joinedDate = "";
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    viewProfile();
  }

  Future<void> viewProfile() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("url").toString();
      String lid = pref.getString("lid").toString(); // Get the login ID from shared preferences
      String url = ip + "volunteer_view_profile";

      // Send a POST request with the login ID
      var response = await http.post(
        Uri.parse(url),
        body: {
          "lid": lid, // Include the login ID in the request body
        },
      );

      var jsondata = json.decode(response.body);

      if (jsondata['status'] == "ok") {
        var profile = jsondata['data'][0]; // Assuming only one profile is returned

        setState(() {
          name = profile['name'].toString();
          gender = profile['gender'].toString();
          dob = profile['dob'].toString();
          district = profile['district'].toString();
          city = profile['city'].toString();
          pin = profile['pin'].toString();
          email = profile['email'].toString();
          contactNo = profile['contact_no'].toString();
          photoUrl = (pref.getString("url").toString() + profile['photo'].toString())
              .replaceFirst(":/", "___TEMP___")  // Temporarily replace ':/'
              .replaceAll("//", "/")  // Fix double slashes
              .replaceFirst("___TEMP___", ":/");  // Restore ':/'
          id = profile['id'].toString();
          aadhaarNumber = profile['aadhaar_number'].toString();
          joinedDate = profile['joined_date'].toString();
          isLoading = false; // Set loading to false after data is fetched
        });

        // Debugging: Print the fetched values to the console
        print("Name: $name");
        print("Gender: $gender");
        print("DOB: $dob");
        print("District: $district");
        print("City: $city");
        print("PIN: $pin");
        print("Email: $email");
        print("Contact No: $contactNo");
        print("Photo URL: $photoUrl");
        print("ID: $id");
        print("Aadhaar Number: $aadhaarNumber");
        print("Joined Date: $joinedDate");
      } else {
        setState(() {
          isLoading = false; // Set loading to false even if no data is found
        });
        print("No profile data found");
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Set loading to false in case of an error
      });
      print("Error: $e");
    }
  }

  void _changePassword() {
    // Implement your change password functionality here
    print("Change Password button pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Public View Profile"),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isLoading)
                const Center(child: CircularProgressIndicator()) // Show loading indicator
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20), // Space above the image
                      CircleAvatar(
                        radius: 70, // Increased the size of the image
                        backgroundImage: photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null, // Removed placeholder image
                        backgroundColor: Colors.grey[200],
                      ),
                      SizedBox(height: 16),
                      Text(
                        name,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20), // Space below the name
                      _buildDetailRow('Gender', gender),
                      _buildDetailRow('Date of Birth', dob),
                      _buildDetailRow('District', district),
                      _buildDetailRow('City', city),
                      _buildDetailRow('PIN', pin),
                      _buildDetailRow('Email', email),
                      _buildDetailRow('Contact', contactNo),
                      _buildDetailRow('Aadhaar Number', aadhaarNumber),
                      _buildDetailRow('Joined Date', joinedDate),
                    ],
                  ),
                ),
              SizedBox(height: 24),

              // Buttons for Change Password and Edit Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrgChangePassword()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _editProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProfile() async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VolunteerEditProfile(
          id: id,
          name: name,
          gender: gender,
          dob: dob,
          district: district,
          city: city,
          pin: pin,
          email: email,
          contactNo: contactNo,
          aadhaarNumber: aadhaarNumber, // Add this line
          photoUrl: photoUrl,
        ),
      ),
    );

    // Refresh profile if updated
    if (result == true) {
      viewProfile();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
