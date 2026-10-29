# DayToDay pilot: limited source excerpts

Scope: button hierarchy only. Verbatim excerpts, not a full-app review. No device observation. Preserve offline behavior, alarms, persistence and neutral palette.


## lib/core/presentation/rotina_theme.dart, lines 108-115
```dart
108:       ),
109:       filledButtonTheme: FilledButtonThemeData(
110:         style: FilledButton.styleFrom(
111:           minimumSize: const Size(48, 52),
112:           shape: const StadiumBorder(),
113:           textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
114:         ),
115:       ),
```


## lib/features/dashboard/presentation/today_screen.dart, lines 389-400
```dart
389:     return Scaffold(
390:       floatingActionButton: onAddRequested == null
391:           ? null
392:           : FloatingActionButton.large(
393:               onPressed: onAddRequested,
394:               tooltip: 'Adicionar atividade',
395:               backgroundColor: RotinaColors.primary,
396:               foregroundColor: Colors.white,
397:               shape: const CircleBorder(),
398:               child: const Icon(Icons.add_rounded, size: 34),
399:             ),
400:       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
```


## lib/features/activities/presentation/new_activity_sheet.dart, lines 265-282
```dart
265:                 FilledButton.icon(
266:                   onPressed: _saving ? null : _save,
267:                   icon: _saving
268:                       ? const SizedBox.square(
269:                           dimension: 18,
270:                           child: CircularProgressIndicator(
271:                             strokeWidth: 2,
272:                             color: Colors.white,
273:                           ),
274:                         )
275:                       : const Icon(Icons.add_alarm_rounded),
276:                   label: Text(
277:                     _saving ? 'Salvando…' : 'Salvar e preparar alarme',
278:                   ),
279:                   style: FilledButton.styleFrom(
280:                     minimumSize: const Size(double.infinity, 56),
281:                   ),
282:                 ),
```
