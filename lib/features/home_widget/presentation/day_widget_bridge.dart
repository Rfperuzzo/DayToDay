import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_dependencies.dart';
import '../../../core/time/time_zone_service.dart';
import '../../activities/domain/activity.dart';
import '../../activities/domain/activity_occurrence.dart';
import '../../dashboard/application/day_providers.dart';
import '../application/day_widget_snapshot_builder.dart';
import '../domain/day_widget_gateway.dart';

final class DayWidgetBridge extends ConsumerStatefulWidget {
  const DayWidgetBridge({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DayWidgetBridge> createState() => _DayWidgetBridgeState();
}

final class _DayWidgetBridgeState extends ConsumerState<DayWidgetBridge> {
  StreamSubscription<DayWidgetOpenRequest>? _subscription;
  String? _lastSignature;

  @override
  void initState() {
    super.initState();
    final gateway = ref.read(dayWidgetGatewayProvider);
    _subscription = gateway.openRequests.listen((request) {
      ref.read(dayWidgetOpenRequestProvider.notifier).open(request);
      unawaited(gateway.acknowledgeOpenRequest());
    });
    unawaited(gateway.initialize());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(allActivitiesProvider);
    final occurrences = ref.watch(widgetOccurrencesProvider);
    if (activities case AsyncData(value: final activityItems)) {
      if (occurrences case AsyncData(value: final occurrenceItems)) {
        _queueUpdate(activityItems, occurrenceItems);
      }
    }
    return widget.child;
  }

  void _queueUpdate(
    List<Activity> activities,
    List<ActivityOccurrence> occurrences,
  ) {
    final today = dateOnly(DateTime.now());
    final timeZone = ref.read(timeZoneServiceProvider);
    final bundle = DayWidgetBundle(
      days: [
        for (var offset = 0; offset < 7; offset++)
          DayWidgetSnapshotBuilder.build(
            localDay: today.add(Duration(days: offset)),
            activities: activities,
            occurrences: _occurrencesForDay(
              occurrences,
              today.add(Duration(days: offset)),
              timeZone,
            ),
            timeZone: timeZone,
          ),
      ],
    );
    final fullSignature = jsonEncode(bundle.toJson());
    if (_lastSignature == fullSignature) {
      return;
    }
    _lastSignature = fullSignature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(dayWidgetGatewayProvider).update(bundle));
      }
    });
  }
}

List<ActivityOccurrence> _occurrencesForDay(
  List<ActivityOccurrence> occurrences,
  DateTime day,
  TimeZoneService timeZone,
) => [
  for (final occurrence in occurrences)
    if (_sameDay(timeZone.toLocal(occurrence.scheduledStartUtc), day))
      occurrence,
];

bool _sameDay(DateTime left, DateTime right) =>
    left.year == right.year &&
    left.month == right.month &&
    left.day == right.day;
