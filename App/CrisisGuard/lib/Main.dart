import 'package:flutter/material.dart';
import 'ipset.dart';


void main() {
  runApp(const CrisisGuard());
}

class CrisisGuard extends StatefulWidget {
  const CrisisGuard({super.key});

  @override
  State<CrisisGuard> createState() => _CrisisGuard();
}

class _CrisisGuard extends State<CrisisGuard> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IpSet(),
    );
  }
}