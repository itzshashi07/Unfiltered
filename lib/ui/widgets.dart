import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/models.dart';

/// Current text scale factor (system setting x in-app text size), at least 1.
double textScaleOf(BuildContext context) {
  final s = MediaQuery.textScalerOf(context).scale(100) / 100;
  return s < 1 ? 1 : s;
}

/// Press feedback: gently scales its child. Honors reduced motion.
class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final BorderRadius? radius;
  const Tap({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.radius,
  });

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTapUp: enabled ? (_) => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              }
            : null,
        child: AnimatedScale(
          scale: _down && !context.reducedMotion ? 0.97 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double radius;
  final bool border;
  final String? semanticLabel;
  final double? width;
  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.radius = 24,
    this.border = true,
    this.semanticLabel,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final box = Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border && gradient == null && color == null
            ? Border.all(color: c.outline, width: 1.2)
            : null,
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: Palette.dark.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: child,
    );
    return onTap == null
        ? box
        : Tap(onTap: onTap, semanticLabel: semanticLabel, child: box);
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? foreground;
  final bool expand;
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.foreground,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final enabled = onPressed != null;
    final bg = enabled ? (color ?? c.primary) : c.surfaceAlt;
    final fg = enabled ? (foreground ?? c.onPrimary) : c.inkSoft;
    return Tap(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        width: expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled && !context.isDark
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.tx.labelLarge?.copyWith(color: fg, fontSize: 16),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, color: fg, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class SoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  const SoftButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) => PrimaryButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    expand: expand,
    color: context.c.primarySoft,
    foreground: context.isDark ? Colors.white : context.c.primary,
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? foreground;
  final IconData? icon;
  const Pill(this.text, {super.key, this.color, this.foreground, this.icon});

  @override
  Widget build(BuildContext context) {
    final fg = foreground ?? context.c.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color ?? context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tx.labelMedium?.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// A selectable chip with a visible check mark (never colour alone).
class ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tap(
      onTap: onTap,
      child: Semantics(
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? c.primary : c.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected ? c.primary : c.outline,
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 16, color: c.onPrimary),
                const SizedBox(width: 6),
              ] else if (icon != null) ...[
                Icon(icon, size: 16, color: c.inkSoft),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: context.tx.labelLarge?.copyWith(
                    fontSize: 14,
                    color: selected ? c.onPrimary : c.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: context.tx.headlineSmall),
          ),
        ),
        if (action != null)
          Tap(
            onTap: onAction,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 6, bottom: 2),
              child: Text(
                action!,
                style: context.tx.labelLarge?.copyWith(
                  color: context.c.primary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

/// Animated circular progress with a centre slot.
class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color? color;
  final Color? track;
  final Widget? child;
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.stroke = 7,
    this.color,
    this.track,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Semantics(
      label: '${(value * 100).round()}%',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 1)),
        duration: context.reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, v, _) => SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              v,
              color ?? c.primary,
              track ?? c.primarySoft,
              stroke,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color color;
  final Color track;
  final double stroke;
  _RingPainter(this.v, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (v > 0) {
      canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.v != v || o.color != color || o.track != track;
}

/// Entrance animation: fade + rise. Static when reduced motion is on.
class FadeSlide extends StatelessWidget {
  final Widget child;
  final int delayMs;
  final double dy;
  const FadeSlide({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.dy = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return child;
    final total = 420 + delayMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (_, t, c) {
        final start = delayMs / total;
        final v = Curves.easeOutCubic.transform(
          ((t - start) / (1 - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: c),
        );
      },
      child: child,
    );
  }
}

enum Mood { happy, curious, calm, wow }

/// "Fil" — the app's original guide character, drawn in code.
class Mascot extends StatefulWidget {
  final double size;
  final Mood mood;
  const Mascot({super.key, this.size = 96, this.mood = Mood.happy});

  @override
  State<Mascot> createState() => _MascotState();
}

class _MascotState extends State<Mascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reducedMotion) {
      _c.stop();
      _c.value = 0.2;
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
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: _MascotPainter(_c.value, widget.mood),
        ),
      ),
    ),
  );
}

class _MascotPainter extends CustomPainter {
  final double t;
  final Mood mood;
  _MascotPainter(this.t, this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final bob = math.sin(t * math.pi * 2) * s * 0.025;
    canvas.translate(0, bob);
    // soft ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.93 - bob),
        width: s * 0.5,
        height: s * 0.07,
      ),
      Paint()..color = Palette.dark.withValues(alpha: 0.12),
    );
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.14, s * 0.14, s * 0.72, s * 0.72),
      Radius.circular(s * 0.3),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B86FF), Palette.purple, Color(0xFF5A3FE6)],
        ).createShader(body.outerRect),
    );
    // top-left highlight for a soft 3D feel
    canvas.drawOval(
      Rect.fromLTWH(s * 0.22, s * 0.19, s * 0.3, s * 0.16),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );
    // antenna spark
    final spark = Offset(s * 0.5, s * 0.07);
    canvas.drawLine(
      Offset(s * 0.5, s * 0.15),
      spark,
      Paint()
        ..color = Palette.purple
        ..strokeWidth = s * 0.03
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(spark, s * 0.045, Paint()..color = Palette.coral);
    // eyes (blink near the end of each loop)
    final blink = t > 0.94
        ? (1 - ((t - 0.94) / 0.06 - 0.5).abs() * 2).clamp(0.0, 1.0)
        : 0.0;
    final eyeH = s * (mood == Mood.wow ? 0.2 : 0.17) * (1 - blink * 0.9);
    for (final dx in [0.36, 0.64]) {
      final c = Offset(s * dx, s * 0.46);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: s * 0.15, height: eyeH),
        Paint()..color = Colors.white,
      );
      final look = mood == Mood.curious
          ? Offset(s * 0.015, -s * 0.015)
          : Offset.zero;
      canvas.drawOval(
        Rect.fromCenter(
          center: c + look,
          width: s * 0.075,
          height: math.min(eyeH, s * 0.085),
        ),
        Paint()..color = Palette.dark,
      );
    }
    // cheeks
    for (final dx in [0.26, 0.74]) {
      canvas.drawCircle(
        Offset(s * dx, s * 0.6),
        s * 0.045,
        Paint()..color = Palette.coral.withValues(alpha: 0.55),
      );
    }
    // mouth
    final mp = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    final m = Offset(s * 0.5, s * 0.64);
    switch (mood) {
      case Mood.happy:
        canvas.drawArc(
          Rect.fromCenter(center: m, width: s * 0.2, height: s * 0.14),
          0.15,
          math.pi - 0.3,
          false,
          mp,
        );
      case Mood.calm:
        canvas.drawArc(
          Rect.fromCenter(center: m, width: s * 0.16, height: s * 0.06),
          0.2,
          math.pi - 0.4,
          false,
          mp,
        );
      case Mood.curious:
        canvas.drawCircle(m + Offset(0, s * 0.02), s * 0.03, mp);
      case Mood.wow:
        canvas.drawOval(
          Rect.fromCenter(
            center: m + Offset(0, s * 0.02),
            width: s * 0.09,
            height: s * 0.11,
          ),
          Paint()..color = Colors.white,
        );
    }
  }

  @override
  bool shouldRepaint(_MascotPainter o) => o.t != t || o.mood != mood;
}

/// Original abstract artwork for a curriculum domain: layered shapes + icon.
class DomainArt extends StatelessWidget {
  final String domainId;
  final double size;
  final double radius;
  const DomainArt(this.domainId, {super.key, this.size = 64, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final st = DomainStyle.of(domainId);
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CustomPaint(
            painter: _ArtPainter(
              st,
              int.tryParse(domainId.replaceAll('d', '')) ?? 1,
            ),
            child: Center(
              child: Icon(
                st.icon,
                color: Colors.white,
                size: size * 0.46,
                shadows: [
                  Shadow(
                    color: Palette.dark.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  final DomainStyle st;
  final int seed;
  _ArtPainter(this.st, this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [st.a, Color.lerp(st.a, st.b, 0.75)!],
        ).createShader(r),
    );
    final rnd = math.Random(seed * 97);
    for (var i = 0; i < 4; i++) {
      final c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final rad = size.width * (0.22 + rnd.nextDouble() * 0.3);
      canvas.drawCircle(
        c,
        rad,
        Paint()..color = Colors.white.withValues(alpha: 0.07 + i * 0.03),
      );
    }
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.16),
      size.width * 0.1,
      Paint()..color = st.b.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(_ArtPainter o) => o.seed != seed;
}

/// A short, tasteful confetti burst. Never used for sensitive topics.
class Celebration extends StatefulWidget {
  const Celebration({super.key});

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_c.value),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);
  static const _colors = [
    Palette.purple,
    Palette.coral,
    Palette.mint,
    Palette.blue,
    Palette.sun,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    for (var i = 0; i < 46; i++) {
      final x0 = rnd.nextDouble();
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final sway = (rnd.nextDouble() - 0.5) * 0.25;
      final rot = rnd.nextDouble() * math.pi * 2;
      final w = 6 + rnd.nextDouble() * 6;
      final y = -0.1 + t * speed * 1.3;
      final x = x0 + math.sin(t * 6 + i) * 0.03 + sway * t;
      final fade = (1 - (t - 0.7).clamp(0.0, 0.3) / 0.3);
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rot + t * 8 * (i.isEven ? 1 : -1));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.55),
          const Radius.circular(2),
        ),
        Paint()..color = _colors[i % _colors.length].withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter o) => o.t != t;
}

class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final String? title;
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final col = color ?? context.c.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: col.withValues(alpha: context.isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: col.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: col, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(title!, style: context.tx.titleSmall),
                  ),
                Text(text, style: context.tx.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String body;
  final Mood mood;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.mood = Mood.curious,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Mascot(size: 110, mood: mood),
          const SizedBox(height: 18),
          Text(
            title,
            style: context.tx.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: context.tx.bodyMedium?.copyWith(color: context.c.inkSoft),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}

/// The review-status line shown wherever health or legal content appears.
class ReviewNote extends StatelessWidget {
  const ReviewNote({super.key});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.pending_actions_rounded, size: 16, color: context.c.inkSoft),
      const SizedBox(width: 8),
      Expanded(
        child: Text(context.t('review.pending'), style: context.tx.bodySmall),
      ),
    ],
  );
}

/// Sources attached to a piece of content. Tapping opens the reference sheet.
class SourceList extends StatelessWidget {
  final List<RefEntry> refs;
  const SourceList(this.refs, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final r in refs)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Tap(
              onTap: () => showRefSheet(context, r),
              semanticLabel: '${r.title}, ${r.publisher}',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.outline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 18, color: c.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: context.tx.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            r.publisher,
                            style: context.tx.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.inkSoft),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

void showRefSheet(BuildContext context, RefEntry r) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Pill(
              ctx.t('refs.cat.${r.category}'),
              icon: Icons.verified_outlined,
            ),
            const SizedBox(height: 12),
            Text(r.title, style: ctx.tx.headlineSmall),
            const SizedBox(height: 6),
            Text(
              r.publisher,
              style: ctx.tx.bodyMedium?.copyWith(color: ctx.c.inkSoft),
            ),
            const SizedBox(height: 12),
            SelectableText(
              r.url,
              style: ctx.tx.bodySmall?.copyWith(color: ctx.c.primary),
            ),
            const SizedBox(height: 12),
            Text(
              ctx.t(
                r.reachable ? 'refs.status.ok' : 'refs.status.unreachable',
                {'date': r.checked},
              ),
              style: ctx.tx.bodySmall,
            ),
            const SizedBox(height: 6),
            Text(ctx.t('refs.status.review'), style: ctx.tx.bodySmall),
            const SizedBox(height: 18),
            PrimaryButton(
              label: ctx.t('refs.open'),
              icon: Icons.open_in_new_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                openUrl(context, r.url);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Opens a link in the device browser. Only ever called from a user tap.
Future<void> openUrl(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failText = context.t('link.fail');
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) messenger?.showSnackBar(SnackBar(content: Text('$failText $url')));
}

/// Asks before opening the dialer. A call is never started automatically.
Future<void> confirmCall(
  BuildContext context,
  String number,
  String name,
) async {
  final go = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.t('call.title', {'number': number})),
      content: Text(ctx.t('call.body', {'name': name})),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.t('common.cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ctx.t('call.go')),
        ),
      ],
    ),
  );
  if (go != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failText = context.t('call.fail', {'number': number});
  var ok = false;
  try {
    ok = await launchUrl(Uri(scheme: 'tel', path: number));
  } catch (_) {
    ok = false;
  }
  if (!ok) messenger?.showSnackBar(SnackBar(content: Text(failText)));
}

/// Standard page padding with a max content width for tablets / landscape.
class PageBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;
  const PageBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 32),
    this.controller,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView(
        controller: controller,
        padding: padding,
        children: children,
      ),
    ),
  );
}

/// Drag to tilt: a light pseudo-3D effect for diagrams. Flat with reduced motion.
class TiltCard extends StatefulWidget {
  final Widget child;
  const TiltCard({super.key, required this.child});

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  Offset _tilt = Offset.zero;

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return widget.child;
    return Listener(
      onPointerMove: (e) => setState(() {
        _tilt = Offset(
          (_tilt.dx + e.delta.dx * 0.004).clamp(-0.32, 0.32),
          (_tilt.dy - e.delta.dy * 0.004).clamp(-0.32, 0.32),
        );
      }),
      onPointerUp: (_) => setState(() => _tilt = Offset.zero),
      onPointerCancel: (_) => setState(() => _tilt = Offset.zero),
      child: TweenAnimationBuilder<Offset>(
        tween: Tween(begin: Offset.zero, end: _tilt),
        duration: Duration(milliseconds: _tilt == Offset.zero ? 420 : 60),
        curve: Curves.easeOut,
        builder: (_, v, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0014)
            ..rotateY(v.dx)
            ..rotateX(v.dy),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
