import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../ui/widgets.dart';
import 'body_lab.dart';

/// Lessons that show the "how a pregnancy begins" animation (all ages 13+).
const kFertilizationLessons = {'d01-l04', 'd07-l01', 'd08-l01'};

/// Lessons that show the row of real period products.
const kPeriodProductLessons = {'d03-l02', 'd03-l05'};

Offset _tube(double t) {
  // Cubic along the right fallopian tube: uterus corner -> ovary end.
  const p0 = Offset(0.635, 0.305),
      p1 = Offset(0.72, 0.225),
      p2 = Offset(0.82, 0.225),
      p3 = Offset(0.865, 0.335);
  final u = 1 - t;
  return p0 * (u * u * u) +
      p1 * (3 * u * u * t) +
      p2 * (3 * u * t * t) +
      p3 * (t * t * t);
}

/// Step-by-step animated explainer drawn over the uterus diagram:
/// ovulation -> sperm travel -> fertilisation -> implantation.
class FertilizationJourney extends StatefulWidget {
  const FertilizationJourney({super.key});

  @override
  State<FertilizationJourney> createState() => _FertilizationJourneyState();
}

class _FertilizationJourneyState extends State<FertilizationJourney>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _run();
  }

  void _run() {
    if (context.reducedMotion) {
      _c.stop();
      _c.value = 1;
    } else {
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
    final c = context.c;
    return AppCard(
      key: const Key('fert-journey'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('fert.title'), style: context.tx.titleLarge),
          const SizedBox(height: 10),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: 1,
                child: Semantics(
                  image: true,
                  label: context.t('fert.${_step + 1}'),
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, _) => CustomPaint(
                      painter: DiagramPainter(
                        'internal_f',
                        'all',
                        null,
                        context.isDark,
                      ),
                      foregroundPainter: _JourneyPainter(_step, _c.value),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < 4; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    child: Tap(
                      key: Key('fert-step-$i'),
                      onTap: () => setState(() => _step = i),
                      child: Semantics(
                        selected: _step == i,
                        label: '${i + 1}',
                        child: Container(
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _step == i ? c.primary : c.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ExcludeSemantics(
                            child: Text(
                              '${i + 1}',
                              textScaler: TextScaler.noScaling,
                              style: context.tx.titleMedium?.copyWith(
                                color: _step == i ? c.onPrimary : c.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            context.t('fert.${_step + 1}'),
            key: const Key('fert-caption'),
            style: context.tx.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(context.t('fert.note'), style: context.tx.bodySmall),
        ],
      ),
    );
  }
}

class _JourneyPainter extends CustomPainter {
  final int step;
  final double t;
  _JourneyPainter(this.step, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(Offset o) => Offset(o.dx * s, o.dy * s);
    void egg(Offset at, {bool fertilised = false, double scale = 1}) {
      final o = p(at);
      canvas.drawCircle(o, s * 0.03 * scale, Paint()..color = Colors.white);
      canvas.drawCircle(
        o,
        s * 0.024 * scale,
        Paint()..color = const Color(0xFFFFB02E),
      );
      if (fertilised) {
        for (final d in const [
          Offset(-0.008, -0.006),
          Offset(0.008, -0.004),
          Offset(0, 0.009),
        ]) {
          canvas.drawCircle(
            o + d * s,
            s * 0.008 * scale,
            Paint()..color = const Color(0xFFE06A00),
          );
        }
      }
    }

    void sperm(Offset at, double angle) {
      final o = p(at);
      canvas.drawCircle(o, s * 0.011, Paint()..color = const Color(0xFF2F6BFF));
      canvas.drawLine(
        o,
        o - Offset(math.cos(angle), math.sin(angle)) * s * 0.035,
        Paint()
          ..color = const Color(0xFF2F6BFF)
          ..strokeWidth = s * 0.006
          ..strokeCap = StrokeCap.round,
      );
    }

    void ring(Offset at, double v) {
      canvas.drawCircle(
        p(at),
        s * (0.03 + 0.05 * v),
        Paint()
          ..color = Palette.deepMint.withValues(alpha: (1 - v) * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.008,
      );
    }

    const meet = 0.62; // where on the tube egg and sperm meet
    switch (step) {
      case 0: // ovulation: the egg leaves the ovary and enters the tube
        final v = Curves.easeInOut.transform(t);
        egg(Offset.lerp(const Offset(0.85, 0.43), _tube(0.97), v)!);
        ring(const Offset(0.85, 0.43), t);
      case 1: // sperm travel: vagina -> cervix -> uterus -> tube
        egg(_tube(meet));
        const route = [
          Offset(0.5, 0.88),
          Offset(0.5, 0.65),
          Offset(0.5, 0.4),
          Offset(0.6, 0.325),
        ];
        for (var i = 0; i < 6; i++) {
          final v = ((t + i * 0.16) % 1) * (route.length - 1 + meet);
          final seg = v.floor();
          final f = v - seg;
          final wobble = Offset(math.sin((t + i) * 9) * 0.012, 0);
          final at = seg < route.length - 1
              ? Offset.lerp(route[seg], route[seg + 1], f)! + wobble
              : _tube(((v - (route.length - 1))).clamp(0.0, meet));
          sperm(at, -math.pi / 2);
        }
      case 2: // fertilisation in the tube
        egg(_tube(meet), fertilised: t > 0.55, scale: 1.25);
        final v = (t / 0.55).clamp(0.0, 1.0);
        if (t <= 0.55) {
          sperm(Offset.lerp(_tube(meet - 0.3), _tube(meet), v)!, 0);
        }
        if (t > 0.55) ring(_tube(meet), (t - 0.55) / 0.45);
      default: // journey to the uterus and implantation in the lining
        const home = Offset(0.555, 0.39);
        final v = Curves.easeInOut.transform(t);
        final at = v < 0.7
            ? _tube(meet * (1 - v / 0.7))
            : Offset.lerp(_tube(0), home, (v - 0.7) / 0.3)!;
        egg(at, fertilised: true, scale: 1.1 + 0.3 * v);
        if (v > 0.9) ring(home, (v - 0.9) / 0.1);
    }
  }

  @override
  bool shouldRepaint(_JourneyPainter o) => o.step != step || o.t != t;
}

/// Shows where a set of organs sits in the body, on a clothed-neutral outline.
class BodyLocation extends StatelessWidget {
  /// true = inside the pelvis; false = outside, between the legs.
  final bool inside;
  const BodyLocation({super.key, required this.inside});

  @override
  Widget build(BuildContext context) => AppCard(
    key: const Key('body-location'),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Semantics(
          image: true,
          label: context.t('body.where'),
          child: SizedBox(
            width: 84,
            height: 132,
            child: CustomPaint(
              painter: _SilhouettePainter(inside, context.isDark),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t('body.where'), style: context.tx.titleMedium),
              const SizedBox(height: 4),
              Text(
                context.t(inside ? 'body.where.inside' : 'body.where.outside'),
                style: context.tx.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SilhouettePainter extends CustomPainter {
  final bool inside;
  final bool dark;
  _SilhouettePainter(this.inside, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Paint()
      ..color = dark ? const Color(0xFF4A4A8F) : const Color(0xFFD9D2FF);
    // A plain outline from head to knees: no surface detail at all.
    canvas.drawCircle(Offset(w * 0.5, h * 0.09), h * 0.075, body);
    canvas.drawRect(Rect.fromLTRB(w * 0.44, h * 0.15, w * 0.56, h * 0.2), body);
    final torso = Path()
      ..moveTo(w * 0.2, h * 0.21)
      ..quadraticBezierTo(w * 0.5, h * 0.17, w * 0.8, h * 0.21)
      ..lineTo(w * 0.74, h * 0.5)
      ..quadraticBezierTo(w * 0.82, h * 0.6, w * 0.8, h * 0.7)
      ..lineTo(w * 0.76, h * 0.99)
      ..lineTo(w * 0.55, h * 0.99)
      ..lineTo(w * 0.5, h * 0.74)
      ..lineTo(w * 0.45, h * 0.99)
      ..lineTo(w * 0.24, h * 0.99)
      ..lineTo(w * 0.2, h * 0.7)
      ..quadraticBezierTo(w * 0.18, h * 0.6, w * 0.26, h * 0.5)
      ..close();
    canvas.drawPath(torso, body);
    for (final s in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(w * (0.5 + s * 0.31), h * 0.24),
        Offset(w * (0.5 + s * 0.42), h * 0.62),
        Paint()
          ..color = body.color
          ..strokeWidth = w * 0.13
          ..strokeCap = StrokeCap.round,
      );
    }
    final at = Offset(w * 0.5, h * (inside ? 0.63 : 0.73));
    canvas.drawCircle(
      at,
      w * 0.2,
      Paint()..color = Palette.coral.withValues(alpha: 0.28),
    );
    canvas.drawCircle(at, w * 0.11, Paint()..color = Palette.coral);
    canvas.drawCircle(
      at,
      w * 0.2,
      Paint()
        ..color = Palette.coral
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SilhouettePainter o) =>
      o.inside != inside || o.dark != dark;
}
