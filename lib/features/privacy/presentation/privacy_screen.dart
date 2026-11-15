import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/presentation/rotina_theme.dart';

const publicPrivacyPolicyUrl =
    'https://rfperuzzo.github.io/DayToDay/privacidade.html';

final class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

final class _PrivacyScreenState extends State<PrivacyScreen> {
  static const _channel = MethodChannel('com.senhoritajhenifer.rotina/privacy');
  late final Future<String> _policy = rootBundle.loadString(
    'assets/legal/privacy_policy.md',
  );

  Future<void> _openPublicPolicy() async {
    try {
      await _channel.invokeMethod<void>('openPublicPolicy');
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir o navegador. Copie o link abaixo.',
          ),
        ),
      );
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abra o link abaixo no seu navegador.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Privacidade e suporte')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(RotinaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seus dados e suas escolhas',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: RotinaSpacing.md),
            const Text(
              'Leia a política aqui, mesmo sem internet. Para dúvidas, entre em contato: thalesmelodasilva@gmail.com.',
            ),
            const SizedBox(height: RotinaSpacing.md),
            FilledButton.icon(
              onPressed: _openPublicPolicy,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Abrir política pública'),
            ),
            const SizedBox(height: RotinaSpacing.sm),
            const SelectableText(publicPrivacyPolicyUrl),
            const SizedBox(height: RotinaSpacing.lg),
            FutureBuilder<String>(
              future: _policy,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Não foi possível ler a política. Use o link público ou fale com o suporte.',
                  );
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator(
                    semanticsLabel: 'Carregando política',
                  );
                }
                return SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final paragraph
                          in snapshot.data!
                              .replaceAll('\r\n', '\n')
                              .trim()
                              .split('\n\n'))
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: RotinaSpacing.md,
                          ),
                          child: Text(
                            paragraph
                                .replaceFirst(RegExp(r'^#{1,2} '), '')
                                .replaceAll('\n', ' '),
                            style: paragraph.startsWith('# ')
                                ? Theme.of(context).textTheme.headlineSmall
                                : paragraph.startsWith('## ')
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
