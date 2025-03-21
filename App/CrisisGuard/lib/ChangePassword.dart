import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crisisguard/Public/home.dart';

class OrgChangePassword extends StatefulWidget {
  const OrgChangePassword({super.key});

  @override
  State<OrgChangePassword> createState() => _OrgChangePasswordState();
}

class _OrgChangePasswordState extends State<OrgChangePassword> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isCurrentPasswordVerified = false;
  String csrfToken = '';
  bool isCurrentPasswordEmpty = false;
  bool isNewPasswordEmpty = false;
  bool isConfirmPasswordEmpty = false;
  bool isPasswordTooShort = false;

  @override
  void initState() {
    super.initState();
    _retrieveCSRFToken();
  }

  Future<void> _retrieveCSRFToken() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      csrfToken = sh.getString('csrfToken') ?? '';
    });
  }

  void verifyCurrentPassword() async {
    String currentPassword = currentPasswordController.text;

    if (currentPassword.isEmpty) {
      setState(() {
        isCurrentPasswordEmpty = true;
      });
      return;
    }

    setState(() {
      isCurrentPasswordEmpty = false;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString("lid").toString();
    final Uri apiUrl = Uri.parse(url + 'verify_current_password');

    try {
      final response = await http.post(
        apiUrl,
        body: {
          'id': lid,
          'current_password': currentPassword,
        },
        headers: {
          'X-CSRFToken': csrfToken,
        },
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          setState(() {
            isCurrentPasswordVerified = true;
            currentPasswordController.clear(); // Clear the current password field
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Current password verified.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Current password is incorrect.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network Error'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void changePassword() async {
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    setState(() {
      isNewPasswordEmpty = newPassword.isEmpty;
      isConfirmPasswordEmpty = confirmPassword.isEmpty;
      isPasswordTooShort = newPassword.length < 8 && newPassword.isNotEmpty;
    });

    // Check if new password or confirm password fields are empty
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      return;
    }

    // Check if new password is at least 8 characters long
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password must be at least 8 characters long.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if new password and confirm password match
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password and confirmation do not match.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url') ?? '';
    String lid = sh.getString("lid").toString();
    final Uri apiUrl = Uri.parse(url + 'changepassword');

    try {
      final response = await http.post(
        apiUrl,
        body: {
          'id': lid,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
        headers: {
          'X-CSRFToken': csrfToken,
        },
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => home()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change password. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network Error'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isCurrentPasswordVerified) ...[
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isCurrentPasswordEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isCurrentPasswordEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isCurrentPasswordEmpty ? Colors.red : Colors.blue,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              if (isCurrentPasswordEmpty)
                Text(
                  'Current password cannot be empty.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: verifyCurrentPassword,
                child: const Text('Verify Current Password'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ] else ...[
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isNewPasswordEmpty || isPasswordTooShort ? Colors.red : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isNewPasswordEmpty || isPasswordTooShort ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isNewPasswordEmpty || isPasswordTooShort ? Colors.red : Colors.blue,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              if (isNewPasswordEmpty)
                Text(
                  'New password cannot be empty.',
                  style: TextStyle(color: Colors.red),
                ),
              if (isPasswordTooShort)
                Text(
                  'New password must be at least 8 characters long.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isConfirmPasswordEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isConfirmPasswordEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: isConfirmPasswordEmpty ? Colors.red : Colors.blue,
                    ),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                obscureText: true,
              ),
              if (isConfirmPasswordEmpty)
                Text(
                  'Confirm password cannot be empty.',
                  style: TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: changePassword,
                child: const Text('Change Password'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
