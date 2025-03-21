import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:crisisguard/Registration.dart'; // Import your registration page
import 'package:crisisguard/Public/Home.dart'; // Import your public home page
import 'package:crisisguard/Volunteer/Home.dart';

import 'Public/location.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false; // To manage loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo.png', // Replace with your image path
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Username Input Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Username",
                              hintText: "Enter your username",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 16,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Input Field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Password",
                              hintText: "Enter your password",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 20,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 16,
                              ),
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 16,
                              ),
                            ),
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 16,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Login Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null // Disable button when loading
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true; // Show loading indicator
                              });

                              final sh = await SharedPreferences.getInstance();
                              String Uname = usernameController.text.toString();
                              String Passwd = passwordController.text.toString();
                              String url = sh.getString("url").toString();

                              try {
                                var data = await http.post(
                                  Uri.parse(url + "logincode"),
                                  body: {
                                    'username': Uname,
                                    "password": Passwd,
                                  },
                                );

                                var jasondata = json.decode(data.body);
                                String status = jasondata['task'].toString();
                                String type = jasondata['type'].toString();

                                if (status == "valid") {
                                  if (type == 'Public' || type == 'VolPending') {
                                    String lid = jasondata['lid'].toString();
                                    sh.setString("lid", lid);
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => sapp()),
                                    // );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => home()),
                                    );
                                  } else if (type == 'Volunteer' ) {
                                    String lid = jasondata['lid'].toString();
                                    sh.setString("lid", lid);
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => sapp()),
                                    // );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => VolunteerHome()),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: Invalid user type"),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Invalid username or password"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("An error occurred. Please try again."),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              } finally {
                                setState(() {
                                  isLoading = false; // Hide loading indicator
                                });
                              }
                            }
                          },
                          child: isLoading
                              ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Registration Text
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpForm()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register here',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
