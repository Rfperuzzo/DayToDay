import 'package:flutter/material.dart';
import 'app/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(dependencies.provideTo(const RotinaJheniferApp()));
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
