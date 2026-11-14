import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/models.dart';

/// Original illustrations drawn in code: relatable people in everyday
/// situations, and real objects (period products, contraceptives).
/// Everyone is fully clothed; nothing here is anatomical.

// ───────────────────────── People ─────────────────────────

const _skins = [
  Color(0xFFF2C9A1),
  Color(0xFFE0A878),
  Color(0xFFC68656),
  Color(0xFF9A6240),
];
const _hairs = [
  Color(0xFF2B1D1A),
  Color(0xFF3B2A4A),
  Color(0xFF4A2F22),
  Color(0xFF1F1F2E),
];
const _tops = [
  Color(0xFF765BFF),
  Color(0xFFFF677B),
  Color(0xFF1FA67A),
  Color(0xFF3D8BFF),
  Color(0xFFFFB02E),
  Color(0xFFEF5DA8),
  Color(0xFF00A3B4),
];
const _bottoms = [
  Color(0xFF2A2A4A),
  Color(0xFF3B4A6B),
  Color(0xFF5B4A3A),
  Color(0xFF4A3B6B),
];

/// How one illustrated person looks.
class Who {
  final Color skin;
  final Color hair;
  final Color top;
  final Color bottom;

  /// 0 short · 1 long · 2 bun · 3 ponytail · 4 headscarf · 5 curly
  final int hairStyle;

  /// 0 smile · 1 neutral · 2 worried · 3 talking
  final int mood;

  /// 0 arms down · 1 palm raised · 2 holding a phone · 3 hand held out
  final int pose;
  final bool glasses;
  final bool kid;
  final bool coat;
  const Who({
    required this.skin,
    required this.hair,
    required this.top,
    required this.bottom,
    this.hairStyle = 0,
    this.mood = 0,
    this.pose = 0,
    this.glasses = false,
    this.kid = false,
    this.coat = false,
  });

  /// A varied but repeatable person for a given seed.
  factory Who.seeded(
    math.Random r, {
    int mood = 0,
    int pose = 0,
    bool kid = false,
    bool coat = false,
  }) => Who(
    skin: _skins[r.nextInt(_skins.length)],
    hair: _hairs[r.nextInt(_hairs.length)],
    top: _tops[r.nextInt(_tops.length)],
    bottom: _bottoms[r.nextInt(_bottoms.length)],
    hairStyle: r.nextInt(6),
    glasses: r.nextInt(5) == 0,
    mood: mood,
    pose: pose,
    kid: kid,
    coat: coat,
  );
}

/// Draws a standing person. [feet] is the point between the feet, [h] the
/// full height. [flip] makes them face left.
void drawPerson(
  Canvas c,
  Offset feet,
  double h,
  Who w, {
  bool flip = false,
  double alpha = 1,
}) {
  final d = flip ? -1.0 : 1.0;
  Color a(Color col) => col.withValues(alpha: alpha);
  final r = h * (w.kid ? 0.135 : 0.1);
  final top = feet.dy - h;
  final head = Offset(feet.dx, top + r);
  final ys = top + 2 * r + h * 0.025; // shoulders
  final yh = top + h * (w.kid ? 0.62 : 0.58); // hips
  final bw = h * (w.kid ? 0.17 : 0.15); // half body width
  final skin = Paint()..color = a(w.skin);
  final hair = Paint()..color = a(w.hair);
  final scarf = Paint()..color = a(Color.lerp(w.top, Colors.white, 0.35)!);

  // legs + shoes
  for (final s in [-1.0, 1.0]) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          feet.dx + s * bw * 0.52 - h * 0.052,
          yh - h * 0.03,
          feet.dx + s * bw * 0.52 + h * 0.052,
          feet.dy - h * 0.025,
        ),
        Radius.circular(h * 0.04),
      ),
      Paint()..color = a(w.bottom),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          feet.dx + s * bw * 0.52 - h * 0.06 + d * h * 0.012,
          feet.dy - h * 0.045,
          feet.dx + s * bw * 0.52 + h * 0.06 + d * h * 0.012,
          feet.dy,
        ),
        Radius.circular(h * 0.022),
      ),
      Paint()..color = a(const Color(0xFF16162C)),
    );
  }

  // hair behind the head
  if (w.hairStyle == 1) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          head.dx - r * 1.12,
          head.dy - r * 0.2,
          head.dx + r * 1.12,
          ys + h * 0.07,
        ),
        Radius.circular(r * 0.6),
      ),
      hair,
    );
  } else if (w.hairStyle == 3) {
    c.drawOval(
      Rect.fromCenter(
        center: Offset(head.dx - d * r * 1.15, head.dy + r * 0.55),
        width: r * 0.6,
        height: r * 1.5,
      ),
      hair,
    );
  } else if (w.hairStyle == 4) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          head.dx - r * 1.25,
          head.dy - r * 0.4,
          head.dx + r * 1.25,
          ys + h * 0.09,
        ),
        Radius.circular(r * 0.9),
      ),
      scarf,
    );
  }

  // arms (the far arm first)
  void arm(double side, Offset hand, {bool palm = false}) {
    final sh = Offset(feet.dx + side * bw * 1.02, ys + h * 0.04);
    final mid = Offset.lerp(sh, hand, 0.5)!;
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = h * 0.07;
    c.drawLine(sh, mid, p..color = a(w.coat ? Colors.white : w.top));
    c.drawLine(mid, hand, p..color = a(w.skin));
    c.drawCircle(hand, h * (palm ? 0.052 : 0.038), skin);
  }

  final rest = yh - h * 0.02;
  arm(-d, Offset(feet.dx - d * bw * 1.3, rest));
  // torso
  final torso = RRect.fromRectAndRadius(
    Rect.fromLTRB(feet.dx - bw, ys, feet.dx + bw, yh + h * 0.02),
    Radius.circular(h * 0.055),
  );
  c.drawRRect(torso, Paint()..color = a(w.top));
  if (w.coat) {
    c.drawRRect(torso, Paint()..color = a(Colors.white));
    c.drawPath(
      Path()
        ..moveTo(feet.dx - bw * 0.35, ys)
        ..lineTo(feet.dx, ys + h * 0.12)
        ..lineTo(feet.dx + bw * 0.35, ys)
        ..close(),
      Paint()..color = a(w.top),
    );
    // stethoscope
    c.drawArc(
      Rect.fromCenter(
        center: Offset(feet.dx, ys + h * 0.06),
        width: bw * 1.3,
        height: h * 0.2,
      ),
      0.1,
      math.pi - 0.2,
      false,
      Paint()
        ..color = a(const Color(0xFF3B4A6B))
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.014,
    );
    c.drawCircle(
      Offset(feet.dx + bw * 0.5, ys + h * 0.17),
      h * 0.022,
      Paint()..color = a(const Color(0xFF3B4A6B)),
    );
  }
  // neck
  c.drawRect(
    Rect.fromLTRB(
      head.dx - r * 0.32,
      head.dy + r * 0.7,
      head.dx + r * 0.32,
      ys + h * 0.012,
    ),
    skin,
  );
  // near arm by pose
  switch (w.pose) {
    case 1:
      arm(d, Offset(feet.dx + d * bw * 2.25, ys - h * 0.015), palm: true);
    case 2:
      final hand = Offset(feet.dx + d * bw * 1.55, ys + h * 0.15);
      arm(d, hand);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: hand + Offset(d * h * 0.02, -h * 0.045),
            width: h * 0.075,
            height: h * 0.13,
          ),
          Radius.circular(h * 0.015),
        ),
        Paint()..color = a(const Color(0xFF16162C)),
      );
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: hand + Offset(d * h * 0.02, -h * 0.048),
            width: h * 0.058,
            height: h * 0.1,
          ),
          Radius.circular(h * 0.008),
        ),
        Paint()..color = a(const Color(0xFF8FC2FF)),
      );
    case 3:
      arm(d, Offset(feet.dx + d * bw * 2.0, yh - h * 0.09));
    default:
      arm(d, Offset(feet.dx + d * bw * 1.3, rest));
  }

  // head
  c.drawCircle(head, r, skin);
  // hair on top
  final cap = Rect.fromCircle(center: head, radius: r * 1.06);
  if (w.hairStyle == 4) {
    c.drawArc(
      Rect.fromCircle(center: head, radius: r * 1.14),
      math.pi * 0.95,
      math.pi * 1.1,
      true,
      scarf,
    );
  } else {
    c.drawArc(cap, math.pi * 0.98, math.pi * 1.04, true, hair);
    if (w.hairStyle == 2) {
      c.drawCircle(Offset(head.dx, head.dy - r * 1.2), r * 0.42, hair);
    }
    if (w.hairStyle == 5) {
      for (var i = -2; i <= 2; i++) {
        c.drawCircle(
          Offset(
            head.dx + i * r * 0.42,
            head.dy - r * (0.92 - (i.abs() * 0.12)),
          ),
          r * 0.3,
          hair,
        );
      }
    }
    if (w.hairStyle == 1) {
      c.drawArc(cap, math.pi * 0.86, math.pi * 1.28, true, hair);
    }
  }
  // face
  final ink = Paint()..color = a(const Color(0xFF16162C));
  final line = Paint()
    ..color = a(const Color(0xFF16162C))
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.11
    ..strokeCap = StrokeCap.round;
  final look = d * r * 0.1;
  for (final s in [-1.0, 1.0]) {
    final e = Offset(head.dx + s * r * 0.36 + look, head.dy + r * 0.08);
    c.drawCircle(e, r * 0.095, ink);
    c.drawCircle(
      Offset(head.dx + s * r * 0.58 + look, head.dy + r * 0.42),
      r * 0.15,
      Paint()
        ..color = a(const Color(0xFFFF677B)).withValues(alpha: 0.28 * alpha),
    );
    if (w.glasses) c.drawCircle(e, r * 0.24, line);
    if (w.mood == 2) {
      c.drawLine(
        e + Offset(-s * r * 0.2, -r * 0.3),
        e + Offset(s * r * 0.12, -r * 0.22),
        line,
      );
    }
  }
  if (w.glasses) {
    c.drawLine(
      Offset(head.dx - r * 0.12 + look, head.dy + r * 0.08),
      Offset(head.dx + r * 0.12 + look, head.dy + r * 0.08),
      line,
    );
  }
  final m = Offset(head.dx + look, head.dy + r * 0.5);
  switch (w.mood) {
    case 1:
      c.drawLine(m + Offset(-r * 0.16, 0), m + Offset(r * 0.16, 0), line);
    case 2:
      c.drawArc(
        Rect.fromCenter(
          center: m + Offset(0, r * 0.12),
          width: r * 0.42,
          height: r * 0.3,
        ),
        math.pi + 0.3,
        math.pi - 0.6,
        false,
        line,
      );
    case 3:
      c.drawOval(
        Rect.fromCenter(center: m, width: r * 0.26, height: r * 0.3),
        ink,
      );
    default:
      c.drawArc(
        Rect.fromCenter(
          center: m - Offset(0, r * 0.1),
          width: r * 0.5,
          height: r * 0.36,
        ),
        0.3,
        math.pi - 0.6,
        false,
        line,
      );
  }
}

// ───────────────────────── Scenes ─────────────────────────

/// Picks the scene that fits a lesson: by topic, age track and lesson number,
/// so neighbouring lessons do not look the same.
String sceneFor(Lesson l) =>
    sceneForTopic(l.domain, l.tracks, int.tryParse(l.id.split('-l').last) ?? 1);

/// The scene for any item of [domain] shown to [tracks]; [n] varies the pick.
String sceneForTopic(String domain, List<Track> tracks, int n) {
  if (tracks.contains(Track.a)) {
    return const {
          'd01': 'class',
          'd05': 'stop',
          'd06': 'circle',
          'd11': 'circle',
          'd13': 'family',
          'd14': 'family',
          'd17': 'family',
          'd18': 'stop',
        }[domain] ??
        'family';
  }
  final options =
      const {
        'd01': ['class', 'doctor'],
        'd02': ['grow', 'mirror'],
        'd03': ['period', 'friends'],
        'd04': ['think', 'friends'],
        'd05': ['stop', 'friends'],
        'd06': ['friends', 'couple'],
        'd07': ['doctor', 'couple'],
        'd08': ['doctor', 'couple'],
        'd09': ['doctor', 'think'],
        'd10': ['doctor', 'mirror'],
        'd11': ['circle', 'friends'],
        'd12': ['media', 'phone'],
        'd13': ['phone', 'family'],
        'd14': ['family', 'stop'],
        'd15': ['think', 'class'],
        'd16': ['law', 'class'],
        'd17': ['mirror', 'circle'],
        'd18': ['friends', 'family'],
      }[domain] ??
      const ['friends'];
  final pick = options[(n.abs() + options.length - 1) % options.length];
  // Couples are shown only where every viewer is 16 or older.
  final adultish = tracks.every((t) => t.index >= Track.d.index);
  return pick == 'couple' && !adultish ? options.first : pick;
}

/// An illustrated scene with people. Decorative: described by [semanticLabel].
///
/// Scenes move gently, like a looping GIF: people breathe, speech bubbles
/// show typing dots, hearts pulse. Motion stops when the learner (or the
/// phone) asks for reduced motion, and when [animate] is false.
class SceneArt extends StatefulWidget {
  final String kind;
  final int seed;
  final bool kids;
  final double height;
  final Color? tint;
  final bool animate;
  const SceneArt({
    super.key,
    required this.kind,
    this.seed = 1,
    this.kids = false,
    this.height = 150,
    this.tint,
    this.animate = true,
  });

  /// A scene for any FAQ, myth card or quiz question of [domain].
  factory SceneArt.forTopic(
    String domain,
    List<Track> tracks, {
    int seed = 1,
    double height = 120,
    bool animate = true,
  }) => SceneArt(
    kind: sceneForTopic(domain, tracks, seed),
    seed: seed,
    kids:
        tracks.contains(Track.a) ||
        (tracks.length == 1 && tracks.first == Track.b),
    height: height,
    animate: animate,
  );

  factory SceneArt.forLesson(
    Lesson l, {
    double height = 150,
    bool animate = true,
  }) => SceneArt(
    kind: sceneFor(l),
    seed: l.id.hashCode,
    kids:
        l.tracks.contains(Track.a) ||
        (l.tracks.length == 1 && l.tracks.first == Track.b),
    height: height,
    animate: animate,
  );

  @override
  State<SceneArt> createState() => _SceneArtState();
}

class _SceneArtState extends State<SceneArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SceneArt old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final move = widget.animate && !context.reducedMotion;
    if (move && !_loop.isAnimating) {
      _loop.repeat();
    } else if (!move && _loop.isAnimating) {
      _loop.stop();
      _loop.value = 0;
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: context.t('visual.alt.scene'),
    child: SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _loop,
          builder: (_, _) => CustomPaint(
            painter: _ScenePainter(
              widget.kind,
              widget.seed,
              widget.kids,
              widget.tint ?? Colors.white,
              _loop.value,
              _loop.isAnimating,
            ),
          ),
        ),
      ),
    ),
  );
}

class _ScenePainter extends CustomPainter {
  final String kind;
  final int seed;
  final bool kids;
  final Color tint;

  /// Loop phase, 0 to 1, used only while [moving].
  final double t;
  final bool moving;
  _ScenePainter(
    this.kind,
    this.seed,
    this.kids,
    this.tint, [
    this.t = 0,
    this.moving = false,
  ]);

  double wave(double offset, [double speed = 1]) =>
      moving ? math.sin((t * speed + offset) * 2 * math.pi) : 0;

  late double w, h;
  late Canvas c;
  late math.Random r;

  Who who({int mood = 0, int pose = 0, bool kid = false, bool coat = false}) =>
      Who.seeded(r, mood: mood, pose: pose, kid: kid || kids, coat: coat);

  void person(
    double x,
    double scale,
    Who p, {
    bool flip = false,
    double alpha = 1,
  }) {
    // Breathing: each person grows and settles a little, out of step.
    final ph = h * scale * (p.kid ? 0.8 : 1) * (1 + 0.012 * wave(x * 1.7));
    c.drawOval(
      Rect.fromCenter(
        center: Offset(w * x, h * 0.93),
        width: ph * 0.42,
        height: h * 0.05,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.13 * alpha),
    );
    drawPerson(c, Offset(w * x, h * 0.92), ph, p, flip: flip, alpha: alpha);
  }

  void bubble(
    double x,
    double y,
    double bw, {
    bool tailLeft = true,
    Color? color,
    int dots = 3,
  }) {
    final rect = Rect.fromLTWH(w * x, h * y, bw, h * 0.2);
    final p = Paint()..color = color ?? tint.withValues(alpha: 0.92);
    c.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(h * 0.08)), p);
    final tx = tailLeft ? rect.left + bw * 0.25 : rect.right - bw * 0.25;
    c.drawPath(
      Path()
        ..moveTo(tx - h * 0.04, rect.bottom - 1)
        ..lineTo(tx + (tailLeft ? -h * 0.05 : h * 0.05), rect.bottom + h * 0.07)
        ..lineTo(tx + h * 0.04, rect.bottom - 1)
        ..close(),
      p,
    );
    for (var i = 0; i < dots; i++) {
      c.drawCircle(
        Offset(
          rect.center.dx + (i - (dots - 1) / 2) * h * 0.065,
          // Typing dots hop one after another.
          rect.center.dy - h * 0.022 * math.max(0, wave(-i * 0.12, 2)),
        ),
        h * 0.02,
        Paint()..color = Palette.dark.withValues(alpha: 0.55),
      );
    }
  }

  void heart(Offset o, double baseSize, Color col) {
    final s = baseSize * (1 + 0.1 * math.max(0, wave(0.25, 2)));
    final p = Path()
      ..moveTo(o.dx, o.dy + s * 0.9)
      ..cubicTo(
        o.dx - s * 1.5,
        o.dy - s * 0.1,
        o.dx - s * 0.6,
        o.dy - s * 1.1,
        o.dx,
        o.dy - s * 0.3,
      )
      ..cubicTo(
        o.dx + s * 0.6,
        o.dy - s * 1.1,
        o.dx + s * 1.5,
        o.dy - s * 0.1,
        o.dx,
        o.dy + s * 0.9,
      )
      ..close();
    c.drawPath(p, Paint()..color = col);
  }

  void glyph(String s, Offset center, double size, Color col) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: kFont,
          fontSize: size,
          fontWeight: FontWeight.w800,
          color: col,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    c = canvas;
    w = size.width;
    h = size.height;
    r = math.Random(seed);
    final soft = Paint()..color = tint.withValues(alpha: 0.14);
    c.drawCircle(Offset(w * 0.5, h * 0.62), h * 0.62, soft);
    c.drawCircle(Offset(w * 0.86, h * (0.2 + 0.03 * wave(0))), h * 0.16, soft);
    c.drawCircle(Offset(w * 0.1, h * (0.28 + 0.03 * wave(0.5))), h * 0.1, soft);
    switch (kind) {
      case 'family':
        person(0.42, 0.84, who(pose: 3, kid: false).._adult());
        person(0.6, 0.62, who(pose: 3, kid: true), flip: true);
        heart(Offset(w * 0.52, h * 0.2), h * 0.07, Palette.coral);
      case 'doctor':
        person(0.37, 0.84, who(coat: true, mood: 3));
        person(0.63, 0.8, who(mood: 0), flip: true);
        c.drawCircle(
          Offset(w * 0.85, h * 0.24),
          h * 0.13,
          Paint()..color = tint.withValues(alpha: 0.92),
        );
        final cross = Paint()
          ..color = Palette.deepMint
          ..strokeWidth = h * 0.05
          ..strokeCap = StrokeCap.round;
        c.drawLine(
          Offset(w * 0.85, h * 0.17),
          Offset(w * 0.85, h * 0.31),
          cross,
        );
        c.drawLine(
          Offset(w * 0.85 - h * 0.07, h * 0.24),
          Offset(w * 0.85 + h * 0.07, h * 0.24),
          cross,
        );
      case 'phone':
        person(0.34, 0.84, who(pose: 2, mood: 1));
        bubble(0.52, 0.12, w * 0.3, color: tint.withValues(alpha: 0.92));
        bubble(
          0.6,
          0.42,
          w * 0.26,
          tailLeft: false,
          color: Palette.sun,
          dots: 2,
        );
        // warning triangle
        final t = Offset(w * 0.88, h * 0.78);
        c.drawPath(
          Path()
            ..moveTo(t.dx, t.dy - h * 0.14)
            ..lineTo(t.dx - h * 0.13, t.dy + h * 0.08)
            ..lineTo(t.dx + h * 0.13, t.dy + h * 0.08)
            ..close(),
          Paint()..color = Palette.coral,
        );
        glyph('!', t + Offset(0, h * 0.005), h * 0.14, Colors.white);
      case 'stop':
        person(0.34, 0.84, who(pose: 1, mood: 1));
        final dash = Paint()
          ..color = tint.withValues(alpha: 0.9)
          ..strokeWidth = h * 0.02
          ..strokeCap = StrokeCap.round;
        for (var y = 0.12; y < 0.92; y += 0.11) {
          c.drawLine(
            Offset(w * 0.58, h * y),
            Offset(w * 0.58, h * (y + 0.055)),
            dash,
          );
        }
        person(0.8, 0.8, who(mood: 1), flip: true, alpha: 0.55);
      case 'circle':
        person(0.24, 0.74, who(), flip: false);
        person(0.76, 0.74, who(mood: 3), flip: true);
        person(0.5, 0.84, who());
        heart(Offset(w * 0.5, h * 0.1), h * 0.06, Palette.coral);
      case 'think':
        person(0.32, 0.84, who(mood: 1));
        for (final (x, y, s) in const [
          (0.46, 0.34, 0.03),
          (0.52, 0.25, 0.045),
        ]) {
          c.drawCircle(
            Offset(w * x, h * y),
            h * s,
            Paint()..color = tint.withValues(alpha: 0.92),
          );
        }
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.56, h * 0.06, w * 0.36, h * 0.42),
            Radius.circular(h * 0.16),
          ),
          Paint()..color = tint.withValues(alpha: 0.92),
        );
        glyph('?', Offset(w * 0.68, h * 0.27), h * 0.3, Palette.purple);
        glyph('!', Offset(w * 0.82, h * 0.27), h * 0.3, Palette.coral);
      case 'law':
        person(0.3, 0.84, who(mood: 0));
        final o = Offset(w * 0.7, h * 0.2);
        final ink = Paint()
          ..color = tint
          ..strokeWidth = h * 0.03
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        c.drawLine(o, Offset(o.dx, h * 0.84), ink);
        c.drawLine(
          Offset(o.dx - w * 0.14, o.dy + h * 0.06),
          Offset(o.dx + w * 0.14, o.dy + h * 0.06),
          ink,
        );
        c.drawLine(
          Offset(o.dx - w * 0.07, h * 0.86),
          Offset(o.dx + w * 0.07, h * 0.86),
          ink,
        );
        for (final s in [-1.0, 1.0]) {
          final px = o.dx + s * w * 0.14;
          c.drawLine(
            Offset(px, o.dy + h * 0.06),
            Offset(px - w * 0.05, h * 0.5),
            ink..strokeWidth = h * 0.014,
          );
          c.drawLine(
            Offset(px, o.dy + h * 0.06),
            Offset(px + w * 0.05, h * 0.5),
            ink,
          );
          c.drawArc(
            Rect.fromCenter(
              center: Offset(px, h * 0.5),
              width: w * 0.1,
              height: h * 0.16,
            ),
            0,
            math.pi,
            true,
            Paint()..color = s < 0 ? Palette.sun : Palette.mint,
          );
          ink.strokeWidth = h * 0.03;
        }
        c.drawCircle(o, h * 0.035, Paint()..color = tint);
      case 'couple':
        person(0.36, 0.84, who(mood: 3).._adult());
        person(0.64, 0.84, who(mood: 0).._adult(), flip: true);
        bubble(0.06, 0.06, w * 0.24);
        bubble(0.7, 0.06, w * 0.24, tailLeft: false, color: Palette.mint);
      case 'mirror':
        final me = who(mood: 0);
        final frame = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.56, h * 0.08, w * 0.3, h * 0.84),
          Radius.circular(w * 0.15),
        );
        c.drawRRect(frame, Paint()..color = tint.withValues(alpha: 0.95));
        c.drawRRect(
          frame.deflate(h * 0.035),
          Paint()..color = const Color(0xFFCFE6FF),
        );
        c.save();
        c.clipRRect(frame.deflate(h * 0.035));
        drawPerson(
          c,
          Offset(w * 0.71, h * 0.94),
          h * 0.72,
          me,
          flip: true,
          alpha: 0.75,
        );
        c.restore();
        person(0.3, 0.84, me);
        heart(Offset(w * 0.47, h * 0.2), h * 0.05, Palette.coral);
      case 'grow':
        person(0.2, 0.56, who(kid: true));
        person(0.47, 0.72, who());
        person(0.76, 0.86, who().._adult());
        final arrow = Paint()
          ..color = tint.withValues(alpha: 0.9)
          ..strokeWidth = h * 0.022
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        c.drawLine(
          Offset(w * 0.06, h * 0.4),
          Offset(w * 0.93, h * 0.06),
          arrow,
        );
        c.drawLine(
          Offset(w * 0.93, h * 0.06),
          Offset(w * 0.88, h * 0.05),
          arrow,
        );
        c.drawLine(
          Offset(w * 0.93, h * 0.06),
          Offset(w * 0.915, h * 0.14),
          arrow,
        );
      case 'period':
        person(0.3, 0.84, who(mood: 0));
        final cal = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.54, h * 0.14, w * 0.36, h * 0.66),
          Radius.circular(h * 0.07),
        );
        c.drawRRect(cal, Paint()..color = tint.withValues(alpha: 0.96));
        c.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(cal.left, cal.top, cal.width, h * 0.15),
            topLeft: Radius.circular(h * 0.07),
            topRight: Radius.circular(h * 0.07),
          ),
          Paint()..color = Palette.coral,
        );
        for (var row = 0; row < 3; row++) {
          for (var col = 0; col < 5; col++) {
            final period = row == 0 && col < 4;
            c.drawCircle(
              Offset(
                cal.left + cal.width * (0.14 + col * 0.18),
                cal.top + h * (0.26 + row * 0.13),
              ),
              h * 0.032,
              Paint()
                ..color = period
                    ? Palette.coral
                    : Palette.dark.withValues(alpha: 0.14),
            );
          }
        }
      case 'media':
        person(0.26, 0.84, who(mood: 1));
        final scr = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.46, h * 0.12, w * 0.46, h * 0.62),
          Radius.circular(h * 0.06),
        );
        c.drawRRect(scr, Paint()..color = Palette.dark);
        c.drawRRect(
          scr.deflate(h * 0.03),
          Paint()..color = const Color(0xFF9B86FF),
        );
        c.save();
        c.clipRRect(scr.deflate(h * 0.03));
        drawPerson(
          c,
          Offset(scr.center.dx, scr.bottom + h * 0.22),
          h * 0.8,
          who(mood: 0),
        );
        c.restore();
        for (final (x, y) in const [(0.52, 0.2), (0.86, 0.3), (0.56, 0.6)]) {
          glyph('✦', Offset(w * x, h * y), h * 0.12, Palette.sun);
        }
        heart(Offset(w * 0.86, h * 0.62), h * 0.045, Palette.coral);
        c.drawRect(
          Rect.fromLTWH(w * 0.62, h * 0.74, w * 0.14, h * 0.1),
          Paint()..color = Palette.dark,
        );
      case 'class':
        person(0.26, 0.84, who(pose: 1, mood: 3).._adult());
        final board = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.48, h * 0.12, w * 0.44, h * 0.6),
          Radius.circular(h * 0.04),
        );
        c.drawRRect(board, Paint()..color = const Color(0xFF1E5E4E));
        final chalk = Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..strokeWidth = h * 0.018
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;
        c.drawCircle(
          Offset(board.left + board.width * 0.28, board.top + h * 0.16),
          h * 0.055,
          chalk,
        );
        c.drawLine(
          Offset(board.left + board.width * 0.28, board.top + h * 0.22),
          Offset(board.left + board.width * 0.28, board.top + h * 0.42),
          chalk,
        );
        c.drawLine(
          Offset(board.left + board.width * 0.16, board.top + h * 0.29),
          Offset(board.left + board.width * 0.4, board.top + h * 0.29),
          chalk,
        );
        for (var i = 0; i < 3; i++) {
          c.drawLine(
            Offset(
              board.left + board.width * 0.54,
              board.top + h * (0.15 + i * 0.12),
            ),
            Offset(
              board.left + board.width * (0.9 - i * 0.08),
              board.top + h * (0.15 + i * 0.12),
            ),
            chalk,
          );
        }
      default: // friends
        person(0.34, 0.84, who(mood: 0));
        person(0.64, 0.82, who(mood: 3), flip: true);
        bubble(0.62, 0.02, w * 0.26, tailLeft: false);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter o) =>
      o.kind != kind ||
      o.seed != seed ||
      o.kids != kids ||
      o.tint != tint ||
      o.t != t ||
      o.moving != moving;
}

extension on Who {
  /// Marks a grown-up in scenes that are otherwise drawn with children.
  Who _adult() => Who(
    skin: skin,
    hair: hair,
    top: top,
    bottom: bottom,
    hairStyle: hairStyle,
    mood: mood,
    pose: pose,
    glasses: glasses,
    coat: coat,
  );
}

// ───────────────────────── Real objects ─────────────────────────

/// Which object illustrates a contraceptive method id.
String objectForMethod(String id) =>
    const {
      'implant': 'implant',
      'hormonal_iud': 'iud',
      'copper_iud': 'iud_cu',
      'injectable': 'injection',
      'pill': 'pill',
      'external_condom': 'condom',
      'internal_condom': 'condom_in',
      'withdrawal': 'warn',
      'calendar': 'calendar',
      'none': 'question',
      'abstinence': 'pause',
      'emergency': 'emergency',
    }[id] ??
    'question';

/// A drawing of a real object, so learners recognise it when they see it.
class ObjectArt extends StatelessWidget {
  final String kind;
  final double size;
  const ObjectArt(this.kind, {super.key, this.size = 64});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.isDark
            ? const Color(0xFF2A2A52)
            : const Color(0xFFF4F0FF),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: CustomPaint(painter: _ObjectPainter(kind)),
    ),
  );
}

class _ObjectPainter extends CustomPainter {
  final String kind;
  _ObjectPainter(this.kind);

  @override
  void paint(Canvas c, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(s * x, s * y);
    Paint fill(Color col) => Paint()..color = col;
    Paint line(Color col, double w) => Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    RRect rr(double l, double t, double r, double b, double rad) =>
        RRect.fromRectAndRadius(
          Rect.fromLTRB(s * l, s * t, s * r, s * b),
          Radius.circular(s * rad),
        );
    const ink = Color(0xFF3B3B66);
    const rose = Color(0xFFFF8A9A);
    switch (kind) {
      case 'pad':
        c.drawRRect(rr(0.34, 0.14, 0.66, 0.86, 0.16), fill(Colors.white));
        c.drawRRect(
          rr(0.34, 0.14, 0.66, 0.86, 0.16),
          line(const Color(0xFFB7B3E6), 0.02),
        );
        c.drawRRect(
          rr(0.16, 0.4, 0.84, 0.6, 0.08),
          fill(const Color(0xFFE9E5FF)),
        );
        c.drawRRect(
          rr(0.43, 0.26, 0.57, 0.74, 0.07),
          fill(const Color(0xFFCFE6FF)),
        );
      case 'tampon':
        c.drawRRect(rr(0.4, 0.14, 0.6, 0.6, 0.1), fill(Colors.white));
        c.drawRRect(
          rr(0.4, 0.14, 0.6, 0.6, 0.1),
          line(const Color(0xFFB7B3E6), 0.02),
        );
        c.drawPath(
          Path()
            ..moveTo(s * 0.5, s * 0.6)
            ..quadraticBezierTo(s * 0.58, s * 0.74, s * 0.46, s * 0.88),
          line(const Color(0xFF80B9FF), 0.025),
        );
      case 'cup':
        final cup = Path()
          ..moveTo(s * 0.28, s * 0.2)
          ..lineTo(s * 0.72, s * 0.2)
          ..cubicTo(s * 0.72, s * 0.52, s * 0.62, s * 0.68, s * 0.5, s * 0.7)
          ..cubicTo(s * 0.38, s * 0.68, s * 0.28, s * 0.52, s * 0.28, s * 0.2)
          ..close();
        c.drawPath(cup, fill(const Color(0xFFFFB5C0)));
        c.drawPath(cup, line(rose, 0.02));
        c.drawRRect(rr(0.26, 0.17, 0.74, 0.24, 0.035), fill(rose));
        c.drawRRect(rr(0.47, 0.7, 0.53, 0.88, 0.03), fill(rose));
      case 'cloth':
        final u = Path()
          ..moveTo(s * 0.18, s * 0.28)
          ..lineTo(s * 0.82, s * 0.28)
          ..lineTo(s * 0.8, s * 0.48)
          ..quadraticBezierTo(s * 0.62, s * 0.52, s * 0.56, s * 0.78)
          ..lineTo(s * 0.44, s * 0.78)
          ..quadraticBezierTo(s * 0.38, s * 0.52, s * 0.2, s * 0.48)
          ..close();
        c.drawPath(u, fill(const Color(0xFF9B86FF)));
        c.drawRRect(
          rr(0.18, 0.26, 0.82, 0.33, 0.03),
          fill(const Color(0xFF765BFF)),
        );
        c.drawRRect(
          rr(0.45, 0.5, 0.55, 0.76, 0.04),
          fill(const Color(0xFFE9E5FF)),
        );
      case 'condom':
        c.drawRRect(
          rr(0.16, 0.2, 0.6, 0.8, 0.07),
          fill(const Color(0xFF80B9FF)),
        );
        c.drawCircle(p(0.38, 0.5), s * 0.15, line(Colors.white, 0.03));
        c.drawCircle(p(0.38, 0.5), s * 0.04, fill(Colors.white));
        final un = Path()
          ..moveTo(s * 0.68, s * 0.8)
          ..lineTo(s * 0.68, s * 0.34)
          ..quadraticBezierTo(s * 0.68, s * 0.24, s * 0.74, s * 0.22)
          ..quadraticBezierTo(s * 0.76, s * 0.14, s * 0.78, s * 0.22)
          ..quadraticBezierTo(s * 0.84, s * 0.24, s * 0.84, s * 0.34)
          ..lineTo(s * 0.84, s * 0.8);
        c.drawPath(un, line(const Color(0xFF3D8BFF), 0.025));
        c.drawRRect(
          rr(0.65, 0.78, 0.87, 0.84, 0.03),
          fill(const Color(0xFF3D8BFF)),
        );
      case 'condom_in':
        final pouch = Path()
          ..moveTo(s * 0.3, s * 0.22)
          ..lineTo(s * 0.7, s * 0.22)
          ..lineTo(s * 0.62, s * 0.74)
          ..quadraticBezierTo(s * 0.5, s * 0.84, s * 0.38, s * 0.74)
          ..close();
        c.drawPath(pouch, fill(const Color(0xFFCFE6FF)));
        c.drawPath(pouch, line(const Color(0xFF3D8BFF), 0.022));
        c.drawOval(
          Rect.fromCenter(
            center: p(0.5, 0.22),
            width: s * 0.5,
            height: s * 0.14,
          ),
          line(const Color(0xFF3D8BFF), 0.035),
        );
        c.drawOval(
          Rect.fromCenter(
            center: p(0.5, 0.7),
            width: s * 0.22,
            height: s * 0.08,
          ),
          line(const Color(0xFF3D8BFF), 0.025),
        );
      case 'pill':
        c.drawRRect(
          rr(0.14, 0.24, 0.86, 0.76, 0.08),
          fill(const Color(0xFFDAD6F5)),
        );
        for (var row = 0; row < 3; row++) {
          for (var col = 0; col < 5; col++) {
            c.drawCircle(
              p(0.24 + col * 0.13, 0.35 + row * 0.15),
              s * 0.045,
              fill(row == 2 && col > 2 ? Colors.white : rose),
            );
          }
        }
      case 'iud':
      case 'iud_cu':
        final col = kind == 'iud_cu'
            ? const Color(0xFFC9772B)
            : const Color(0xFF765BFF);
        c.drawLine(p(0.26, 0.24), p(0.74, 0.24), line(Colors.white, 0.07));
        c.drawLine(
          p(0.26, 0.24),
          p(0.74, 0.24),
          line(const Color(0xFFB7B3E6), 0.035),
        );
        c.drawLine(p(0.5, 0.24), p(0.5, 0.62), line(col, 0.07));
        if (kind == 'iud_cu') {
          for (var y = 0.3; y < 0.6; y += 0.06) {
            c.drawLine(
              p(0.46, y),
              p(0.54, y + 0.02),
              line(const Color(0xFFFFD27A), 0.015),
            );
          }
        }
        c.drawLine(p(0.49, 0.62), p(0.45, 0.86), line(ink, 0.012));
        c.drawLine(p(0.51, 0.62), p(0.56, 0.86), line(ink, 0.012));
      case 'implant':
        final armP = Path()
          ..moveTo(s * 0.12, s * 0.3)
          ..quadraticBezierTo(s * 0.5, s * 0.22, s * 0.88, s * 0.38)
          ..lineTo(s * 0.88, s * 0.66)
          ..quadraticBezierTo(s * 0.5, s * 0.6, s * 0.12, s * 0.72)
          ..close();
        c.drawPath(armP, fill(const Color(0xFFE0A878)));
        c.drawLine(p(0.4, 0.44), p(0.62, 0.47), line(Colors.white, 0.05));
        c.drawLine(
          p(0.4, 0.44),
          p(0.62, 0.47),
          line(const Color(0xFF765BFF), 0.028),
        );
      case 'injection':
        c.save();
        c.translate(s * 0.5, s * 0.5);
        c.rotate(-math.pi / 4);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: s * 0.44,
              height: s * 0.16,
            ),
            Radius.circular(s * 0.03),
          ),
          fill(Colors.white),
        );
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: s * 0.44,
              height: s * 0.16,
            ),
            Radius.circular(s * 0.03),
          ),
          line(const Color(0xFF3D8BFF), 0.02),
        );
        c.drawRect(
          Rect.fromLTWH(-s * 0.2, -s * 0.06, s * 0.22, s * 0.12),
          fill(const Color(0xFFCFE6FF)),
        );
        c.drawLine(Offset(s * 0.22, 0), Offset(s * 0.4, 0), line(ink, 0.014));
        c.drawLine(
          Offset(-s * 0.22, 0),
          Offset(-s * 0.36, 0),
          line(const Color(0xFF3D8BFF), 0.03),
        );
        c.drawLine(
          Offset(-s * 0.36, -s * 0.08),
          Offset(-s * 0.36, s * 0.08),
          line(const Color(0xFF3D8BFF), 0.03),
        );
        c.restore();
      case 'calendar':
        c.drawRRect(rr(0.18, 0.2, 0.82, 0.82, 0.08), fill(Colors.white));
        c.drawRRect(rr(0.18, 0.2, 0.82, 0.36, 0.08), fill(rose));
        for (var row = 0; row < 2; row++) {
          for (var col = 0; col < 4; col++) {
            c.drawCircle(
              p(0.29 + col * 0.14, 0.5 + row * 0.16),
              s * 0.035,
              fill(const Color(0xFFDAD6F5)),
            );
          }
        }
        c.drawLine(
          p(0.3, 0.3),
          p(0.74, 0.78),
          line(const Color(0xFFC62F47), 0.045),
        );
      case 'emergency':
        c.drawCircle(p(0.42, 0.52), s * 0.24, fill(Colors.white));
        c.drawCircle(
          p(0.42, 0.52),
          s * 0.24,
          line(const Color(0xFFE39A00), 0.035),
        );
        c.drawLine(p(0.42, 0.52), p(0.42, 0.37), line(ink, 0.03));
        c.drawLine(p(0.42, 0.52), p(0.53, 0.56), line(ink, 0.03));
        c.drawOval(
          Rect.fromCenter(
            center: p(0.72, 0.72),
            width: s * 0.24,
            height: s * 0.13,
          ),
          fill(rose),
        );
      case 'pause':
        c.drawCircle(p(0.5, 0.5), s * 0.3, fill(const Color(0xFFA9EBD4)));
        c.drawRRect(
          rr(0.39, 0.36, 0.46, 0.64, 0.03),
          fill(const Color(0xFF12855F)),
        );
        c.drawRRect(
          rr(0.54, 0.36, 0.61, 0.64, 0.03),
          fill(const Color(0xFF12855F)),
        );
      case 'warn':
        final t = Path()
          ..moveTo(s * 0.5, s * 0.2)
          ..lineTo(s * 0.82, s * 0.76)
          ..lineTo(s * 0.18, s * 0.76)
          ..close();
        c.drawPath(t, fill(const Color(0xFFFFC95C)));
        c.drawLine(p(0.5, 0.4), p(0.5, 0.56), line(ink, 0.045));
        c.drawCircle(p(0.5, 0.66), s * 0.028, fill(ink));
      default: // question
        c.drawCircle(
          p(0.5, 0.5),
          s * 0.3,
          line(const Color(0xFFB7B3E6), 0.035),
        );
        c.drawArc(
          Rect.fromCenter(
            center: p(0.5, 0.43),
            width: s * 0.2,
            height: s * 0.2,
          ),
          math.pi,
          math.pi * 1.5,
          false,
          line(ink, 0.04),
        );
        c.drawLine(p(0.5, 0.53), p(0.5, 0.58), line(ink, 0.04));
        c.drawCircle(p(0.5, 0.67), s * 0.026, fill(ink));
    }
  }

  @override
  bool shouldRepaint(_ObjectPainter o) => o.kind != kind;
}

/// A labelled row of real period products.
class PeriodProducts extends StatelessWidget {
  const PeriodProducts({super.key});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final k in const ['pad', 'tampon', 'cup', 'cloth'])
        Expanded(
          child: Column(
            children: [
              ObjectArt(k, size: 62),
              const SizedBox(height: 6),
              Text(
                context.t('visual.$k'),
                textAlign: TextAlign.center,
                style: context.tx.labelMedium,
              ),
            ],
          ),
        ),
    ],
  );
}
