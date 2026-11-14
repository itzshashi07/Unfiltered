import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

/// "<1" style label for a per-100 rate.
String rateLabel(double v) {
  if (v == 0) return '0';
  if (v < 1) return '<1';
  return v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
}

/// Protection & Prevention Lab: informational comparison only — never a
/// recommendation or prescription.
class ProtectionLabScreen extends ConsumerStatefulWidget {
  const ProtectionLabScreen({super.key});

  @override
  ConsumerState<ProtectionLabScreen> createState() =>
      _ProtectionLabScreenState();
}

class _ProtectionLabScreenState extends ConsumerState<ProtectionLabScreen> {
  String _tab = 'methods';
  String? _open;
  bool _perfect = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('protection_lab'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    if (track.index < Track.c.index || content.methods.isEmpty) {
      return const NotAvailableScreen();
    }
    final c = context.c;
    final cards = content.visible(content.preventionCards, track);
    final groups = [
      'methods',
      for (final g in const ['sti', 'vaccine', 'testing', 'care'])
        if (cards.any((x) => x.group == g)) g,
    ];
    final methods = [...content.methods.where((m) => m.typical != null)]
      ..sort(
        (a, b) => (_perfect ? a.perfect! : a.typical!).compareTo(
          _perfect ? b.perfect! : b.typical!,
        ),
      );
    final backup = content.methods.where((m) => m.typical == null).toList();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.protection_lab.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(lab: 'protection_lab', scene: 'doctor', domain: 'd07'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in groups)
                ChoicePill(
                  key: Key('prot-tab-$g'),
                  label: context.t('prot.tab.$g'),
                  selected: _tab == g,
                  onTap: () => setState(() => _tab = g),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_tab == 'methods') ...[
            Text(context.t('prot.intro'), style: context.tx.headlineSmall),
            const SizedBox(height: 8),
            Text(
              context.t('prot.explain'),
              style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
            ),
            if (track.isMinor) ...[
              const SizedBox(height: 12),
              InfoBanner(
                icon: Icons.gavel_rounded,
                color: c.warning,
                text: context.t('prot.minor'),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoicePill(
                  key: const Key('prot-typical'),
                  label: context.t('prot.typical'),
                  selected: !_perfect,
                  onTap: () => setState(() => _perfect = false),
                ),
                ChoicePill(
                  key: const Key('prot-perfect'),
                  label: context.t('prot.perfect'),
                  selected: _perfect,
                  onTap: () => setState(() => _perfect = true),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              context.t(_perfect ? 'prot.perfect.sub' : 'prot.typical.sub'),
              style: context.tx.bodySmall,
            ),
            const SizedBox(height: 14),
            for (final m in methods)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MethodCard(
                  method: m,
                  perfect: _perfect,
                  open: _open == m.id,
                  onTap: () =>
                      setState(() => _open = _open == m.id ? null : m.id),
                ),
              ),
            for (final m in backup)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  color: c.sun.withValues(alpha: context.isDark ? 0.18 : 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ObjectArt(objectForMethod(m.id), size: 52),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.lx(m.name),
                              style: context.tx.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(context.lx(m.how), style: context.tx.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        context.lx(m.note),
                        style: context.tx.bodySmall?.copyWith(color: c.ink),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            InfoBanner(
              icon: Icons.medical_services_rounded,
              text: context.t('prot.noPrescription'),
            ),
            const SizedBox(height: 14),
            Text(context.t('common.sources'), style: context.tx.labelMedium),
            const SizedBox(height: 8),
            SourceList([
              for (final r in const ['who-fp', 'who-ec'])
                if (content.ref(r) != null) content.ref(r)!,
            ]),
          ] else
            for (final card in cards.where((x) => x.group == _tab))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  key: Key('prot-card-${card.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.lx(card.title),
                        style: context.tx.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(context.lx(card.body), style: context.tx.bodyLarge),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 6),
          const ReviewNote(),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final Method method;
  final bool perfect;
  final bool open;
  final VoidCallback onTap;
  const _MethodCard({
    required this.method,
    required this.perfect,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final v = perfect ? method.perfect! : method.typical!;
    final color = v < 1 ? c.success : (v < 10 ? c.warning : c.danger);
    return AppCard(
      key: Key('method-${method.id}'),
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      semanticLabel:
          '${context.lx(method.name)}: ${context.t('prot.rate', {'n': rateLabel(v)})}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ObjectArt(objectForMethod(method.id), size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.lx(method.name),
                      style: context.tx.titleMedium,
                    ),
                    if (method.sti)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Pill(
                          context.t('prot.sti'),
                          icon: Icons.shield_rounded,
                          color: c.success.withValues(alpha: 0.16),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (v / 100).clamp(0.004, 1.0)),
                    duration: context.reducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    builder: (_, t, _) => LinearProgressIndicator(
                      value: t,
                      minHeight: 10,
                      color: color,
                      backgroundColor: c.surfaceAlt,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.t('prot.rate', {'n': rateLabel(v)}),
                style: context.tx.labelLarge,
              ),
            ],
          ),
          if (open) ...[
            const SizedBox(height: 14),
            Semantics(
              image: true,
              label: context.t('prot.grid.alt', {'n': rateLabel(v)}),
              child: _DotGrid(
                count: v < 1 ? 0 : v.round(),
                color: c.coral,
                base: c.surfaceAlt,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.t('prot.grid', {'n': rateLabel(v)}),
              style: context.tx.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(context.lx(method.how), style: context.tx.bodyLarge),
            const SizedBox(height: 12),
            _Fact(
              icon: Icons.hourglass_bottom_rounded,
              label: context.t('prot.lasts'),
              text: context.lx(method.lasts),
            ),
            _Fact(
              icon: Icons.local_pharmacy_rounded,
              label: context.t('prot.access'),
              text: context.lx(method.access),
            ),
            _Fact(
              icon: method.sti
                  ? Icons.shield_rounded
                  : Icons.remove_moderator_rounded,
              label: context.t('prot.stiLabel'),
              text: context.t(method.sti ? 'prot.sti.yes' : 'prot.sti.no'),
            ),
            const SizedBox(height: 6),
            InfoBanner(
              icon: Icons.info_outline_rounded,
              color: c.warning,
              text: context.lx(method.note),
            ),
          ],
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  const _Fact({required this.icon, required this.label, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.c.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label: ', style: context.tx.titleSmall),
                TextSpan(text: text, style: context.tx.bodyMedium),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// 100 dots = 100 people using the method for a year; highlighted = pregnancies.
class _DotGrid extends StatelessWidget {
  final int count;
  final Color color;
  final Color base;
  const _DotGrid({
    required this.count,
    required this.color,
    required this.base,
  });

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 20 / 5,
    child: CustomPaint(painter: _DotPainter(count, color, base)),
  );
}

class _DotPainter extends CustomPainter {
  final int count;
  final Color color;
  final Color base;
  _DotPainter(this.count, this.color, this.base);

  @override
  void paint(Canvas canvas, Size size) {
    const cols = 20, rows = 5;
    final cw = size.width / cols, ch = size.height / rows;
    final r = (cw < ch ? cw : ch) * 0.36;
    for (var i = 0; i < 100; i++) {
      final o = Offset((i % cols + 0.5) * cw, (i ~/ cols + 0.5) * ch);
      canvas.drawCircle(o, r, Paint()..color = i < count ? color : base);
    }
  }

  @override
  bool shouldRepaint(_DotPainter o) =>
      o.count != count || o.color != color || o.base != base;
}
