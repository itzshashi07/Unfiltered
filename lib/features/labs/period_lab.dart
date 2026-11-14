import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

/// Phase index (0 menstrual, 1 follicular, 2 ovulation, 3 luteal) for a day
/// of a teaching-model cycle. Ovulation is modelled ~14 days before the next
/// period; real cycles vary and this must never be used to predict fertility.
int cyclePhaseIndex(int day, int length) {
  final ov = length - 14;
  if (day <= 5) return 0;
  if (day < ov) return 1;
  if (day == ov) return 2;
  return 3;
}

double _gauss(double x, double mu, double sigma) =>
    math.exp(-((x - mu) * (x - mu)) / (2 * sigma * sigma));

/// Illustrative hormone curve shapes (0-1). Not measurements.
double hormoneLevel(int hormone, double day, int length) {
  final ov = (length - 14).toDouble();
  return switch (hormone) {
    0 =>
      0.14 +
          0.72 * _gauss(day, ov - 1, 2.6) +
          0.34 * _gauss(day, ov + 7, 3.4), // oestrogen
    1 => 0.05 + 0.86 * _gauss(day, ov + 7, 3.6), // progesterone
    2 => 0.08 + 0.88 * _gauss(day, ov - 0.6, 0.9), // LH
    _ =>
      0.16 +
          0.16 * _gauss(day, 3, 3) +
          0.42 * _gauss(day, ov - 0.6, 1.0), // FSH
  };
}

/// Relative thickness (0-1) of the uterus lining across the model cycle.
double liningLevel(double day, int length) {
  final ov = (length - 14).toDouble();
  if (day <= 5) return 0.55 - 0.4 * (day - 1) / 4;
  if (day <= ov) return 0.15 + 0.55 * (day - 5) / math.max(1, ov - 5);
  return 0.7 + 0.3 * math.min(1, (day - ov) / 8);
}

const _phaseColors = [
  Color(0xFFFF677B),
  Color(0xFF80B9FF),
  Color(0xFFFFC95C),
  Color(0xFF9B86FF),
];
const _hormoneColors = [
  Color(0xFFFF677B),
  Color(0xFF765BFF),
  Color(0xFFE39A00),
  Color(0xFF1FA67A),
];
const _hormoneKeys = [
  'period.h.e',
  'period.h.p',
  'period.h.lh',
  'period.h.fsh',
];

class PeriodLabScreen extends ConsumerStatefulWidget {
  const PeriodLabScreen({super.key});

  @override
  ConsumerState<PeriodLabScreen> createState() => _PeriodLabScreenState();
}

class _PeriodLabScreenState extends ConsumerState<PeriodLabScreen> {
  int _length = 28;
  int _day = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('period_lab'),
    );
  }

  void _fromOffset(Offset local, double size) {
    final d = local - Offset(size / 2, size / 2);
    if (d.distance < size * 0.18) return;
    var a = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (a < 0) a += math.pi * 2;
    setState(
      () => _day =
          (a / (math.pi * 2) * _length).floor().clamp(0, _length - 1) + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    if (context.track == Track.a || content.cyclePhases.length < 4) {
      return const NotAvailableScreen();
    }
    final c = context.c;
    final pi = cyclePhaseIndex(_day, _length);
    final phase = content.cyclePhases[pi];
    final lining = liningLevel(_day.toDouble(), _length);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.period_lab.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(lab: 'period_lab'),
          Text(context.t('period.intro'), style: context.tx.headlineSmall),
          const SizedBox(height: 10),
          InfoBanner(
            key: const Key('period-disclaimer'),
            icon: Icons.warning_amber_rounded,
            color: c.warning,
            text: context.t('period.notContraception'),
          ),
          const SizedBox(height: 16),
          // ── Cycle wheel
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final size = box.maxWidth;
                    return Semantics(
                      label: context.t('period.wheel.alt', {
                        'day': _day,
                        'total': _length,
                        'phase': context.lx(phase.name),
                      }),
                      child: GestureDetector(
                        onPanUpdate: (d) => _fromOffset(d.localPosition, size),
                        onTapDown: (d) => _fromOffset(d.localPosition, size),
                        child: CustomPaint(
                          painter: _WheelPainter(
                            _day,
                            _length,
                            c.surface,
                            c.ink,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.t('period.day', {'n': _day}),
                                  key: const Key('period-day'),
                                  style: context.tx.displaySmall,
                                ),
                                const SizedBox(height: 4),
                                Pill(
                                  context.lx(phase.name),
                                  color: _phaseColors[pi],
                                  foreground: Palette.dark,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Slider(
            key: const Key('period-slider'),
            value: _day.toDouble(),
            min: 1,
            max: _length.toDouble(),
            divisions: _length - 1,
            label: context.t('period.day', {'n': _day}),
            semanticFormatterCallback: (v) =>
                context.t('period.day', {'n': v.round()}),
            onChanged: (v) => setState(() => _day = v.round()),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 4; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _phaseColors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        context.lx(content.cyclePhases[i].name),
                        style: context.tx.labelMedium,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Phase narration
          FadeSlide(
            key: ValueKey(pi),
            child: AppCard(
              key: const Key('period-phase-card'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _phaseColors[pi],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.lx(phase.name),
                          style: context.tx.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(context.lx(phase.days), style: context.tx.bodySmall),
                  const SizedBox(height: 10),
                  Text(context.lx(phase.desc), style: context.tx.bodyLarge),
                  const SizedBox(height: 12),
                  _Labeled(
                    icon: Icons.science_rounded,
                    label: context.t('period.hormones'),
                    text: context.lx(phase.hormones),
                  ),
                  const SizedBox(height: 10),
                  _Labeled(
                    icon: Icons.mood_rounded,
                    label: context.t('period.feel'),
                    text: context.lx(phase.feel),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Uterus lining
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('period.lining'), style: context.tx.titleMedium),
                const SizedBox(height: 10),
                Semantics(
                  label:
                      '${context.t('period.lining')}: ${(lining * 100).round()}%',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 54,
                      color: const Color(0xFFFF9AA8).withValues(alpha: 0.35),
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: context.reducedMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        height: 6 + lining * 46,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFE2556A), Color(0xFF8E2740)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.t('period.lining.sub'),
                  style: context.tx.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Hormone curves
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.t('period.curves'), style: context.tx.titleMedium),
                const SizedBox(height: 4),
                Text(
                  context.t('period.curves.sub'),
                  style: context.tx.bodySmall,
                ),
                const SizedBox(height: 12),
                Semantics(
                  image: true,
                  label: context.t('period.curves.alt'),
                  child: SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _CurvePainter(_day, _length, c.outline, c.ink),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var h = 0; h < 4; h++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _hormoneColors[h],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.t(_hormoneKeys[h]),
                            style: context.tx.bodyMedium,
                          ),
                        ),
                        Text(
                          context.t(
                            'period.level.${hormoneLevel(h, _day.toDouble(), _length) > 0.55 ? 'high' : (hormoneLevel(h, _day.toDouble(), _length) > 0.28 ? 'mid' : 'low')}',
                          ),
                          style: context.tx.labelMedium,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('visual.products'),
                  style: context.tx.titleMedium,
                ),
                const SizedBox(height: 12),
                const PeriodProducts(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ── Natural variation
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('period.length', {'n': _length}),
                  style: context.tx.titleMedium,
                ),
                Slider(
                  key: const Key('period-length'),
                  value: _length.toDouble(),
                  min: 21,
                  max: 35,
                  divisions: 14,
                  label: '$_length',
                  semanticFormatterCallback: (v) =>
                      context.t('period.length', {'n': v.round()}),
                  onChanged: (v) => setState(() {
                    _length = v.round();
                    _day = _day.clamp(1, _length);
                  }),
                ),
                Text(
                  context.t('period.length.sub'),
                  style: context.tx.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final n in content.cycleNotes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InfoBanner(
                icon: Icons.info_outline_rounded,
                text: context.lx(n),
              ),
            ),
          const ReviewNote(),
        ],
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  const _Labeled({required this.icon, required this.label, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: context.c.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.tx.labelMedium?.copyWith(color: context.c.inkSoft),
            ),
            const SizedBox(height: 2),
            Text(text, style: context.tx.bodyMedium),
          ],
        ),
      ),
    ],
  );
}

class _WheelPainter extends CustomPainter {
  final int day;
  final int length;
  final Color surface;
  final Color ink;
  _WheelPainter(this.day, this.length, this.surface, this.ink);

  @override
  void paint(Canvas canvas, Size size) {
    final o = size.center(Offset.zero);
    final r = size.width / 2;
    final seg = math.pi * 2 / length;
    for (var i = 0; i < length; i++) {
      final d = i + 1;
      final sel = d == day;
      final color = _phaseColors[cyclePhaseIndex(d, length)];
      final outer = sel ? r * 0.99 : r * 0.92;
      final inner = sel ? r * 0.62 : r * 0.68;
      final a0 = -math.pi / 2 + i * seg + 0.012;
      final a1 = a0 + seg - 0.024;
      final path = Path()
        ..moveTo(o.dx + math.cos(a0) * inner, o.dy + math.sin(a0) * inner)
        ..lineTo(o.dx + math.cos(a0) * outer, o.dy + math.sin(a0) * outer)
        ..arcTo(Rect.fromCircle(center: o, radius: outer), a0, a1 - a0, false)
        ..lineTo(o.dx + math.cos(a1) * inner, o.dy + math.sin(a1) * inner)
        ..arcTo(Rect.fromCircle(center: o, radius: inner), a1, a0 - a1, false)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = sel ? color : color.withValues(alpha: 0.5),
      );
      if (sel) {
        canvas.drawPath(
          path,
          Paint()
            ..color = ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
    canvas.drawCircle(o, r * 0.58, Paint()..color = surface);
    // "Day 1" marker at the top
    canvas.drawCircle(Offset(o.dx, o.dy - r * 0.985), 4, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_WheelPainter o) =>
      o.day != day || o.length != length || o.surface != surface;
}

class _CurvePainter extends CustomPainter {
  final int day;
  final int length;
  final Color grid;
  final Color ink;
  _CurvePainter(this.day, this.length, this.grid, this.ink);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double x(double d) => (d - 1) / (length - 1) * w;
    double y(double v) => h - 6 - v * (h - 16);
    // phase bands
    var start = 1;
    for (var d = 2; d <= length + 1; d++) {
      if (d > length ||
          cyclePhaseIndex(d, length) != cyclePhaseIndex(start, length)) {
        canvas.drawRect(
          Rect.fromLTRB(
            x(start - 0.5).clamp(0, w),
            0,
            x(d - 0.5).clamp(0, w),
            h,
          ),
          Paint()
            ..color = _phaseColors[cyclePhaseIndex(start, length)].withValues(
              alpha: 0.12,
            ),
        );
        start = d;
      }
    }
    canvas.drawLine(Offset(0, h - 6), Offset(w, h - 6), Paint()..color = grid);
    const widths = [3.4, 3.4, 2.4, 2.4];
    for (var hI = 0; hI < 4; hI++) {
      final path = Path();
      for (var i = 0; i <= 120; i++) {
        final d = 1 + (length - 1) * i / 120;
        final p = Offset(x(d), y(hormoneLevel(hI, d, length)));
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _hormoneColors[hI]
          ..style = PaintingStyle.stroke
          ..strokeWidth = widths[hI]
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    final mx = x(day.toDouble());
    canvas.drawLine(
      Offset(mx, 0),
      Offset(mx, h),
      Paint()
        ..color = ink
        ..strokeWidth = 2,
    );
    for (var hI = 0; hI < 4; hI++) {
      final p = Offset(mx, y(hormoneLevel(hI, day.toDouble(), length)));
      canvas.drawCircle(p, 5.5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 4, Paint()..color = _hormoneColors[hI]);
    }
  }

  @override
  bool shouldRepaint(_CurvePainter o) =>
      o.day != day || o.length != length || o.ink != ink;
}
