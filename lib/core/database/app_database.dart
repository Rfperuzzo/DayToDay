import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('ActivityRow')
class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get durationMinutes => integer()();
  TextColumn get priority => text()();
  TextColumn get recurrenceType => text()();
  DateTimeColumn get oneOffAtUtc => dateTime().nullable()();
  IntColumn get weekdaysMask => integer().nullable()();
  IntColumn get localHour => integer().nullable()();
  IntColumn get localMinute => integer().nullable()();
  IntColumn get preparationLeadMinutes => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('OccurrenceRow')
class Occurrences extends Table {
  TextColumn get id => text()();
  IntColumn get nativeAlarmId => integer()();
  TextColumn get activityId => text().references(Activities, #id)();
  DateTimeColumn get originalStartUtc => dateTime()();
  DateTimeColumn get scheduledStartUtc => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get priority => text()();
  TextColumn get status => text()();
  IntColumn get attempt => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SubtaskRow')
class Subtasks extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text().references(Activities, #id)();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get completedAtUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ActivityEventRow')
class ActivityEvents extends Table {
  TextColumn get id => text()();
  TextColumn get occurrenceId => text().references(Occurrences, #id)();
  TextColumn get type => text()();
  DateTimeColumn get occurredAtUtc => dateTime()();
  DateTimeColumn get previousStartUtc => dateTime().nullable()();
  DateTimeColumn get nextStartUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('UserPreferenceRow')
class UserPreferenceRows extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get dayStartMinutes => integer().withDefault(const Constant(420))();
  IntColumn get dayEndMinutes => integer().withDefault(const Constant(1320))();
  IntColumn get maxSameDayReplans => integer().withDefault(const Constant(3))();
  IntColumn get scheduleHorizonDays =>
      integer().withDefault(const Constant(30))();
  IntColumn get maxPendingAlarms =>
      integer().withDefault(const Constant(200))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AppMetadataRow')
class AppMetadataRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Activities,
    Occurrences,
    Subtasks,
    ActivityEvents,
    UserPreferenceRows,
    AppMetadataRows,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'rotina_andriele',
          native: const DriftNativeOptions(shareAcrossIsolates: true),
        ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(subtasks);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
