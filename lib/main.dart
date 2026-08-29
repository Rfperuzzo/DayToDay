import 'package:flutter/material.dart';

void main() {
  runApp(const RotinaJheniferApp());
}

class RotinaJheniferApp extends StatelessWidget {
  const RotinaJheniferApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SizedBox.shrink(),
    );
  }
}
