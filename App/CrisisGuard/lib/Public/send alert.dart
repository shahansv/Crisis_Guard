

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'ViewEmergencyTeam.dart';

class SentRequest extends StatefulWidget {
  const SentRequest({super.key});

  @override
  State<SentRequest> createState() => _SentRequestState();
}

class _SentRequestState extends State<SentRequest> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedAlert;
  String _currentLocation = "Press the button to get the location";
  double? _latitude;
  double? _longitude;

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permissions are denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Location permissions are permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _latitude = position.latitude;
      _longitude = position.longitude;

      setState(() {
        _currentLocation = 'Latitude: $_latitude, Longitude: $_longitude';
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to fetch location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Request"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildDropdownField(
                label: "Select Alert Type",
                icon: Icons.warning_amber_rounded,
                options: [
                  "Help",
                  "Injuries, medical aid",
                  "Trapped individuals",
                  "Fire",
                  "Flood",
                  "Earthquake",
                  "Gas Leak",
                  "Road Accident",
                  "Suspicious Activity",
                  "Other Emergency"
                ],
                onChanged: (value) {
                  setState(() {
                    selectedAlert = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an  type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                _currentLocation,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text("Get Current Location"),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_latitude == null || _longitude == null) {
                        Fluttertoast.showToast(msg: "Please fetch your location first.");
                        return;
                      }

                      final sh = await SharedPreferences.getInstance();
                      String url = sh.getString("url").toString();
                      try {
                        var data = await http.post(
                          Uri.parse(url + "send_emergency_request"),
                          body: {
                            'lid': sh.getString("lid").toString(),
                            'tid': sh.getString("tid").toString(),
                            'request': selectedAlert,
                            'latitude': _latitude.toString(),
                            'longitude': _longitude.toString(),
                          },
                        );
                        var jsonData = json.decode(data.body);
                        String status = jsonData['status'].toString();

                        if (status == "ok") {
                          Fluttertoast.showToast(msg: "Request Sent!");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublicViewEmergencyTeam(),
                            ),
                          );
                        } else {
                          _showAlertDialog("Sending alert failed.");
                        }
                      } catch (e) {
                        print(e);
                        _showAlertDialog("An error occurred: $e");
                      }
                    }
                  },
                  child: const Text("Send"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((option) => DropdownMenuItem(
        value: option,
        child: Text(option),
      ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
