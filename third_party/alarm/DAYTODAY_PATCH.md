# DayToDay local patch — alarm 5.12.0

Project-local copy of the already installed dependency. MIT LICENSE is unchanged.
Required runtime sources/assets and original package metadata are preserved;
examples/dev tools are not imported. DAYTODAY_PATCH.json records original hashes.

Android one-shot playback previously ended audio/vibration without releasing
ringingAlarmIds or the FIFO queue. The single patched native file now posts the
normal notification Stop path on playback completion, guarded by service, ID and
scheduled timestamp ownership. This unsaves the alarm, notifies Flutter, promotes
the next queued alarm and cleans up foreground state. It does not acknowledge or
complete an activity in the DayToDay database. Looping alarms are unchanged.

No new permissions, exported components, network calls or API credentials.
The app overrides AlarmReceiver to exported=false; explicit PendingIntents still
deliver inside the package. Tests must cover two simultaneous one-shot alarms,
manual stop racing completion, and foreground cleanup on the Android AVD. Other
devices, boot restrictions and iOS require their own validation before release.

When upgrading upstream, compare this small patch rather than overwriting it.
Never modify the shared pub cache to apply this fix.
