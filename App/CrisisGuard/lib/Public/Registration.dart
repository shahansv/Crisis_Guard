import 'dart:convert';
import 'dart:io';
import 'package:crisisguard/Login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  String? selectedGender;
  String? selectedDistrict;
  List<String> cities = [];
  XFile? _image;

  final List<String> genders = ['Male', 'Female', 'Other'];

  final Map<String, List<String>> districtCities = {
    "Thiruvananthapuram": ["Thiruvananthapuram", "Neyyattinkara", "Nedumangad", "Varkala", "Attingal"],
    "Kollam": ["Kollam", "Punalur", "Karunagappally", "Kottarakkara", "Paravur"],
    "Pathanamthitta": ["Pathanamthitta", "Adoor", "Thiruvalla", "Ranni", "Kozhencherry"],
    "Alappuzha": ["Alappuzha", "Cherthala", "Kayamkulam", "Mavelikkara", "Chengannur"],
    "Kottayam": ["Kottayam", "Changanassery", "Pala", "Vaikom", "Kanjirapally"],
    "Idukki": ["Painavu", "Thodupuzha", "Adimali", "Nedumkandam", "Munnar"],
    "Ernakulam": ["Kochi", "Aluva", "Kothamangalam", "Perumbavoor", "Muvattupuzha"],
    "Thrissur": ["Thrissur", "Chalakudy", "Kodungallur", "Guruvayur", "Irinjalakuda"],
    "Palakkad": ["Palakkad", "Ottapalam", "Chittur", "Mannarkkad", "Alathur"],
    "Malappuram": ["Malappuram", "Manjeri", "Perinthalmanna", "Ponnani", "Tirur"],
    "Kozhikode": ["Kozhikode", "Vatakara", "Ramanattukara", "Koyilandy", "Thamarassery"],
    "Wayanad": ["Kalpetta", "Mananthavady", "Sulthan Bathery", "Vythiri", "Pulpally"],
    "Kannur": ["Kannur", "Thalassery", "Payyannur", "Kuthuparamba", "Mattannur"],
    "Kasaragod": ["Kasaragod", "Kanhangad", "Nileshwaram", "Manjeshwaram", "Hosdurg"]
  };

  final Map<String, String> cityPincodes = {
    "Thiruvananthapuram": "695001",
    "Neyyattinkara": "695121",
    "Nedumangad": "695541",
    "Varkala": "695141",
    "Attingal": "695101",
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
    "Alappuzha": "688001",
    "Cherthala": "688524",
    "Kayamkulam": "690502",
    "Mavelikkara": "690101",
    "Chengannur": "689121",
    "Kottayam": "686001",
    "Changanassery": "686101",
    "Pala": "686575",
    "Vaikom": "686141",
    "Kanjirapally": "686507",
    "Painavu": "685603",
    "Thodupuzha": "685584",
    "Adimali": "685561",
    "Nedumkandam": "685553",
    "Munnar": "685612",
    "Kochi": "682001",
    "Aluva": "683101",
    "Kothamangalam": "686691",
    "Perumbavoor": "683542",
    "Muvattupuzha": "686661",
    "Thrissur": "680001",
    "Chalakudy": "680307",
    "Kodungallur": "680664",
    "Guruvayur": "680101",
    "Irinjalakuda": "680125",
    "Palakkad": "678001",
    "Ottapalam": "679101",
    "Chittur": "678101",
    "Mannarkkad": "678582",
    "Alathur": "678541",
    "Malappuram": "676505",
    "Manjeri": "676121",
    "Perinthalmanna": "679322",
    "Ponnani": "679577",
    "Tirur": "676101",
    "Kozhikode": "673001",
    "Vatakara": "673101",
    "Ramanattukara": "673633",
    "Koyilandy": "673305",
    "Thamarassery": "673573",
    "Kalpetta": "673121",
    "Mananthavady": "670645",
    "Sulthan Bathery": "673592",
    "Vythiri": "673576",
    "Pulpally": "673579",
    "Kannur": "670001",
    "Thalassery": "670101",
    "Payyannur": "670307",
    "Kuthuparamba": "670643",
    "Mattannur": "670702",
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
    if (_formKey.currentState!.validate() && _image != null) {
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

        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully Registered'),
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const Login()));
        }
      } catch (e) {
        print(e);
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
      appBar: AppBar(title: const Text("Registration")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
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
              _buildTextField(nameController, "Name", Icons.person),
              _buildDropdown(genders, selectedGender, "Gender", Icons.wc),
              _buildDatePicker(dobController, "Date of Birth", Icons.calendar_today),
              _buildTextField(contactNoController, "Contact Number", Icons.phone, keyboardType: TextInputType.number),
              _buildTextField(emailController, "Email", Icons.email),
              _buildDropdown(districtCities.keys.toList(), selectedDistrict, "District", Icons.location_city),
              _buildDropdown(cities, cityController.text.isEmpty ? null : cityController.text, "City", Icons.location_on),
              _buildTextField(pinController, "PIN Code", Icons.pin, enabled: false),
              _buildTextField(usernameController, "Username", Icons.person_outline),
              _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text("Register")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? selectedItem, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
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
    );
  }

  Widget _buildDatePicker(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}