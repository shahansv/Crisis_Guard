import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Login.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController contactNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController aadhaarController = TextEditingController(); // Controller for Aadhaar number

  String? selectedGender;
  String? selectedDistrict;
  List<String> cities = [];
  XFile? _image;

  final List<String> genders = ['Male', 'Female', 'Other'];

  final Map<String, List<String>> districtCities = {
    "Thiruvananthapuram": ["Thiruvananthapuram", "Neyyattinkara", "Nedumangad", "Varkala", "Attingal", "Kattakada"],
    "Kollam": ["Kollam", "Punalur", "Karunagappally", "Kottarakkara", "Paravur", "Karunagappally"],
    "Pathanamthitta": ["Pathanamthitta", "Adoor", "Thiruvalla", "Ranni", "Kozhencherry", "Konni"],
    "Alappuzha": ["Alappuzha", "Cherthala", "Kayamkulam", "Mavelikkara", "Chengannur", "Haripad"],
    "Kottayam": ["Kottayam", "Changanassery", "Pala", "Vaikom", "Kanjirapally", "Ettumanoor"],
    "Idukki": ["Painavu", "Thodupuzha", "Adimali", "Nedumkandam", "Munnar", "Devikulam"],
    "Ernakulam": ["Kochi", "Aluva", "Kothamangalam", "Perumbavoor", "Muvattupuzha", "Kolenchery"],
    "Thrissur": ["Thrissur", "Chalakudy", "Kodungallur", "Guruvayur", "Irinjalakuda", "Kunnamkulam"],
    "Palakkad": ["Palakkad", "Ottapalam", "Chittur", "Mannarkkad", "Alathur", "Shornur"],
    "Malappuram": ["Malappuram", "Manjeri", "Perinthalmanna", "Ponnani", "Tirur", "Nilambur"],
    "Kozhikode": ["Kozhikode", "Vatakara", "Ramanattukara", "Koyilandy", "Thamarassery", "Payyoli"],
    "Wayanad": ["Kalpetta", "Mananthavady", "Sulthan Bathery", "Vythiri", "Pulpally", "Meppadi"],
    "Kannur": ["Kannur", "Thalassery", "Payyannur", "Kuthuparamba", "Mattannur", "Iritty"],
    "Kasaragod": ["Kasaragod", "Kanhangad", "Nileshwaram", "Manjeshwaram", "Hosdurg", "Kanhangad"]
  };

  final Map<String, String> cityPincodes = {
    "Thiruvananthapuram": "695001",
    "Neyyattinkara": "695121",
    "Nedumangad": "695541",
    "Varkala": "695141",
    "Attingal": "695101",
    "Kattakada": "695573",
    "Kollam": "691001",
    "Punalur": "691305",
    "Karunagappally": "690518",
    "Kottarakkara": "691506",
    "Paravur": "691301",
    "Pathanamthitta": "689645",
    "Adoor": "691523",
    "Thiruvalla": "689101",
    "Ranni": "689673",
    "Kozhencherry": "689641",
    "Konni": "689691",
    "Alappuzha": "688001",
    "Cherthala": "688524",
    "Kayamkulam": "690502",
    "Mavelikkara": "690101",
    "Chengannur": "689121",
    "Haripad": "690516",
    "Kottayam": "686001",
    "Changanassery": "686101",
    "Pala": "686575",
    "Vaikom": "686141",
    "Kanjirapally": "686507",
    "Ettumanoor": "686631",
    "Painavu": "685603",
    "Thodupuzha": "685584",
    "Adimali": "685561",
    "Nedumkandam": "685553",
    "Munnar": "685612",
    "Devikulam": "685613",
    "Kochi": "682001",
    "Aluva": "683101",
    "Kothamangalam": "686691",
    "Perumbavoor": "683542",
    "Muvattupuzha": "686661",
    "Kolenchery": "682311",
    "Thrissur": "680001",
    "Chalakudy": "680307",
    "Kodungallur": "680664",
    "Guruvayur": "680101",
    "Irinjalakuda": "680125",
    "Kunnamkulam": "680517",
    "Palakkad": "678001",
    "Ottapalam": "679101",
    "Chittur": "678101",
    "Mannarkkad": "678582",
    "Alathur": "678541",
    "Shornur": "679121",
    "Malappuram": "676505",
    "Manjeri": "676121",
    "Perinthalmanna": "679322",
    "Ponnani": "679577",
    "Tirur": "676101",
    "Nilambur": "679329",
    "Kozhikode": "673001",
    "Vatakara": "673101",
    "Ramanattukara": "673633",
    "Koyilandy": "673305",
    "Thamarassery": "673573",
    "Payyoli": "673627",
    "Kalpetta": "673121",
    "Mananthavady": "670645",
    "Sulthan Bathery": "673592",
    "Vythiri": "673576",
    "Pulpally": "673579",
    "Meppadi": "673577",
    "Kannur": "670001",
    "Thalassery": "670101",
    "Payyannur": "670307",
    "Kuthuparamba": "670643",
    "Mattannur": "670702",
    "Iritty": "670703",
    "Kasaragod": "671121",
    "Kanhangad": "671315",
    "Nileshwaram": "671314",
    "Manjeshwaram": "671323",
    "Hosdurg": "671315"
  };

  _imgFromCamera() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  _imgFromGallery() async {
    XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _imgFromGallery();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image!'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("url").toString();

      try {
        var uri = Uri.parse(url + 'public_registration');
        var request = http.MultipartRequest('POST', uri);

        request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
        request.fields['name'] = nameController.text;
        request.fields['gender'] = selectedGender!;
        request.fields['dob'] = dobController.text;
        request.fields['contactno'] = contactNoController.text;
        request.fields['email'] = emailController.text;
        request.fields['district'] = selectedDistrict!;
        request.fields['city'] = cityController.text;
        request.fields['pin'] = pinController.text;
        request.fields['username'] = usernameController.text;
        request.fields['password'] = passwordController.text;
        request.fields['aadhaar'] = aadhaarController.text; // Send Aadhaar number with spaces

        var response = await request.send();
        var responseBody = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          final data = jsonDecode(responseBody.body);
          if (data['status'] == 'ok') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully Registered'),
                backgroundColor: Color(0xFF4ADE80),
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const Login()));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(data['message']),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration failed. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showPicker(context),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey[200],
                        child: _image != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(File(_image!.path), width: 100, height: 100, fit: BoxFit.cover),
                        )
                            : const Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Registration",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1), // Custom dark blue color
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(nameController, "Name", Icons.person),
                    _buildDropdown(genders, selectedGender, "Gender", Icons.wc),
                    _buildDatePicker(dobController, "Date of Birth", Icons.calendar_today),
                    _buildTextField(contactNoController, "Contact Number", Icons.phone, keyboardType: TextInputType.number),
                    _buildTextField(emailController, "Email", Icons.email),
                    _buildTextField(aadhaarController, "Aadhaar Number", Icons.credit_card, keyboardType: TextInputType.number, inputFormatters: [AadhaarInputFormatter()]), // Aadhaar field
                    _buildDropdown(districtCities.keys.toList(), selectedDistrict, "District", Icons.location_city),
                    _buildDropdown(cities, cityController.text.isEmpty ? null : cityController.text, "City", Icons.location_on),
                    _buildTextField(pinController, "PIN Code", Icons.pin, enabled: false),
                    _buildTextField(usernameController, "Username", Icons.person_outline),
                    _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
                    _buildTextField(confirmPasswordController, "Confirm Password", Icons.lock, obscureText: true),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
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
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, bool enabled = true, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            prefixIcon: Icon(icon),
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
          ),
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (label == "Name") {
              if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                return 'Name should contain only letters and spaces';
              }
            }
            if (label == "Contact Number") {
              if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                return 'Please enter a valid 10-digit phone number';
              }
            }
            if (label == "Email") {
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            if (label == "Confirm Password" && value != passwordController.text) {
              return 'Passwords do not match';
            }
            if (label == "Aadhaar Number") { // Validation for Aadhaar number
              if (!RegExp(r'^\d{4}\s\d{4}\s\d{4}$').hasMatch(value)) {
                return 'Please enter a valid 12-digit Aadhaar number with spaces';
              }
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedItem, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            border: InputBorder.none,
            labelStyle: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 16,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          value: selectedItem,
          onChanged: (value) {
            setState(() {
              if (label == "District") {
                selectedDistrict = value;
                cities = districtCities[value] ?? [];
                cityController.text = '';
                pinController.text = '';
              } else if (label == "City") {
                cityController.text = value!;
                pinController.text = cityPincodes[value] ?? '';
              } else {
                selectedGender = value;
              }
            });
          },
          validator: (value) => value == null ? 'Please select $label' : null,
        ),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            border: InputBorder.none,
            labelStyle: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 16,
            ),
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
          validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
          style: TextStyle(
            color: Colors.blue.shade800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(RegExp(r'\s'), ''); // Remove all spaces
    final buffer = StringBuffer();

    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if ((i + 1) % 4 == 0 && i != 11) {
        buffer.write(' ');
      }
    }

    final String formattedText = buffer.toString();

    if (formattedText.length > 14) {
      return oldValue;
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
