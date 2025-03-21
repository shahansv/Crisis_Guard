import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart'; // Import for FilteringTextInputFormatter

import 'ViewPayDonation.dart'; // Import the lottie package

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  TextEditingController _amountController = TextEditingController();
  String enteredAmount = "";
  bool showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");

    final sh = await SharedPreferences.getInstance();
    String url = sh.getString("url") ?? "";
    String lid = sh.getString("lid") ?? "";

    var paymentData = await http.post(
      Uri.parse(url + "public_pay_donation"),
      body: {
        'lid': lid,
        'amount': enteredAmount, // Sending amount to the backend
      },
    );

    var jsonResponse = json.decode(paymentData.body);
    String status = jsonResponse['status'].toString();

    if (status == "ok") {
      setState(() {
        showSuccessAnimation = true;
      });

      // Show the animation for a few seconds before navigating
      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PublicViewPayments()), // Navigate to PublicViewPayments
        );
      });
    } else {
      print("Server-side payment confirmation failed");
      _showSnackBar("Payment confirmation failed.", Colors.red);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.message}");
    _showSnackBar("Payment failed. Please try again.", Colors.red);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  void _openCheckout() {
    String amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showSnackBar("Please enter an amount", Colors.orange);
      return;
    }
    try {
      int amount = int.parse(amountText) * 100;
      enteredAmount = amountText; // Store the entered amount
      var options = {
        'key': 'rzp_test_edrzdb8Gbx5U5M',
        'amount': amount,
        'name': 'Payment for booking',
        'description': 'Payment of $amountText Rupees',
        'prefill': {
          'contact': '9747583510',
          'email': 'shahanvs007@gmail.com'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      _showSnackBar("Error: $e", Colors.red);
      print("Error in opening Razorpay: $e");
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Payment Page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly // Allow only digits
                  ],
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _openCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Pay Now',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          if (showSuccessAnimation)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Lottie.asset(
                    'assets/Payment Success Animation.json', // Path to your success animation file
                    width: 400, // Increase the width as needed
                    height: 400, // Increase the height as needed
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}