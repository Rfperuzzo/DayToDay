import 'package:flutter/material.dart';

import '../../../core/presentation/rotina_theme.dart';
import '../domain/alarm_permission_gateway.dart';

Future<void> showAlarmAccessSheet(
  BuildContext context,
  AlarmPermissionGateway permissions,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: false,
  enableDrag: false,
  builder: (_) => AlarmAccessSheet(permissions: permissions),
);

final class AlarmAccessSheet extends StatefulWidget {
  const AlarmAccessSheet({required this.permissions, super.key});

  final AlarmPermissionGateway permissions;

  @override
  State<AlarmAccessSheet> createState() => _AlarmAccessSheetState();
}

final class _AlarmAccessSheetState extends State<AlarmAccessSheet> {
  late final AppLifecycleListener _lifecycle;
  AlarmCapabilities? _capabilities;
  bool _busy = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        if (!_busy) _refresh();
      },
    );
    _refresh();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh({bool request = false}) async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      final capabilities = request
          ? await widget.permissions.requestRequiredAccess()
          : await widget.permissions.check();
      if (mounted) setState(() => _capabilities = capabilities);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _capabilities = null;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _capabilities;
    return PopScope(
      canPop: !_busy,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(RotinaSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Acessos dos alarmes',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => Navigator.pop(context),
                    tooltip: 'Fechar',
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: RotinaSpacing.sm),
              Text(
                'Suas atividades ficam neste aparelho. Estes acessos ajudam o alarme a funcionar com a tela bloqueada e durante o Não Perturbe.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: RotinaSpacing.lg),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.all(RotinaSpacing.md),
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Verificando acessos',
                    ),
                  ),
                ),
              if (_failed)
                Semantics(
                  liveRegion: true,
                  child: const Text(
                    'Não foi possível verificar os acessos. Tente novamente.',
                  ),
                ),
              if (!_busy && state != null) ...[
                for (final entry in [
                  ('Notificações', state.notifications),
                  ('Agendamento exato', state.exactScheduling),
                  ('Tela cheia', state.fullScreen),
                  ('Não Perturbe', state.doNotDisturbAccess),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: RotinaSpacing.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          entry.$2
                              ? Icons.check_circle_outline_rounded
                              : Icons.info_outline_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: RotinaSpacing.sm),
                        Expanded(
                          child: Text(
                            '${entry.$1}: ${entry.$2 ? "liberado" : "precisa de acesso"}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: RotinaSpacing.md),
                Text(
                  state.fullyOperational
                      ? 'Os acessos estão liberados. O funcionamento também depende das restrições do Android e do fabricante.'
                      : 'Você pode continuar organizando a rotina. Sem estes acessos, o Android pode limitar os alarmes.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: RotinaSpacing.lg),
              FilledButton.icon(
                onPressed: _busy ? null : () => _refresh(request: !_failed),
                icon: Icon(
                  _failed ? Icons.refresh_rounded : Icons.settings_outlined,
                ),
                label: Text(
                  _failed ? 'Tentar novamente' : 'Revisar acessos no Android',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
