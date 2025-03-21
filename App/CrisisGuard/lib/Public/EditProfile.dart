import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PublicEditProfile extends StatefulWidget {
  final String name, gender, dob, district, city, pin, email, contactNo, photoUrl, id, aadhaarNumber;

  const PublicEditProfile({
    super.key,
    required this.name,
    required this.gender,
    required this.dob,
    required this.district,
    required this.city,
    required this.pin,
    required this.email,
    required this.contactNo,
    required this.photoUrl,
    required this.id,
    required this.aadhaarNumber,
  });

  @override
  _PublicEditProfileState createState() => _PublicEditProfileState();
}

class _PublicEditProfileState extends State<PublicEditProfile> {
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController emailController;
  late TextEditingController contactNoController;
  late TextEditingController aadhaarController;
  late TextEditingController pinController;
  File? _image;
  final picker = ImagePicker();

  String? selectedGender;
  String? selectedDistrict;
  String? selectedCity;
  List<String> cities = [];

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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    selectedGender = widget.gender;
    dobController = TextEditingController(text: widget.dob);
    selectedDistrict = widget.district;
    cities = districtCities[widget.district] ?? [];
    selectedCity = widget.city;
    pinController = TextEditingController(text: widget.pin);
    emailController = TextEditingController(text: widget.email);
    contactNoController = TextEditingController(text: widget.contactNo);
    aadhaarController = TextEditingController(text: widget.aadhaarNumber);
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
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

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pref = await SharedPreferences.getInstance();
        String ip = pref.getString("url") ?? "";
        String lid = pref.getString("lid") ?? "";
        String url = ip + "public_edit_profile";

        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.fields['lid'] = lid;
        request.fields['name'] = nameController.text;
        request.fields['gender'] = selectedGender!;
        request.fields['dob'] = dobController.text;
        request.fields['district'] = selectedDistrict!;
        request.fields['city'] = selectedCity!;
        request.fields['pin'] = pinController.text;
        request.fields['email'] = emailController.text;
        request.fields['contact_no'] = contactNoController.text;
        request.fields['aadhaar_number'] = aadhaarController.text;

        if (_image != null) {
          request.files.add(await http.MultipartFile.fromPath('photo', _image!.path));
        }

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsondata = json.decode(responseData);

        if (jsondata['status'] == "ok") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile updated successfully!", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true);
        } else {
          // Display error message from the backend
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsondata['message'] ?? "Failed to update profile", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred while updating the profile", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : NetworkImage(widget.photoUrl) as ImageProvider,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 35, color: Colors.grey[100])
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(nameController, "Name"),
              _buildDropdown(genders, selectedGender, "Gender"),
              _buildDatePicker(dobController, "Date of Birth"),
              _buildDropdown(districtCities.keys.toList(), selectedDistrict, "District"),
              _buildDropdown(cities, selectedCity, "City"),
              _buildTextField(pinController, "Pin Code", enabled: false),
              _buildTextField(emailController, "Email"),
              _buildTextField(contactNoController, "Contact No", keyboardType: TextInputType.number),
              _buildTextField(aadhaarController, "Aadhaar Number", keyboardType: TextInputType.number, inputFormatters: [AadhaarInputFormatter()]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Save Changes", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool enabled = true, TextInputType keyboardType = TextInputType.text, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[100],
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
          if (label == "Contact No") {
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit phone number';
            }
          }
          if (label == "Email") {
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
          }
          if (label == "Aadhaar Number") {
            if (!RegExp(r'^\d{4}\s\d{4}\s\d{4}$').hasMatch(value)) {
              return 'Please enter a valid 12-digit Aadhaar number with spaces';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedItem, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[100],
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
              selectedCity = null;
              pinController.text = '';
            } else if (label == "City") {
              selectedCity = value;
              pinController.text = cityPincodes[value] ?? '';
            } else {
              selectedGender = value;
            }
          });
        },
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}

class AadhaarInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text.replaceAll(RegExp(r'\s'), '');
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
