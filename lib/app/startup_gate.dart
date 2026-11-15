import 'package:flutter/material.dart';

import '../core/presentation/rotina_theme.dart';

/// Initialization errors stay recoverable without exposing technical details.
final class StartupGate extends StatefulWidget {
  const StartupGate({required this.load, required this.shell, super.key});

  final Future<Widget> Function() load;
  final Widget Function(Widget child) shell;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

final class _StartupGateState extends State<StartupGate> {
  late Future<Widget> _pending;

  @override
  void initState() {
    super.initState();
    _pending = Future.sync(widget.load);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
    future: _pending,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return snapshot.requireData;
      }
      return widget.shell(
        Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(RotinaSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: snapshot.hasError
                      ? [
                          const Icon(Icons.event_busy_rounded, size: 48),
                          const SizedBox(height: RotinaSpacing.md),
                          const Text('Não foi possível iniciar o DayToDay.'),
                          const SizedBox(height: RotinaSpacing.sm),
                          const Text(
                            'Tente novamente. Se o problema continuar, feche e abra o aplicativo.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: RotinaSpacing.lg),
                          FilledButton.icon(
                            onPressed: () => setState(() {
                              _pending = Future.sync(widget.load);
                            }),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Tentar novamente'),
                          ),
                        ]
                      : const [
                          CircularProgressIndicator(
                            semanticsLabel: 'Abrindo sua rotina',
                          ),
                          SizedBox(height: RotinaSpacing.md),
                          Text('Abrindo sua rotina…'),
                        ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
