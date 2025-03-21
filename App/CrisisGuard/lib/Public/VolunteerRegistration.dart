import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PublicVolunteerRegistration extends StatefulWidget {
  @override
  _PublicVolunteerRegistrationState createState() => _PublicVolunteerRegistrationState();
}

class _PublicVolunteerRegistrationState extends State<PublicVolunteerRegistration> {
  String _name = "";
  String _gender = "";
  String _dob = "";
  String _district = "";
  String _city = "";
  String _pin = "";
  String _email = "";
  String _contactNo = "";
  String _photoUrl = "";
  String _selectedCampId = "";
  String _loginType = ""; // Add login type
  String _aadhaarNumber = "";
  String _joinedDate = "";
  List<dynamic> _camps = [];

  @override
  void initState() {
    super.initState();
    fetchPublicDetails();
    fetchCamps();
  }

  Future<void> fetchPublicDetails() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String url = pref.getString("url").toString() + "public_view_profile";
      String loginId = pref.getString("lid").toString();

      var response = await http.post(Uri.parse(url), body: {'lid': loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        var userData = jsonData['data'][0];
        setState(() {
          _name = userData['name'].toString();
          _gender = userData['gender'].toString();
          _dob = userData['dob'].toString();
          _district = userData['district'].toString();
          _city = userData['city'].toString();
          _pin = userData['pin'].toString();
          _email = userData['email'].toString();
          _contactNo = userData['contact_no'].toString();
          _photoUrl = (pref.getString("url").toString() + userData['photo'].toString())
              .replaceFirst(":/", "___TEMP___")
              .replaceAll("//", "/")
              .replaceFirst("___TEMP___", ":/");
          _loginType = userData['login_type'].toString(); // Fetch login type
          _aadhaarNumber = userData['aadhaar_number'].toString();
          _joinedDate = userData['joined_date'].toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch profile data"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error fetching public details: $e");
    }
  }

  Future<void> fetchCamps() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String? baseUrl = pref.getString("url");

      if (baseUrl == null || baseUrl.isEmpty) {
        print("Error: Base URL is null or empty");
        return;
      }

      String url = baseUrl + "get_camps";
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['status'] == "ok") {
          setState(() {
            _camps = jsonData['data'];
          });
        } else {
          print("API returned error status: ${jsonData['status']}");
        }
      } else {
        print("HTTP Request Failed: ${response.body}");
      }
    } catch (e) {
      print("Error fetching camps: $e");
    }
  }

  Future<void> registerAsVolunteer() async {
    if (_selectedCampId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a camp"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final pref = await SharedPreferences.getInstance();
      String url = pref.getString("url").toString() + "public_vol_registration";
      String loginId = pref.getString("lid").toString();

      var response = await http.post(
        Uri.parse(url),
        body: {'login_id': loginId, 'camp_id': _selectedCampId},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Volunteer registration successful"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Update the login type to reflect the registration status
        setState(() {
          _loginType = 'VolPending';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonData['message']),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register as Volunteer"),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                      backgroundImage: _photoUrl.isNotEmpty
                          ? NetworkImage(_photoUrl)
                          : null, // Removed placeholder image
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(height: 16),
                    Text(
                      _name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20), // Space below the name
                    buildInfoRow("Gender", _gender),
                    buildInfoRow("Date of Birth", _dob),
                    buildInfoRow("District", _district),
                    buildInfoRow("City", _city),
                    buildInfoRow("PIN", _pin),
                    buildInfoRow("Contact No.", _contactNo),
                    buildInfoRow("Email", _email),
                    buildInfoRow("Aadhaar Number", _aadhaarNumber),
                    buildInfoRow("Joined Date", _joinedDate),
                  ],
                ),
              ),
              SizedBox(height: 24),
              if (_loginType == 'VolPending')
                Text(
                  "You have already registered.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Select a Camp", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.blue[700]!),
                        ),
                      ),
                      hint: Text("Choose a Camp"),
                      value: _selectedCampId.isNotEmpty ? _selectedCampId : null,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCampId = newValue!;
                        });
                      },
                      items: _camps.map((camp) {
                        return DropdownMenuItem<String>(
                          value: camp['id'].toString(),
                          child: Text(camp['camp_name'].toString()),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: registerAsVolunteer,
                        child: Text("Register as Volunteer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
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

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
