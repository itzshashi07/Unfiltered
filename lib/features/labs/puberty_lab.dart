import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

const _minAge = 7.0;
const _maxAge = 19.0;

class PubertyLabScreen extends ConsumerStatefulWidget {
  const PubertyLabScreen({super.key});

  @override
  ConsumerState<PubertyLabScreen> createState() => _PubertyLabScreenState();
}

class _PubertyLabScreenState extends ConsumerState<PubertyLabScreen> {
  String _group = 'all';
  double _age = 11;
  String? _open;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('puberty_lab'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    if (context.track == Track.a || content.pubertyChanges.isEmpty) {
      return const NotAvailableScreen();
    }
    final c = context.c;
    final changes = [
      for (final p in content.pubertyChanges)
        if (_group == 'all' || p.group == 'all' || p.group == _group) p,
    ]..sort((a, b) => a.from.compareTo(b.from));

    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.puberty_lab.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(lab: 'puberty_lab', scene: 'grow', domain: 'd02'),
          Text(context.t('puberty.intro'), style: context.tx.headlineSmall),
          const SizedBox(height: 12),
          // ── Hormone signal cascade
          AppCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Palette.dark, Color(0xFF3B2F96)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('puberty.cascade.title'),
                  style: context.tx.titleMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Semantics(
                  image: true,
                  label: context.t('puberty.cascade.alt'),
                  child: SizedBox(
                    height: 120,
                    child: _Cascade(
                      labels: [
                        context.t('puberty.node.brain'),
                        context.t('puberty.node.pituitary'),
                        context.t('puberty.node.gonads'),
                        context.t('puberty.node.body'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  context.t('puberty.cascade.body'),
                  style: context.tx.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(context.t('puberty.timeline'), style: context.tx.titleLarge),
          const SizedBox(height: 4),
          Text(
            context.t('puberty.timeline.sub'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in const ['all', 'f', 'm'])
                ChoicePill(
                  key: Key('puberty-group-$g'),
                  label: context.t('puberty.group.$g'),
                  selected: _group == g,
                  onTap: () => setState(() => _group = g),
                ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.t('puberty.age', {'n': _age.round()}),
                      style: context.tx.titleMedium,
                    ),
                    const Spacer(),
                    Pill(
                      context.t('puberty.active', {
                        'n': changes
                            .where((p) => _age >= p.from && _age <= p.to)
                            .length,
                      }),
                      icon: Icons.bolt_rounded,
                    ),
                  ],
                ),
                Slider(
                  key: const Key('puberty-age'),
                  value: _age,
                  min: _minAge,
                  max: _maxAge,
                  divisions: (_maxAge - _minAge).round(),
                  label: '${_age.round()}',
                  semanticFormatterCallback: (v) =>
                      context.t('puberty.age', {'n': v.round()}),
                  onChanged: (v) => setState(() => _age = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final p in changes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ChangeRow(
                change: p,
                age: _age,
                open: _open == p.id,
                onTap: () =>
                    setState(() => _open = _open == p.id ? null : p.id),
              ),
            ),
          const SizedBox(height: 10),
          Text(context.t('puberty.remember'), style: context.tx.titleLarge),
          const SizedBox(height: 10),
          for (final n in content.pubertyNotes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InfoBanner(
                icon: Icons.favorite_rounded,
                color: c.coral,
                text: context.lx(n),
              ),
            ),
          const SizedBox(height: 6),
          const ReviewNote(),
        ],
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  final PubertyChange change;
  final double age;
  final bool open;
  final VoidCallback onTap;
  const _ChangeRow({
    required this.change,
    required this.age,
    required this.open,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final inRange = age >= change.from && age <= change.to;
    final color = switch (change.group) {
      'f' => c.coral,
      'm' => c.blue,
      _ => c.primary,
    };
    final status = inRange
        ? context.t('puberty.status.now')
        : (age < change.from
              ? context.t('puberty.status.later')
              : context.t('puberty.status.past'));
    return AppCard(
      key: Key('puberty-${change.id}'),
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      semanticLabel:
          '${context.lx(change.name)}, ${context.t('puberty.range', {'from': change.from.round(), 'to': change.to.round()})}, $status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.lx(change.name),
                  style: context.tx.titleMedium,
                ),
              ),
              Pill(
                status,
                icon: inRange ? Icons.bolt_rounded : Icons.schedule_rounded,
                color: inRange ? color.withValues(alpha: 0.2) : c.surfaceAlt,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, box) {
              double x(double a) =>
                  (a - _minAge) / (_maxAge - _minAge) * box.maxWidth;
              return SizedBox(
                height: 30,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 6,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: context.reducedMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      left: x(change.from),
                      width: math.max(10, x(change.to) - x(change.from)),
                      top: 6,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: inRange
                              ? color
                              : color.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Positioned(
                      left: x(age) - 1.5,
                      top: 0,
                      child: Container(width: 3, height: 24, color: c.ink),
                    ),
                  ],
                ),
              );
            },
          ),
          Text(
            context.t('puberty.range', {
              'from': change.from.round(),
              'to': change.to.round(),
            }),
            style: context.tx.bodySmall,
          ),
          if (open) ...[
            const SizedBox(height: 10),
            Text(context.lx(change.desc), style: context.tx.bodyLarge),
          ],
        ],
      ),
    );
  }
}

/// Animated "signal" diagram: brain -> pituitary -> ovaries/testes -> body.
class _Cascade extends StatefulWidget {
  final List<String> labels;
  const _Cascade({required this.labels});

  @override
  State<_Cascade> createState() => _CascadeState();
}

class _CascadeState extends State<_Cascade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reducedMotion) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.psychology_rounded,
      Icons.hub_rounded,
      Icons.spa_rounded,
      Icons.accessibility_new_rounded,
    ];
    const colors = [Palette.blue, Palette.sun, Palette.coral, Palette.mint];
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          painter: _CascadePainter(_c.value),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors[i],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icons[i], color: Palette.dark, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.labels[i],
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.noScaling,
                        style: context.tx.labelSmall?.copyWith(
                          color: Colors.white,
                          letterSpacing: 0,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CascadePainter extends CustomPainter {
  final double t;
  _CascadePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / 4;
    const y = 26.0;
    final line = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final a = Offset(w * i + w / 2 + 30, y);
      final b = Offset(w * (i + 1) + w / 2 - 30, y);
      canvas.drawLine(a, b, line);
      for (final phase in [0.0, 0.5]) {
        final v = (t + phase + i * 0.17) % 1;
        canvas.drawCircle(
          Offset.lerp(a, b, v)!,
          4.5,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CascadePainter o) => o.t != t;
}
