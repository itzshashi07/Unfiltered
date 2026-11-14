import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../ui/widgets.dart';

/// Privacy policy, medical disclaimer and credits. Each document is a list of
/// (heading, body) string keys: `legal.<doc>.<n>.h` / `.b`.
class LegalScreen extends StatelessWidget {
  final String doc;
  const LegalScreen(this.doc, {super.key});

  static const sections = {'privacy': 6, 'disclaimer': 5, 'credits': 5};

  @override
  Widget build(BuildContext context) {
    final d = sections.containsKey(doc) ? doc : 'disclaimer';
    return Scaffold(
      appBar: AppBar(title: Text(context.t('legal.$d.title'))),
      body: PageBody(
        children: [
          Text(context.t('legal.$d.title'), style: context.tx.displaySmall),
          const SizedBox(height: 6),
          Text(context.t('legal.draft'), style: context.tx.bodySmall),
          for (var i = 1; i <= sections[d]!; i++) ...[
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                context.t('legal.$d.$i.h'),
                style: context.tx.titleLarge,
              ),
            ),
            const SizedBox(height: 6),
            Text(context.t('legal.$d.$i.b'), style: context.tx.bodyLarge),
          ],
          const SizedBox(height: 20),
          const ReviewNote(),
        ],
      ),
    );
  }
}
