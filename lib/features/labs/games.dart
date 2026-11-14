import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

/// Shared frame for round-based games: progress header + end-of-game summary.
class _Rounds extends StatelessWidget {
  final String title;
  final int index;
  final int total;
  final int score;
  final bool sensitive;
  final VoidCallback onRestart;
  final Widget Function() round;
  const _Rounds({
    required this.title,
    required this.index,
    required this.total,
    required this.score,
    required this.onRestart,
    required this.round,
    this.sensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final done = index >= total;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: total == 0
          ? EmptyState(
              title: context.t('quiz.empty'),
              body: context.t('quiz.empty.body'),
            )
          : PageBody(
              children: [
                if (!done) ...[
                  Row(
                    children: [
                      Text(
                        context.t('quiz.count', {
                          'n': index + 1,
                          'total': total,
                        }),
                        style: context.tx.labelMedium?.copyWith(
                          color: c.inkSoft,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: index / total,
                            minHeight: 6,
                            color: c.primary,
                            backgroundColor: c.primarySoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FadeSlide(key: ValueKey(index), child: round()),
                ] else
                  Column(
                    key: const Key('game-summary'),
                    children: [
                      const SizedBox(height: 16),
                      ProgressRing(
                        value: score / total,
                        size: 128,
                        stroke: 12,
                        color: c.success,
                        child: Text(
                          '$score/$total',
                          style: context.tx.displaySmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.t('game.done'),
                        style: context.tx.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.t('quiz.result.note'),
                        style: context.tx.bodyMedium?.copyWith(
                          color: c.inkSoft,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SoftButton(
                        label: context.t('quiz.retry'),
                        icon: Icons.refresh_rounded,
                        onPressed: onRestart,
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: context.t('common.done'),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

// ───────────────────────── Relationship Signals ─────────────────────────

class SignalsScreen extends ConsumerStatefulWidget {
  const SignalsScreen({super.key});

  @override
  ConsumerState<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends ConsumerState<SignalsScreen> {
  List<Signal>? _items;
  int _i = 0;
  int _score = 0;
  String? _pick;

  static const _cats = ['healthy', 'concerning', 'harmful'];
  static const _icons = [
    Icons.favorite_rounded,
    Icons.help_rounded,
    Icons.report_problem_rounded,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('signals'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    _items ??= (content.visible(
      content.signals,
      context.track,
    )..shuffle(math.Random())).take(10).toList();
    final items = _items!;
    final c = context.c;
    final colors = [c.success, c.warning, c.danger];
    return _Rounds(
      title: context.t('lab.signals.title'),
      index: _i,
      total: items.length,
      score: _score,
      onRestart: () => setState(() {
        _items = null;
        _i = 0;
        _score = 0;
        _pick = null;
      }),
      round: () {
        final s = items[_i];
        final right = _cats.indexOf(s.category);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('signals.prompt'),
              style: context.tx.labelLarge?.copyWith(color: c.inkSoft),
            ),
            const SizedBox(height: 10),
            AppCard(
              color: c.surfaceAlt,
              padding: const EdgeInsets.all(22),
              child: Text(context.lx(s.text), style: context.tx.headlineSmall),
            ),
            const SizedBox(height: 16),
            for (var k = 0; k < 3; k++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Tap(
                  key: Key('signal-${_cats[k]}'),
                  onTap: _pick != null
                      ? null
                      : () => setState(() {
                          _pick = _cats[k];
                          if (k == right) _score++;
                        }),
                  child: Opacity(
                    opacity: _pick != null && k != right && _pick != _cats[k]
                        ? 0.5
                        : 1,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _pick != null && k == right
                            ? colors[k].withValues(alpha: 0.14)
                            : c.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              _pick != null && (k == right || _pick == _cats[k])
                              ? colors[k]
                              : c.outline,
                          width: _pick != null && k == right ? 2.4 : 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(_icons[k], color: colors[k]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.t('signals.${_cats[k]}'),
                              style: context.tx.titleMedium,
                            ),
                          ),
                          if (_pick != null && k == right)
                            Icon(Icons.check_circle_rounded, color: colors[k]),
                          if (_pick == _cats[k] && k != right)
                            Icon(Icons.cancel_rounded, color: c.inkSoft),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_pick != null) ...[
              InfoBanner(
                key: const Key('signal-note'),
                icon: _icons[right],
                color: colors[right],
                title: _pick == s.category
                    ? context.t('quiz.correct')
                    : ((_cats.indexOf(_pick!) - right).abs() == 1
                          ? context.t('signals.close')
                          : context.t('quiz.notQuite')),
                text: context.lx(s.note),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                key: const Key('game-next'),
                label: context.t('common.next'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => setState(() {
                  _i++;
                  _pick = null;
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ───────────────────────── Digital Safety Challenge ─────────────────────────

class DigitalChallengeScreen extends ConsumerStatefulWidget {
  const DigitalChallengeScreen({super.key});

  @override
  ConsumerState<DigitalChallengeScreen> createState() =>
      _DigitalChallengeScreenState();
}

class _DigitalChallengeScreenState
    extends ConsumerState<DigitalChallengeScreen> {
  List<DigitalItem>? _items;
  int _i = 0;
  int _score = 0;
  bool? _saidSafe;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('digital_challenge'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    _items ??= (content.visible(
      content.digitalChallenge,
      context.track,
    )..shuffle(math.Random())).take(10).toList();
    final items = _items!;
    final c = context.c;
    return _Rounds(
      title: context.t('lab.digital_challenge.title'),
      index: _i,
      total: items.length,
      score: _score,
      sensitive: true,
      onRestart: () => setState(() {
        _items = null;
        _i = 0;
        _score = 0;
        _saidSafe = null;
      }),
      round: () {
        final d = items[_i];
        final answered = _saidSafe != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: c.primarySoft,
                  child: Icon(
                    Icons.person_rounded,
                    color: context.isDark ? Colors.white : c.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.lx(d.from),
                    style: context.tx.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  topLeft: Radius.circular(6),
                ),
              ),
              child: Text(
                context.lx(d.message),
                style: context.tx.titleLarge?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 18),
            if (!answered)
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      key: const Key('digital-safe'),
                      label: context.t('digital.safe'),
                      icon: Icons.check_rounded,
                      color: c.success,
                      foreground: Colors.white,
                      onPressed: () => setState(() {
                        _saidSafe = true;
                        if (d.safe) _score++;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      key: const Key('digital-unsafe'),
                      label: context.t('digital.unsafe'),
                      icon: Icons.report_problem_rounded,
                      color: c.danger,
                      foreground: Colors.white,
                      onPressed: () => setState(() {
                        _saidSafe = false;
                        if (!d.safe) _score++;
                      }),
                    ),
                  ),
                ],
              )
            else ...[
              InfoBanner(
                key: const Key('digital-verdict'),
                icon: d.safe
                    ? Icons.verified_user_rounded
                    : Icons.report_problem_rounded,
                color: d.safe ? c.success : c.danger,
                title:
                    '${context.t(_saidSafe == d.safe ? 'quiz.correct' : 'quiz.notQuite')} · ${context.t(d.safe ? 'digital.isSafe' : 'digital.isUnsafe')}',
                text: context.lx(d.why),
              ),
              const SizedBox(height: 10),
              InfoBanner(
                icon: Icons.shield_rounded,
                title: context.t('digital.action'),
                text: context.lx(d.action),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                key: const Key('game-next'),
                label: context.t('common.next'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => setState(() {
                  _i++;
                  _saidSafe = null;
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ───────────────────────── STI Knowledge Challenge ─────────────────────────

class StiMatchScreen extends ConsumerStatefulWidget {
  const StiMatchScreen({super.key});

  @override
  ConsumerState<StiMatchScreen> createState() => _StiMatchScreenState();
}

class _StiMatchScreenState extends ConsumerState<StiMatchScreen> {
  List<StiInfo>? _order;
  List<List<StiInfo>> _options = [];
  int _i = 0;
  int _score = 0;
  String? _pick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('sti_match'),
    );
  }

  void _deal(List<StiInfo> all) {
    final rnd = math.Random();
    _order = [...all]..shuffle(rnd);
    _options = [
      for (final s in _order!)
        ([
          s,
          ...([...all.where((x) => x.id != s.id)]..shuffle(rnd)).take(3),
        ]..shuffle(rnd)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    if (context.track.index < Track.c.index || content.stiMatch.length < 4) {
      return const NotAvailableScreen();
    }
    if (_order == null) _deal(content.stiMatch);
    final order = _order!;
    final c = context.c;
    return _Rounds(
      title: context.t('lab.sti_match.title'),
      index: _i,
      total: order.length,
      score: _score,
      onRestart: () => setState(() {
        _order = null;
        _i = 0;
        _score = 0;
        _pick = null;
      }),
      round: () {
        final s = order[_i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.t('sti.prompt'),
              style: context.tx.labelLarge?.copyWith(color: c.inkSoft),
            ),
            const SizedBox(height: 10),
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A3B4), Color(0xFF5BC9D4)],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill(
                    context.lx(s.type),
                    color: Colors.white,
                    foreground: Palette.dark,
                    icon: Icons.biotech_rounded,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.lx(s.clue),
                    style: context.tx.titleLarge?.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final o in _options[_i])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Tap(
                  key: Key('sti-${o.id}'),
                  onTap: _pick != null
                      ? null
                      : () => setState(() {
                          _pick = o.id;
                          if (o.id == s.id) _score++;
                        }),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _pick != null && o.id == s.id
                          ? c.success.withValues(alpha: 0.14)
                          : c.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _pick == null
                            ? c.outline
                            : (o.id == s.id
                                  ? c.success
                                  : (o.id == _pick ? c.danger : c.outline)),
                        width: _pick != null && (o.id == s.id || o.id == _pick)
                            ? 2.2
                            : 1.4,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.lx(o.name),
                            style: context.tx.titleMedium,
                          ),
                        ),
                        if (_pick != null && o.id == s.id)
                          Icon(Icons.check_circle_rounded, color: c.success),
                        if (_pick == o.id && o.id != s.id)
                          Icon(Icons.cancel_rounded, color: c.danger),
                      ],
                    ),
                  ),
                ),
              ),
            if (_pick != null) ...[
              AppCard(
                key: const Key('sti-info'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.lx(s.name), style: context.tx.headlineSmall),
                    const SizedBox(height: 10),
                    for (final (icon, key, text) in [
                      (Icons.shield_rounded, 'sti.prevention', s.prevention),
                      (Icons.science_rounded, 'sti.testing', s.testing),
                      (Icons.fact_check_rounded, 'sti.myth', s.myth),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, size: 20, color: c.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.t(key),
                                    style: context.tx.labelMedium?.copyWith(
                                      color: c.inkSoft,
                                    ),
                                  ),
                                  Text(
                                    context.lx(text),
                                    style: context.tx.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const ReviewNote(),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                key: const Key('game-next'),
                label: context.t('common.next'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => setState(() {
                  _i++;
                  _pick = null;
                }),
              ),
            ],
          ],
        );
      },
    );
  }
}

// ───────────────────────── Build Your Support Circle ─────────────────────────

const _kindIcons = <String, IconData>{
  'person': Icons.person_rounded,
  'school': Icons.school_rounded,
  'health': Icons.local_hospital_rounded,
  'emergency': Icons.sos_rounded,
  'online': Icons.language_rounded,
};

class SupportCircleScreen extends ConsumerStatefulWidget {
  const SupportCircleScreen({super.key});

  @override
  ConsumerState<SupportCircleScreen> createState() =>
      _SupportCircleScreenState();
}

class _SupportCircleScreenState extends ConsumerState<SupportCircleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('support_circle'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final items = content.visible(content.supportCircle, context.track);
    final chosen = [
      for (final s in items)
        if (progress.support.contains(s.id)) s,
    ];
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.support_circle.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(lab: 'support_circle', scene: 'circle', domain: 'd17'),
          Text(context.t('support.intro'), style: context.tx.headlineSmall),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: 1,
                child: Semantics(
                  label: context.t('support.count', {'n': chosen.length}),
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final size = box.maxWidth;
                      final r = size * 0.36;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CirclePainter(
                                chosen.length,
                                c.primary,
                                c.primarySoft,
                              ),
                            ),
                          ),
                          Center(
                            child: Mascot(
                              size: size * 0.26,
                              mood: chosen.isEmpty ? Mood.curious : Mood.happy,
                            ),
                          ),
                          for (var i = 0; i < chosen.length; i++)
                            Positioned(
                              left:
                                  size / 2 +
                                  math.cos(
                                        -math.pi / 2 +
                                            i * 2 * math.pi / chosen.length,
                                      ) *
                                      r -
                                  24,
                              top:
                                  size / 2 +
                                  math.sin(
                                        -math.pi / 2 +
                                            i * 2 * math.pi / chosen.length,
                                      ) *
                                      r -
                                  24,
                              child: ExcludeSemantics(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: c.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: c.surface,
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    _kindIcons[chosen[i].kind] ??
                                        Icons.person_rounded,
                                    color: c.onPrimary,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              context.t('support.count', {'n': chosen.length}),
              key: const Key('support-count'),
              style: context.tx.titleMedium,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.t('support.private'),
            style: context.tx.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          for (final s in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                key: Key('support-${s.id}'),
                onTap: () =>
                    ref.read(progressProvider.notifier).toggleSupport(s.id),
                color: progress.support.contains(s.id) ? c.primarySoft : null,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _kindIcons[s.kind] ?? Icons.person_rounded,
                      color: context.isDark ? Colors.white : c.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.lx(s.title),
                            style: context.tx.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.lx(s.desc),
                            style: context.tx.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.lx(s.examples),
                            style: context.tx.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      selected: progress.support.contains(s.id),
                      child: Icon(
                        progress.support.contains(s.id)
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                        color: progress.support.contains(s.id)
                            ? c.success
                            : c.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          SoftButton(
            label: context.t('safety.title'),
            icon: Icons.health_and_safety_rounded,
            onPressed: () => context.push('/safety'),
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final int n;
  final Color color;
  final Color soft;
  _CirclePainter(this.n, this.color, this.soft);

  @override
  void paint(Canvas canvas, Size size) {
    final o = size.center(Offset.zero);
    final r = size.width * 0.36;
    canvas.drawCircle(o, r + 34, Paint()..color = soft.withValues(alpha: 0.35));
    canvas.drawCircle(
      o,
      r,
      Paint()
        ..color = soft
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / n;
      canvas.drawLine(
        o,
        o + Offset(math.cos(a), math.sin(a)) * r,
        Paint()
          ..color = color.withValues(alpha: 0.45)
          ..strokeWidth = 2.5,
      );
    }
  }

  @override
  bool shouldRepaint(_CirclePainter o) => o.n != n || o.color != color;
}
