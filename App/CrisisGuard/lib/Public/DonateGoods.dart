import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ViewDonation.dart';
import 'home.dart'; // Import the home widget


class DonateGoodsForm extends StatefulWidget {
  const DonateGoodsForm({super.key});

  @override
  State<DonateGoodsForm> createState() => _DonateGoodsFormState();
}

class _DonateGoodsFormState extends State<DonateGoodsForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController categoryController = TextEditingController();
  TextEditingController productController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController unitController = TextEditingController();

  TextEditingController customCategoryController = TextEditingController();
  TextEditingController customProductController = TextEditingController();
  TextEditingController customUnitController = TextEditingController();

  String? selectedCategory;
  String? selectedProduct;
  String? selectedUnit;

  List<String> categories = [
    "Food",
    "Medical Supplies",
    "Clothing",
    "Water",
    "Shelter Materials",
    "Hygiene Kits",
    "Tools",
    "Electronics",
    "Fuel",
    "Communication Equipment",
    "Other"
  ];

  Map<String, List<String>> categoryProducts = {
    "Food": ["Vegetables", "Fruits", "Grains", "Dairy", "Meat", "Masala", "Other"],
    "Medical Supplies": ["Bandages", "Medicines", "Syringes", "Gloves", "Masks", "Other"],
    "Clothing": ["Shirts", "Pants", "Jackets", "Shoes", "Socks", "Other"],
    "Water": ["Bottled Water", "Water Purifiers", "Water Filters", "Other"],
    "Shelter Materials": ["Tents", "Tarps", "Blankets", "Mattresses", "Sleeping Bags", "Other"],
    "Hygiene Kits": ["Soap", "Toothpaste", "Sanitary Pads", "Shampoo", "Toilet Paper", "Other"],
    "Tools": ["Shovels", "Hammers", "Saws", "Axes", "Pliers", "Other"],
    "Electronics": ["Flashlights", "Batteries", "Radios", "Chargers", "Lanterns", "Other"],
    "Fuel": ["Gasoline", "Diesel", "Kerosene", "Propane", "Charcoal", "Other"],
    "Communication Equipment": ["Walkie-Talkies", "Satellite Phones", "Radios", "Antennas", "Batteries", "Other"],
    "Other": ["Books", "Toys", "Utensils", "Tools"]
  };

  Map<String, List<String>> productUnits = {
    "Food": ["Kg", "Liter", "Piece", "Packet"],
    "Medical Supplies": ["Piece", "Box", "Bottle"],
    "Clothing": ["Piece", "Pair"],
    "Water": ["Liter", "Bottle"],
    "Shelter Materials": ["Piece", "Set"],
    "Hygiene Kits": ["Piece", "Box"],
    "Tools": ["Piece", "Set"],
    "Electronics": ["Piece", "Set"],
    "Fuel": ["Liter", "Gallon"],
    "Communication Equipment": ["Piece", "Set"],
    "Other": ["Piece", "Box", "Liter", "Kg"]
  };

  Future<void> _donateGoods() async {
    if (_formKey.currentState!.validate()) {
      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("url").toString();
      String lid = sh.getString("lid").toString();

      try {
        var uri = Uri.parse(url + 'public_donate_goods');
        var request = http.MultipartRequest('POST', uri);

        request.fields['lid'] = lid;
        request.fields['category'] = selectedCategory == "Other"
            ? customCategoryController.text
            : selectedCategory!;
        request.fields['product'] = selectedCategory == "Other"
            ? customProductController.text
            : (selectedProduct == "Other"
            ? customProductController.text
            : selectedProduct!);
        request.fields['name'] = nameController.text;
        request.fields['quantity'] = quantityController.text;
        request.fields['unit'] = selectedUnit == "Other"
            ? customUnitController.text
            : selectedUnit!;

        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Donation Successful'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PublicViewDonations()),
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Donate Goods",
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
        elevation: 4,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdown(categories, selectedCategory, "Category", Icons.category, (value) {
                setState(() {
                  selectedCategory = value;
                  selectedProduct = null;
                  selectedUnit = null;
                  customProductController.clear();
                  customUnitController.clear();
                });
              }),
              if (selectedCategory == "Other")
                _buildTextField(customCategoryController, "Custom Category", Icons.edit),
              if (selectedCategory == "Other")
                _buildTextField(customProductController, "Custom Product Name", Icons.edit),
              if (selectedCategory != "Other")
                _buildDropdown(
                    selectedCategory != null ? categoryProducts[selectedCategory]! : [],
                    selectedProduct,
                    "Product",
                    Icons.shopping_basket,
                        (value) {
                      setState(() {
                        selectedProduct = value;
                        selectedUnit = null;
                        customUnitController.clear();
                      });
                    }),
              if (selectedProduct == "Other" && selectedCategory != "Other")
                _buildTextField(customProductController, "Custom Product Name", Icons.edit),
              _buildTextField(nameController, "Product Name", Icons.shopping_bag), // Updated icon
              _buildTextField(quantityController, "Quantity", Icons.format_list_numbered, keyboardType: TextInputType.number),
              _buildDropdown(
                  selectedCategory != null ? productUnits[selectedCategory]! : [],
                  selectedUnit,
                  "Unit",
                  Icons.straighten,
                      (value) {
                    setState(() {
                      selectedUnit = value;
                    });
                  }),
              if (selectedUnit == "Other")
                _buildTextField(customUnitController, "Custom Unit", Icons.edit),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _donateGoods,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Donate",
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

  Widget _buildDropdown(List<String> items, String? selectedItem, String label, IconData icon, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
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
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        value: selectedItem,
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }
}
