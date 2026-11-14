import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import 'visual_explainers.dart';
import '../lessons/lesson_visual.dart';

/// Hotspot positions (0-1) for every tappable structure, per diagram.
const kHotspots = <String, Map<String, Offset>>{
  'kid': {
    'brain': Offset(0.5, 0.10),
    'mouth': Offset(0.5, 0.215),
    'chest': Offset(0.5, 0.37),
    'tummy': Offset(0.5, 0.50),
    'hands': Offset(0.19, 0.57),
    'private_parts': Offset(0.5, 0.64),
  },
  'internal_f': {
    'ovary': Offset(0.85, 0.43),
    'fallopian_tube': Offset(0.71, 0.255),
    'uterus': Offset(0.375, 0.43),
    'endometrium': Offset(0.5, 0.39),
    'cervix': Offset(0.5, 0.645),
    'vagina': Offset(0.5, 0.80),
  },
  'internal_m': {
    'bladder': Offset(0.52, 0.21),
    'seminal_vesicle': Offset(0.70, 0.355),
    'prostate': Offset(0.52, 0.42),
    'vas_deferens': Offset(0.845, 0.53),
    'urethra': Offset(0.475, 0.535),
    'penis': Offset(0.335, 0.655),
    'foreskin_glans': Offset(0.215, 0.80),
    'testis': Offset(0.485, 0.80),
    'epididymis': Offset(0.585, 0.80),
    'scrotum': Offset(0.42, 0.905),
  },
  'external_f': {
    'mons_pubis': Offset(0.5, 0.115),
    'outer_labia': Offset(0.285, 0.47),
    'inner_labia': Offset(0.405, 0.60),
    'clitoris': Offset(0.5, 0.315),
    'urethral_opening': Offset(0.5, 0.455),
    'vaginal_opening': Offset(0.5, 0.585),
    'hymen': Offset(0.575, 0.655),
    'perineum': Offset(0.5, 0.765),
    'anus': Offset(0.5, 0.885),
  },
};

const _urinary = {'bladder', 'urethra', 'urethral_opening'};

class BodyLabScreen extends ConsumerStatefulWidget {
  const BodyLabScreen({super.key});

  @override
  ConsumerState<BodyLabScreen> createState() => _BodyLabScreenState();
}

class _BodyLabScreenState extends ConsumerState<BodyLabScreen> {
  String? _diagram;
  String? _selected;
  String _focus = 'all';
  bool _findMode = false;
  List<String> _targets = [];
  int _found = 0;
  int _misses = 0;
  String? _wrong;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('body_lab'),
    );
  }

  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _startFind(List<BodyPart> parts) {
    setState(() {
      _findMode = true;
      _targets = [for (final p in parts) p.id]..shuffle(math.Random());
      _found = 0;
      _misses = 0;
      _selected = null;
      _wrong = null;
      _focus = 'all';
    });
    // The "find this part" banner and the diagram sit at the top of the page.
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _tap(String id) {
    if (!_findMode) {
      setState(() => _selected = id);
      return;
    }
    if (_found >= _targets.length) return;
    setState(() {
      if (id == _targets[_found]) {
        _selected = id;
        _wrong = null;
        _found++;
      } else {
        _wrong = id;
        _misses++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final diagrams = content.diagramsFor(track);
    if (diagrams.isEmpty) return const NotAvailableScreen();
    final diagram = diagrams.contains(_diagram) ? _diagram! : diagrams.first;
    final parts = content.bodyPartsFor(track, diagram);
    final spots = kHotspots[diagram] ?? const {};
    final byId = {for (final p in parts) p.id: p};
    final sel = _selected == null ? null : byId[_selected];
    final c = context.c;
    final hasUrinary = parts.any((p) => _urinary.contains(p.id));
    final finished = _findMode && _found >= _targets.length;
    final target = _findMode && !finished ? byId[_targets[_found]] : null;

    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.body_lab.title'))),
      body: PageBody(
        controller: _scroll,
        children: [
          if (diagrams.length > 1)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final d in diagrams)
                  ChoicePill(
                    key: Key('diagram-$d'),
                    label: context.t('body.diagram.$d'),
                    selected: d == diagram,
                    onTap: () => setState(() {
                      _diagram = d;
                      _selected = null;
                      _findMode = false;
                      _focus = 'all';
                    }),
                  ),
              ],
            ),
          const SizedBox(height: 10),
          if (_findMode)
            InfoBanner(
              key: const Key('body-find-banner'),
              icon: finished
                  ? Icons.emoji_events_rounded
                  : Icons.touch_app_rounded,
              color: finished ? c.success : c.primary,
              title: finished
                  ? context.t('body.find.done', {
                      'n': _targets.length,
                      'miss': _misses,
                    })
                  : context.t('body.find.prompt', {
                      'name': context.lx(target!.name),
                    }),
              text: finished
                  ? context.t('body.find.doneBody')
                  : (_wrong != null && byId[_wrong] != null
                        ? context.t('body.find.wrong', {
                            'name': context.lx(byId[_wrong]!.name),
                          })
                        : context.t('body.find.count', {
                            'n': _found + 1,
                            'total': _targets.length,
                          })),
            )
          else
            Text(
              context.t('body.hint'),
              style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
            ),
          const SizedBox(height: 12),
          TiltCard(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDark
                      ? [const Color(0xFF23234A), const Color(0xFF191932)]
                      : [Colors.white, Palette.lavender],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: c.outline),
                boxShadow: [
                  BoxShadow(
                    color: Palette.purple.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final s = box.maxWidth;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Semantics(
                            image: true,
                            label: context.t('body.alt.$diagram'),
                            child: CustomPaint(
                              painter: DiagramPainter(
                                diagram,
                                _focus,
                                _selected,
                                context.isDark,
                              ),
                            ),
                          ),
                        ),
                        for (final p in parts)
                          if (spots[p.id] != null)
                            Positioned(
                              left: spots[p.id]!.dx * s - 22,
                              top: spots[p.id]!.dy * s - 22,
                              child: _Hotspot(
                                key: Key('spot-${p.id}'),
                                label: _findMode
                                    ? context.t('body.spot')
                                    : context.lx(p.name),
                                selected: _selected == p.id,
                                wrong: _wrong == p.id,
                                dim:
                                    _focus != 'all' &&
                                    (_focus == 'urinary') !=
                                        _urinary.contains(p.id),
                                onTap: () => _tap(p.id),
                              ),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('body.caption'),
            style: context.tx.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (diagram != 'kid' && !_findMode) ...[
            BodyLocation(inside: diagram != 'external_f'),
            const SizedBox(height: 12),
          ],
          if (hasUrinary && !_findMode) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in const ['all', 'repro', 'urinary'])
                  ChoicePill(
                    label: context.t('body.focus.$f'),
                    selected: _focus == f,
                    onTap: () => setState(() => _focus = f),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (!_findMode && sel != null)
            FadeSlide(
              key: ValueKey(sel.id),
              child: AppCard(
                key: const Key('body-part-card'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.lx(sel.name), style: context.tx.headlineSmall),
                    const SizedBox(height: 8),
                    Text(context.lx(sel.what), style: context.tx.bodyLarge),
                    const SizedBox(height: 12),
                    InfoBanner(
                      icon: Icons.lightbulb_rounded,
                      color: c.warning,
                      text: context.lx(sel.more),
                    ),
                  ],
                ),
              ),
            ),
          if (!_findMode) ...[
            const SizedBox(height: 14),
            Text(context.t('body.parts'), style: context.tx.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in parts)
                  ChoicePill(
                    label: context.lx(p.name),
                    selected: _selected == p.id,
                    onTap: () => setState(() => _selected = p.id),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          if (_findMode)
            SoftButton(
              label: context.t('body.find.exit'),
              icon: Icons.explore_rounded,
              onPressed: () => setState(() {
                _findMode = false;
                _wrong = null;
              }),
            )
          else
            PrimaryButton(
              key: const Key('body-find'),
              label: context.t('body.find.start'),
              icon: Icons.ads_click_rounded,
              onPressed: () => _startFind(parts),
            ),
          // The photo comes after the diagram so the lab itself fills the
          // first screen.
          const SizedBox(height: 14),
          const ScreenPicture(lab: 'body_lab'),
          const SizedBox(height: 14),
          const ReviewNote(),
        ],
      ),
    );
  }
}

class _Hotspot extends StatefulWidget {
  final String label;
  final bool selected;
  final bool wrong;
  final bool dim;
  final VoidCallback onTap;
  const _Hotspot({
    super.key,
    required this.label,
    required this.selected,
    required this.wrong,
    required this.dim,
    required this.onTap,
  });

  @override
  State<_Hotspot> createState() => _HotspotState();
}

class _HotspotState extends State<_Hotspot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reducedMotion) {
      _c.stop();
      _c.value = 0;
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
    final c = context.c;
    final color = widget.wrong
        ? c.danger
        : (widget.selected ? c.success : c.primary);
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Opacity(
          opacity: widget.dim ? 0.3 : 1,
          child: SizedBox(
            width: 44,
            height: 44,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) => CustomPaint(
                painter: _SpotPainter(
                  _c.value,
                  color,
                  widget.selected,
                  widget.wrong,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotPainter extends CustomPainter {
  final double t;
  final Color color;
  final bool selected;
  final bool wrong;
  _SpotPainter(this.t, this.color, this.selected, this.wrong);

  @override
  void paint(Canvas canvas, Size size) {
    final o = size.center(Offset.zero);
    if (!selected && !wrong) {
      canvas.drawCircle(
        o,
        9 + t * 12,
        Paint()..color = color.withValues(alpha: (1 - t) * 0.35),
      );
    }
    canvas.drawCircle(o, 11, Paint()..color = Colors.white);
    canvas.drawCircle(o, selected || wrong ? 9 : 7, Paint()..color = color);
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (selected) {
      canvas.drawPath(
        Path()
          ..moveTo(o.dx - 4, o.dy)
          ..lineTo(o.dx - 1, o.dy + 3)
          ..lineTo(o.dx + 4.5, o.dy - 3),
        p,
      );
    } else if (wrong) {
      canvas.drawLine(o + const Offset(-3, -3), o + const Offset(3, 3), p);
      canvas.drawLine(o + const Offset(3, -3), o + const Offset(-3, 3), p);
    }
  }

  @override
  bool shouldRepaint(_SpotPainter o) =>
      o.t != t ||
      o.color != color ||
      o.selected != selected ||
      o.wrong != wrong;
}

/// Original, simplified teaching diagrams drawn in code. Flat, schematic and
/// deliberately non-realistic: they exist to label structures, nothing else.
class DiagramPainter extends CustomPainter {
  final String diagram;
  final String focus; // all | repro | urinary
  final String? selected;
  final bool dark;
  DiagramPainter(this.diagram, this.focus, this.selected, this.dark);

  static const _rose = Color(0xFFFF9AA8);
  static const _roseDeep = Color(0xFFE2556A);
  static const _roseSoft = Color(0xFFFFD0D6);
  static const _peach = Color(0xFFFFC2B8);
  static const _skin = Color(0xFFFFE3D8);
  static const _blueSoft = Color(0xFFB7D7FF);
  static const _blueDeep = Color(0xFF3F84E0);
  static const _violet = Color(0xFF765BFF);
  static const _violetSoft = Color(0xFFCDBFFF);
  static const _sun = Color(0xFFFFD27A);

  late double s;

  double _a(String part) {
    if (focus == 'all') return 1;
    final uri = _urinary.contains(part);
    return (focus == 'urinary') == uri ? 1 : 0.22;
  }

  Paint _fill(Color c, String part) =>
      Paint()..color = c.withValues(alpha: _a(part));
  Paint _line(Color c, String part, double w) => Paint()
    ..color = c.withValues(alpha: _a(part))
    ..style = PaintingStyle.stroke
    ..strokeWidth = w * s
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Rect _oval(double cx, double cy, double w, double h) => Rect.fromCenter(
    center: Offset(cx * s, cy * s),
    width: w * s,
    height: h * s,
  );
  Offset _p(double x, double y) => Offset(x * s, y * s);

  void _glow(Canvas canvas, String part) {
    if (selected != part) return;
    final o = kHotspots[diagram]?[part];
    if (o == null) return;
    canvas.drawCircle(
      _p(o.dx, o.dy),
      s * 0.085,
      Paint()
        ..color = Palette.deepMint.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    s = size.width;
    // faint dotted grid for depth
    final dot = Paint()
      ..color = (dark ? Colors.white : Palette.purple).withValues(alpha: 0.07);
    for (var x = 0.08; x < 1; x += 0.105) {
      for (var y = 0.08; y < 1; y += 0.105) {
        canvas.drawCircle(_p(x, y), s * 0.004, dot);
      }
    }
    for (final part in (kHotspots[diagram] ?? const <String, Offset>{}).keys) {
      _glow(canvas, part);
    }
    switch (diagram) {
      case 'kid':
        _kid(canvas);
      case 'internal_f':
        _internalF(canvas);
      case 'internal_m':
        _internalM(canvas);
      case 'external_f':
        _externalF(canvas);
    }
  }

  void _kid(Canvas canvas) {
    const skin = Color(0xFFEDB98F);
    const hair = Color(0xFF3B2A4A);
    final limb = Paint()
      ..color = skin
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // legs + shoes
    for (final x in [0.44, 0.56]) {
      canvas.drawLine(_p(x, 0.70), _p(x, 0.89), limb..strokeWidth = s * 0.06);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          _oval(x + (x < 0.5 ? -0.012 : 0.012), 0.915, 0.105, 0.05),
          Radius.circular(s * 0.025),
        ),
        Paint()..color = _violet,
      );
    }
    // arms
    for (final sign in [-1.0, 1.0]) {
      final sx = 0.5 + sign * 0.135;
      final hx = 0.5 + sign * 0.305;
      canvas.drawLine(
        _p(sx, 0.34),
        _p(hx, 0.555),
        limb..strokeWidth = s * 0.05,
      );
      canvas.drawCircle(_p(hx, 0.572), s * 0.033, Paint()..color = skin);
      // sleeve
      canvas.drawLine(
        _p(sx, 0.335),
        _p(0.5 + sign * 0.2, 0.42),
        Paint()
          ..color = const Color(0xFF3CC8A0)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = s * 0.075,
      );
    }
    // shorts (the "private zone" that underwear covers)
    final shorts = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0.365 * s, 0.565 * s, 0.635 * s, 0.725 * s),
          Radius.circular(s * 0.035),
        ),
      );
    canvas.drawPath(shorts, Paint()..color = Palette.coral);
    canvas.drawLine(
      _p(0.5, 0.66),
      _p(0.5, 0.725),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = s * 0.008,
    );
    if (selected == 'private_parts') {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(0.345 * s, 0.545 * s, 0.655 * s, 0.745 * s),
          Radius.circular(s * 0.045),
        ),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.012,
      );
    }
    // t-shirt
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(0.365 * s, 0.29 * s, 0.635 * s, 0.59 * s),
        Radius.circular(s * 0.055),
      ),
      Paint()..color = const Color(0xFF3CC8A0),
    );
    canvas.drawCircle(
      _p(0.5, 0.42),
      s * 0.035,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0.485 * s, 0.417 * s)
        ..quadraticBezierTo(0.5 * s, 0.405 * s, 0.5 * s, 0.422 * s)
        ..quadraticBezierTo(0.5 * s, 0.405 * s, 0.515 * s, 0.417 * s)
        ..quadraticBezierTo(0.515 * s, 0.432 * s, 0.5 * s, 0.442 * s)
        ..quadraticBezierTo(0.485 * s, 0.432 * s, 0.485 * s, 0.417 * s),
      Paint()..color = Palette.coral,
    );
    // neck + head
    canvas.drawRect(
      Rect.fromLTRB(0.47 * s, 0.25 * s, 0.53 * s, 0.31 * s),
      Paint()..color = skin,
    );
    canvas.drawCircle(_p(0.5, 0.165), s * 0.115, Paint()..color = hair);
    canvas.drawCircle(_p(0.5, 0.18), s * 0.1, Paint()..color = skin);
    canvas.drawArc(
      _oval(0.5, 0.15, 0.2, 0.17),
      math.pi,
      math.pi,
      true,
      Paint()..color = hair,
    );
    for (final x in [0.462, 0.538]) {
      canvas.drawCircle(_p(x, 0.185), s * 0.012, Paint()..color = Palette.dark);
    }
    canvas.drawArc(
      _oval(0.5, 0.21, 0.07, 0.05),
      0.2,
      math.pi - 0.4,
      false,
      Paint()
        ..color = Palette.dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.009
        ..strokeCap = StrokeCap.round,
    );
    for (final x in [0.425, 0.575]) {
      canvas.drawCircle(
        _p(x, 0.215),
        s * 0.017,
        Paint()..color = Palette.coral.withValues(alpha: 0.45),
      );
    }
  }

  void _internalF(Canvas canvas) {
    // vagina (canal)
    final canal = RRect.fromRectAndRadius(
      Rect.fromLTRB(0.452 * s, 0.63 * s, 0.548 * s, 0.94 * s),
      Radius.circular(s * 0.045),
    );
    canvas.drawRRect(canal, _fill(_roseSoft, 'vagina'));
    canvas.drawRRect(canal, _line(_rose, 'vagina', 0.008));
    // tubes + ovaries, mirrored
    for (final sign in [-1.0, 1.0]) {
      double x(double v) => 0.5 + sign * (v - 0.5);
      final tube = Path()
        ..moveTo(x(0.635) * s, 0.305 * s)
        ..cubicTo(
          x(0.72) * s,
          0.225 * s,
          x(0.82) * s,
          0.225 * s,
          x(0.865) * s,
          0.335 * s,
        );
      canvas.drawPath(tube, _line(_roseDeep, 'fallopian_tube', 0.05));
      canvas.drawPath(tube, _line(_rose, 'fallopian_tube', 0.034));
      for (final a in [-0.5, 0.0, 0.5]) {
        canvas.drawLine(
          _p(x(0.865), 0.335),
          _p(
            x(0.865) + sign * math.sin(a) * 0.035,
            0.335 + math.cos(a) * 0.045,
          ),
          _line(_rose, 'fallopian_tube', 0.014),
        );
      }
      canvas.drawLine(
        _p(x(0.66), 0.40),
        _p(x(0.79), 0.43),
        _line(_roseSoft, 'ovary', 0.008),
      );
      canvas.drawOval(_oval(x(0.85), 0.43, 0.135, 0.095), _fill(_sun, 'ovary'));
      canvas.drawOval(
        _oval(x(0.85), 0.43, 0.135, 0.095),
        _line(const Color(0xFFE39A00), 'ovary', 0.006),
      );
      for (final d in const [
        Offset(-0.025, -0.01),
        Offset(0.02, 0.012),
        Offset(0.0, -0.02),
      ]) {
        canvas.drawCircle(
          _p(x(0.85) + d.dx, 0.43 + d.dy),
          s * 0.011,
          _fill(Colors.white, 'ovary'),
        );
      }
    }
    // uterus (muscular wall)
    final uterus = Path()
      ..moveTo(0.335 * s, 0.315 * s)
      ..cubicTo(0.40 * s, 0.235 * s, 0.60 * s, 0.235 * s, 0.665 * s, 0.315 * s)
      ..cubicTo(0.665 * s, 0.46 * s, 0.575 * s, 0.55 * s, 0.56 * s, 0.655 * s)
      ..lineTo(0.44 * s, 0.655 * s)
      ..cubicTo(0.425 * s, 0.55 * s, 0.335 * s, 0.46 * s, 0.335 * s, 0.315 * s)
      ..close();
    canvas.drawPath(uterus, _fill(_rose, 'uterus'));
    canvas.drawPath(uterus, _line(_roseDeep, 'uterus', 0.008));
    // endometrium (lining + cavity)
    final lining = Path()
      ..moveTo(0.405 * s, 0.335 * s)
      ..quadraticBezierTo(0.5 * s, 0.30 * s, 0.595 * s, 0.335 * s)
      ..quadraticBezierTo(0.545 * s, 0.47 * s, 0.515 * s, 0.615 * s)
      ..lineTo(0.485 * s, 0.615 * s)
      ..quadraticBezierTo(0.455 * s, 0.47 * s, 0.405 * s, 0.335 * s)
      ..close();
    canvas.drawPath(lining, _fill(_roseDeep, 'endometrium'));
    final cavity = Path()
      ..moveTo(0.445 * s, 0.355 * s)
      ..quadraticBezierTo(0.5 * s, 0.34 * s, 0.555 * s, 0.355 * s)
      ..quadraticBezierTo(0.52 * s, 0.45 * s, 0.503 * s, 0.57 * s)
      ..lineTo(0.497 * s, 0.57 * s)
      ..quadraticBezierTo(0.48 * s, 0.45 * s, 0.445 * s, 0.355 * s)
      ..close();
    canvas.drawPath(cavity, _fill(const Color(0xFF8E2740), 'endometrium'));
    // cervix
    canvas.drawOval(
      _oval(0.5, 0.648, 0.135, 0.06),
      _fill(const Color(0xFFFF7D92), 'cervix'),
    );
    canvas.drawOval(
      _oval(0.5, 0.648, 0.135, 0.06),
      _line(_roseDeep, 'cervix', 0.007),
    );
    canvas.drawOval(
      _oval(0.5, 0.65, 0.03, 0.014),
      _fill(const Color(0xFF8E2740), 'cervix'),
    );
  }

  void _internalM(Canvas canvas) {
    // scrotum, testis, epididymis
    canvas.drawOval(_oval(0.5, 0.81, 0.27, 0.27), _fill(_peach, 'scrotum'));
    canvas.drawOval(
      _oval(0.5, 0.81, 0.27, 0.27),
      _line(const Color(0xFFE89A8A), 'scrotum', 0.006),
    );
    canvas.drawOval(_oval(0.485, 0.805, 0.125, 0.17), _fill(_rose, 'testis'));
    canvas.drawOval(
      _oval(0.485, 0.805, 0.125, 0.17),
      _line(_roseDeep, 'testis', 0.006),
    );
    final epi = Path()
      ..moveTo(0.50 * s, 0.712 * s)
      ..cubicTo(0.60 * s, 0.71 * s, 0.605 * s, 0.87 * s, 0.525 * s, 0.895 * s);
    canvas.drawPath(epi, _line(_violet, 'epididymis', 0.026));
    // vas deferens: from the epididymis up to the seminal vesicle
    final vas = Path()
      ..moveTo(0.555 * s, 0.725 * s)
      ..cubicTo(0.78 * s, 0.70 * s, 0.93 * s, 0.50 * s, 0.80 * s, 0.375 * s)
      ..quadraticBezierTo(0.77 * s, 0.35 * s, 0.735 * s, 0.355 * s);
    canvas.drawPath(vas, _line(_violet, 'vas_deferens', 0.015));
    // bladder
    canvas.drawOval(
      _oval(0.52, 0.225, 0.29, 0.225),
      _fill(_blueSoft, 'bladder'),
    );
    canvas.drawOval(
      _oval(0.52, 0.225, 0.29, 0.225),
      _line(_blueDeep, 'bladder', 0.008),
    );
    // seminal vesicle
    canvas.save();
    canvas.translate(0.69 * s, 0.36 * s);
    canvas.rotate(-0.5);
    final sv = Rect.fromCenter(
      center: Offset.zero,
      width: 0.15 * s,
      height: 0.065 * s,
    );
    canvas.drawOval(sv, _fill(_violetSoft, 'seminal_vesicle'));
    canvas.drawOval(sv, _line(_violet, 'seminal_vesicle', 0.006));
    canvas.restore();
    // prostate
    canvas.drawOval(_oval(0.52, 0.42, 0.14, 0.105), _fill(_sun, 'prostate'));
    canvas.drawOval(
      _oval(0.52, 0.42, 0.14, 0.105),
      _line(const Color(0xFFE39A00), 'prostate', 0.006),
    );
    // penis (schematic side view) + glans
    canvas.drawLine(
      _p(0.445, 0.545),
      _p(0.245, 0.765),
      _line(_peach, 'penis', 0.105),
    );
    canvas.drawCircle(
      _p(0.218, 0.797),
      s * 0.056,
      _fill(_rose, 'foreskin_glans'),
    );
    canvas.drawArc(
      _oval(0.245, 0.767, 0.12, 0.12),
      2.2,
      2.4,
      false,
      _line(const Color(0xFFE89A8A), 'foreskin_glans', 0.008),
    );
    // urethra: bladder -> prostate -> penis tip
    final urethra = Path()
      ..moveTo(0.52 * s, 0.335 * s)
      ..lineTo(0.52 * s, 0.475 * s)
      ..cubicTo(0.52 * s, 0.53 * s, 0.47 * s, 0.525 * s, 0.44 * s, 0.555 * s)
      ..lineTo(0.215 * s, 0.80 * s);
    canvas.drawPath(urethra, _line(_blueDeep, 'urethra', 0.014));
  }

  void _externalF(Canvas canvas) {
    // surrounding skin
    canvas.drawOval(_oval(0.5, 0.52, 0.66, 0.9), _fill(_skin, 'perineum'));
    // mons pubis
    canvas.drawOval(
      _oval(0.5, 0.15, 0.44, 0.2),
      _fill(const Color(0xFFFFD3C6), 'mons_pubis'),
    );
    // outer labia
    canvas.drawOval(_oval(0.5, 0.5, 0.5, 0.62), _fill(_peach, 'outer_labia'));
    canvas.drawOval(
      _oval(0.5, 0.5, 0.5, 0.62),
      _line(const Color(0xFFE89A8A), 'outer_labia', 0.006),
    );
    // inner labia
    canvas.drawOval(_oval(0.5, 0.52, 0.26, 0.46), _fill(_rose, 'inner_labia'));
    canvas.drawOval(
      _oval(0.5, 0.52, 0.26, 0.46),
      _line(_roseDeep, 'inner_labia', 0.006),
    );
    // vestibule
    canvas.drawOval(
      _oval(0.5, 0.535, 0.135, 0.34),
      _fill(_roseSoft, 'inner_labia'),
    );
    // clitoral hood + glans
    final hood = Path()
      ..moveTo(0.445 * s, 0.355 * s)
      ..quadraticBezierTo(0.5 * s, 0.235 * s, 0.555 * s, 0.355 * s)
      ..quadraticBezierTo(0.5 * s, 0.325 * s, 0.445 * s, 0.355 * s)
      ..close();
    canvas.drawPath(hood, _fill(const Color(0xFFFF7D92), 'clitoris'));
    canvas.drawCircle(_p(0.5, 0.345), s * 0.021, _fill(_roseDeep, 'clitoris'));
    // urethral opening
    canvas.drawCircle(
      _p(0.5, 0.455),
      s * 0.013,
      _fill(_blueDeep, 'urethral_opening'),
    );
    // vaginal opening + hymen (a thin rim of tissue)
    canvas.drawOval(
      _oval(0.5, 0.585, 0.075, 0.105),
      _fill(const Color(0xFF8E2740), 'vaginal_opening'),
    );
    canvas.drawArc(
      _oval(0.5, 0.588, 0.105, 0.135),
      0.15,
      math.pi - 0.3,
      false,
      _line(Colors.white, 'hymen', 0.011),
    );
    // anus
    canvas.drawCircle(
      _p(0.5, 0.885),
      s * 0.02,
      _fill(const Color(0xFFB4705E), 'anus'),
    );
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        _p(0.5 + math.cos(a) * 0.027, 0.885 + math.sin(a) * 0.027),
        _p(0.5 + math.cos(a) * 0.04, 0.885 + math.sin(a) * 0.04),
        _line(const Color(0xFFB4705E), 'anus', 0.005),
      );
    }
  }

  @override
  bool shouldRepaint(DiagramPainter o) =>
      o.diagram != diagram ||
      o.focus != focus ||
      o.selected != selected ||
      o.dark != dark;
}
