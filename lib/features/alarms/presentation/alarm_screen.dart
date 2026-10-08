import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/presentation/rotina_theme.dart';
import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../application/alarm_response_service.dart';
import '../domain/alarm_gateway.dart';

final class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({
    required this.alarm,
    required this.onRespond,
    this.isResponding = false,
    this.errorMessage,
    super.key,
  });

  final RingingAlarmBinding alarm;
  final ValueChanged<AlarmResponse> onRespond;
  final bool isResponding;
  final String? errorMessage;

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

final class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: RotinaColors.primary,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  RotinaColors.alarmBackground,
                  RotinaColors.primaryBright,
                  RotinaColors.primaryBright,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_active_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'ALARME TOCANDO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          _formatTime(now),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 72,
                                letterSpacing: -3,
                              ),
                        ),
                        Text(
                          _shortDate(DateTime.now()),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 42),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x4D242723),
                                blurRadius: 38,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 66,
                                height: 66,
                                decoration: const BoxDecoration(
                                  color: RotinaColors.primarySoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.alarm_rounded,
                                  color: RotinaColors.primary,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                widget.alarm.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.alarm.body,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              if (widget.errorMessage case final message?) ...[
                                const SizedBox(height: 18),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDAD6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFF93000A),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 26),
                              FilledButton.icon(
                                onPressed: widget.isResponding
                                    ? null
                                    : () => widget.onRespond(
                                        AlarmResponse.complete,
                                      ),
                                icon: const Icon(Icons.check_circle_rounded),
                                label: const Text('Concluir'),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 58),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: widget.isResponding
                                    ? null
                                    : () => widget.onRespond(
                                        AlarmResponse.nowNot,
                                      ),
                                icon: const Icon(Icons.auto_fix_high_rounded),
                                label: const Text('Agora não — reorganizar'),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  foregroundColor: RotinaColors.primary,
                                  side: const BorderSide(
                                    color: RotinaColors.outline,
                                  ),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: widget.isResponding
                                    ? null
                                    : () => widget.onRespond(
                                        AlarmResponse.skipToday,
                                      ),
                                icon: const Icon(Icons.event_busy_rounded),
                                label: const Text('Pular somente hoje'),
                                style: TextButton.styleFrom(
                                  foregroundColor: RotinaColors.textMuted,
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                              if (widget.isResponding) ...[
                                const SizedBox(height: 14),
                                const LinearProgressIndicator(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(99),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'O toque para quando você escolhe. Sem resposta até o fim da duração, reorganizo a fila por importância.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class AlarmResolvedScreen extends StatelessWidget {
  const AlarmResolvedScreen({
    required this.title,
    required this.result,
    required this.timeZone,
    required this.onDone,
    super.key,
  });

  final String title;
  final AlarmResponseResult result;
  final TimeZoneService timeZone;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final content = _resolvedContent(result, title);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        color: RotinaColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        content.icon,
                        color: RotinaColors.primary,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      content.heading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      content.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (result.response == AlarmResponse.nowNot) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: RotinaColors.outline),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'NOVO HORÁRIO',
                              style: TextStyle(
                                color: RotinaColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _dateAndTime(
                                timeZone,
                                result.occurrence.scheduledStartUtc,
                              ),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: RotinaColors.primary),
                            ),
                            if (result.displacedCount > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${result.displacedCount} ${result.displacedCount == 1 ? 'atividade foi ajustada' : 'atividades foram ajustadas'} para evitar conflitos.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (!result.alarmsSynchronized) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFDAD6),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'A rotina foi salva, mas o Android não confirmou o novo alarme. Revise os acessos no app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF93000A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 34),
                    FilledButton.icon(
                      onPressed: onDone,
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Voltar para minha rotina'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

({IconData icon, String heading, String message}) _resolvedContent(
  AlarmResponseResult result,
  String title,
) => switch (result.response) {
  AlarmResponse.complete => (
    icon: Icons.check_rounded,
    heading: 'Feito!',
    message:
        '${result.occurrence.status == OccurrenceStatus.completed ? 'Atividade concluída' : 'Tudo certo'} e registrada na sua rotina.',
  ),
  AlarmResponse.skipToday => (
    icon: Icons.spa_rounded,
    heading: 'Tudo bem por hoje',
    message: 'Esta ocorrência foi pulada sem mexer nos próximos dias.',
  ),
  AlarmResponse.nowNot => (
    icon: Icons.auto_fix_high_rounded,
    heading: 'Rotina resgatada',
    message:
        '“$title” encontrou o próximo espaço livre sem apagar sua recorrência original.',
  ),
};

String _formatTime(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

String _shortDate(DateTime date) {
  const weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day}';
}

String _dateAndTime(TimeZoneService timeZone, DateTime utc) {
  final local = timeZone.toLocal(utc);
  const weekdays = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '${weekdays[local.weekday - 1]}, $time';
}
