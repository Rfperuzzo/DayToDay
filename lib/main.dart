import 'package:flutter/material.dart';
import 'app/app_dependencies.dart';
import 'core/presentation/rotina_theme.dart';
import 'features/dashboard/presentation/today_screen.dart';
import 'features/alarms/presentation/alarm_router.dart';
import 'features/home_widget/presentation/day_widget_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dependencies = await AppDependencies.create();
  runApp(dependencies.provideTo(const RotinaAndrieleApp()));
}

class RotinaAndrieleApp extends StatelessWidget {
  const RotinaAndrieleApp({this.home, super.key});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rotina da Andriele',
      theme: RotinaTheme.light,
      home:
          home ??
          const DayWidgetBridge(child: AlarmRouter(child: TodayScreen())),
    );
  }
}
