import 'package:crisisguard/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpSet extends StatefulWidget {
  const IpSet({Key? key}) : super(key: key);

  @override
  State<IpSet> createState() => _IpSetState();
}

class _IpSetState extends State<IpSet> {
  final TextEditingController ipController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo/logo.png', // Replace with your image path
              width: 30, // Adjust the width as needed
              height: 30, // Adjust the height as needed
            ),
            const SizedBox(width: 10), // Add some spacing between the image and text
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
        backgroundColor: Colors.blue.shade800, // Darker shade for the AppBar
        elevation: 10, // Add shadow to the AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200, // Light blue at the top
              Colors.blue.shade50, // Very light blue at the bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Set Server IP Address",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1), // Custom dark blue color
                      ),
                    ),
                    const SizedBox(height: 20),
                    // IP Address Input Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: TextField(
                          controller: ipController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "IP Address",
                            hintText: "Enter a valid IP address",
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String ip = ipController.text.trim();
                          if (_isValidIp(ip)) {
                            final sh = await SharedPreferences.getInstance();
                            sh.setString("url", "http://$ip:5000/");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a valid IP address!"),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3), // Set the duration to 3 seconds
                              ),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.key,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Set IP',
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
                            horizontal: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
    );
  }

  bool _isValidIp(String ip) {
    // Basic IP address format validation
    final ipRegex = RegExp(
      r'^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }
}
