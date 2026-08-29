import 'package:flutter/material.dart';
import 'app/app_dependencies.dart';
import 'core/presentation/rotina_theme.dart';
import 'features/dashboard/presentation/today_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(dependencies.provideTo(const RotinaJheniferApp()));
}

class RotinaJheniferApp extends StatelessWidget {
  const RotinaJheniferApp({this.home, super.key});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rotina da Jhenifer',
      theme: RotinaTheme.light,
      home: home ?? const TodayScreen(),
    );
  }
}
