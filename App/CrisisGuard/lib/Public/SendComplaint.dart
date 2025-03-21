import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ViewComplaint.dart';

class PublicSendComplaint extends StatefulWidget {
  const PublicSendComplaint({super.key});

  @override
  State<PublicSendComplaint> createState() => _PublicSendComplaintState();
}

class _PublicSendComplaintState extends State<PublicSendComplaint> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController complaintController = TextEditingController();

  Future<void> _sendComplaint() async {
    if (_formKey.currentState!.validate()) {
      final sh = await SharedPreferences.getInstance();
      String? url = sh.getString("url");
      String? lid = sh.getString("lid");

      // Log the base URL and lid for debugging
      print("Base URL: $url");
      print("Login ID: $lid");

      if (url != null && lid != null) {
        // Construct the full URL
        final fullUrl = Uri.parse('$url/public_send_complaint');
        print("Full URL: $fullUrl");

        try {
          final response = await http.post(
            fullUrl,
            body: {
              'lid': lid,
              'complaint': complaintController.text,
            },
          );

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            if (responseData['status'] == 'ok') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint Sent Successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
              // Navigate to PublicViewComplaints page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PublicViewComplaints()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to Send Complaint'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            // Log the response status code for debugging
            print("Response Status Code: ${response.statusCode}");
          }
        } catch (e) {
          print(e);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Send Complaint",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(complaintController, "Complaint", Icons.edit,
                  maxLines: 5),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendComplaint,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Send Complaint",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[500]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[500]!),
          ),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
