-- Snapshot of the six tables before schema 3 (app baseline fdb268d).
CREATE TABLE activities (
 id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, notes TEXT NOT NULL DEFAULT '',
 duration_minutes INTEGER NOT NULL, priority TEXT NOT NULL, recurrence_type TEXT NOT NULL,
 one_off_at_utc INTEGER, weekdays_mask INTEGER, local_hour INTEGER, local_minute INTEGER,
 preparation_lead_minutes INTEGER, is_active INTEGER NOT NULL DEFAULT 1,
 created_at_utc INTEGER NOT NULL, updated_at_utc INTEGER NOT NULL
);
CREATE TABLE occurrences (
 id TEXT NOT NULL PRIMARY KEY, native_alarm_id INTEGER NOT NULL,
 activity_id TEXT NOT NULL REFERENCES activities(id), original_start_utc INTEGER NOT NULL,
 scheduled_start_utc INTEGER NOT NULL, duration_minutes INTEGER NOT NULL,
 priority TEXT NOT NULL, status TEXT NOT NULL, attempt INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE subtasks (
 id TEXT NOT NULL PRIMARY KEY, activity_id TEXT NOT NULL REFERENCES activities(id),
 title TEXT NOT NULL, position INTEGER NOT NULL, is_completed INTEGER NOT NULL DEFAULT 0,
 created_at_utc INTEGER NOT NULL, completed_at_utc INTEGER
);
CREATE TABLE activity_events (
 id TEXT NOT NULL PRIMARY KEY, occurrence_id TEXT NOT NULL REFERENCES occurrences(id),
 type TEXT NOT NULL, occurred_at_utc INTEGER NOT NULL, previous_start_utc INTEGER, next_start_utc INTEGER
);
CREATE TABLE user_preference_rows (
 id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
 day_start_minutes INTEGER NOT NULL DEFAULT 420, day_end_minutes INTEGER NOT NULL DEFAULT 1320,
 max_same_day_replans INTEGER NOT NULL DEFAULT 3, schedule_horizon_days INTEGER NOT NULL DEFAULT 30,
 max_pending_alarms INTEGER NOT NULL DEFAULT 200
);
CREATE TABLE app_metadata_rows (key TEXT NOT NULL PRIMARY KEY, value TEXT NOT NULL);
INSERT INTO activities VALUES ('legacy','Estudar','Preservar anotação',45,'high','weekly',NULL,17,8,30,NULL,1,1794646800,1794646800);
INSERT INTO occurrences VALUES ('legacy:old',12345,'legacy',1794646800,1794650400,45,'high','completed',2);
INSERT INTO subtasks VALUES ('sub','legacy','Separar material',0,1,1794646800,1794650400);
INSERT INTO activity_events VALUES ('event','legacy:old','completed',1794650400,NULL,NULL);
INSERT INTO user_preference_rows VALUES (1,480,1260,2,21,100);
INSERT INTO app_metadata_rows VALUES ('keep','unchanged');
PRAGMA user_version=2;
