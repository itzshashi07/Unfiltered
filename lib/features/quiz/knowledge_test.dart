import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/knowledge.dart';
import '../../data/models.dart';
import '../../ui/widgets.dart';
import 'quiz_runner.dart';

/// Test Your Knowledge hub: daily challenge, mega test, one test per topic.
class KnowledgeHubScreen extends ConsumerWidget {
  const KnowledgeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAsync = ref.watch(knowledgeProvider);
    final scores = ref.watch(kScoresProvider);
    final track = context.track;
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('kt.title'))),
      body: bankAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          title: context.t('quiz.empty'),
          body: context.t('quiz.empty.body'),
        ),
        data: (bank) {
          final cats = bank.catsFor(track);
          final today = scores.daily[istDay()];
          return PageBody(
            children: [
              Text(
                context.t('kt.dek', {'n': bank.rounded}),
                style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
              ),
              const SizedBox(height: 16),
              _BigCard(
                key: const Key('kt-daily'),
                colors: const [Color(0xFF3A2A05), Color(0xFFB7791F)],
                icon: Icons.today_rounded,
                title: context.t('kt.daily.no', {'n': dailyNumber()}),
                body: today == null
                    ? context.t('kt.daily.dek')
                    : context.t('kt.doneToday', {'s': today[0], 'n': today[1]}),
                badge: scores.dayStreak > 1
                    ? '🔥 ${context.t('kt.dayStreak', {'n': scores.dayStreak})}'
                    : null,
                onTap: () => context.push('/test/daily'),
              ),
              const SizedBox(height: 12),
              _BigCard(
                key: const Key('kt-mega'),
                colors: const [Palette.dark, Color(0xFFB3123A)],
                icon: Icons.emoji_events_rounded,
                title: context.t('kt.mega'),
                body: context.t('kt.mega.dek'),
                badge: scores.best['mega'] == null
                    ? null
                    : context.t('kt.best', {
                        's': scores.best['mega']![0],
                        'n': scores.best['mega']![1],
                      }),
                onTap: () => context.push('/test/mega'),
              ),
              const SizedBox(height: 22),
              Text(context.t('kt.byTopic'), style: context.tx.headlineSmall),
              const SizedBox(height: 10),
              for (final cat in cats)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    key: Key('kt-cat-${cat.key}'),
                    onTap: () => context.push('/test/${cat.key}'),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: cat.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(cat.icon, color: cat.color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.lx(cat.title),
                                style: context.tx.titleMedium,
                              ),
                              Text(
                                scores.best[cat.key] == null
                                    ? context.t('quizhub.count', {
                                        'n': bank
                                            .pool(track, cat: cat.key)
                                            .length,
                                      })
                                    : context.t('kt.best', {
                                        's': scores.best[cat.key]![0],
                                        'n': scores.best[cat.key]![1],
                                      }),
                                style: context.tx.bodySmall?.copyWith(
                                  color: c.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: c.inkSoft),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              InfoBanner(
                icon: Icons.lock_rounded,
                text: context.t('kt.private'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Entry card for Test Your Knowledge (labs tab, quiz hub, home).
class KnowledgeTestCard extends ConsumerWidget {
  const KnowledgeTestCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(knowledgeProvider).value?.rounded ?? 0;
    if (n == 0) return const SizedBox.shrink();
    return _BigCard(
      key: const Key('kt-entry'),
      colors: const [Color(0xFF0B3D2E), Color(0xFF1FA67A)],
      icon: Icons.emoji_events_rounded,
      title: context.t('kt.cta.title'),
      body: context.t('kt.cta.dek', {'n': n}),
      badge: context.t('kt.kicker'),
      onTap: () => context.push('/test'),
    );
  }
}

class _BigCard extends StatelessWidget {
  final List<Color> colors;
  final IconData icon;
  final String title;
  final String body;
  final String? badge;
  final VoidCallback onTap;
  const _BigCard({
    super.key,
    required this.colors,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: false,
    onTap: onTap,
    child: Row(
      children: [
        Icon(icon, color: Colors.white, size: 38),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.tx.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: context.tx.bodySmall?.copyWith(color: Colors.white),
              ),
              if (badge != null) ...[
                const SizedBox(height: 6),
                Pill(
                  badge!,
                  color: Colors.white.withValues(alpha: 0.18),
                  foreground: Colors.white,
                ),
              ],
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_rounded, color: Colors.white),
      ],
    ),
  );
}

/// Result handed to the poster screen.
class KResult {
  final String testKey; // topic key, 'daily' or 'mega'
  final String topic;
  final Color accent;
  final int score;
  final int total;
  const KResult(this.testKey, this.topic, this.accent, this.score, this.total);
}

/// Runs one test: `mode` is `daily`, `mega` or a topic key.
class KnowledgeTestScreen extends ConsumerStatefulWidget {
  final String mode;
  const KnowledgeTestScreen({super.key, required this.mode});

  @override
  ConsumerState<KnowledgeTestScreen> createState() =>
      _KnowledgeTestScreenState();
}

class _KnowledgeTestScreenState extends ConsumerState<KnowledgeTestScreen> {
  List<QuizQ>? _qs;
  List<int> _latest = const [0, 0];
  int _length = 10;
  int _round = 0;

  KMode get _kmode => switch (widget.mode) {
    'daily' => KMode.daily,
    'mega' => KMode.mega,
    _ => KMode.topic,
  };

  void _start(KnowledgeBank bank) {
    final scores = ref.read(kScoresProvider);
    setState(() {
      _round++;
      _qs = buildKnowledgeTest(
        bank,
        context.track,
        mode: _kmode,
        cat: widget.mode,
        length: _length,
        seen: scores.seen.toSet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bankAsync = ref.watch(knowledgeProvider);
    final cat = kCat(widget.mode);
    final title = cat != null
        ? context.lx(cat.title)
        : context.t(_kmode == KMode.daily ? 'kt.daily' : 'kt.mega');
    final topic = cat != null ? context.lx(cat.title) : context.t('kt.mixed');
    final accent =
        cat?.color ??
        (_kmode == KMode.daily ? const Color(0xFFE0A526) : Palette.coral);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: bankAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => EmptyState(
          title: context.t('quiz.empty'),
          body: context.t('quiz.empty.body'),
        ),
        data: (bank) {
          final qs = _qs;
          if (qs == null) return _intro(context, bank, cat, accent);
          if (qs.length < 3) {
            return EmptyState(
              title: context.t('kt.noneForAge'),
              body: context.t('kt.noneForAge.body'),
            );
          }
          return PageBody(
            children: [
              QuizRunner(
                key: ValueKey('kt-run-$_round'),
                questions: qs,
                onFinished: (s, n) {
                  _latest = [s, n];
                  ref.read(kScoresProvider.notifier).record(widget.mode, s, n, [
                    for (final q in qs) q.id,
                  ], daily: _kmode == KMode.daily);
                },
                doneLabel: context.t('kt.makePoster'),
                onDone: () => context.push(
                  '/test/poster',
                  extra: KResult(
                    widget.mode,
                    topic,
                    accent,
                    _latest[0],
                    _latest[1],
                  ),
                ),
              ),
              if (_kmode != KMode.daily) ...[
                const SizedBox(height: 12),
                SoftButton(
                  label: context.t('kt.newSet'),
                  icon: Icons.shuffle_rounded,
                  onPressed: () => _start(bank),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _intro(
    BuildContext context,
    KnowledgeBank bank,
    KCat? cat,
    Color accent,
  ) {
    final c = context.c;
    final scores = ref.watch(kScoresProvider);
    final today = scores.daily[istDay()];
    return PageBody(
      children: [
        if (cat != null) ...[
          Text(
            context.lx(cat.dek),
            style: context.tx.bodyLarge?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 18),
          Text(context.t('kt.length'), style: context.tx.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final n in const [10, 20, 30])
                ChoiceChip(
                  key: Key('kt-len-$n'),
                  label: Text('$n'),
                  selected: _length == n,
                  onSelected: (_) => setState(() => _length = n),
                ),
            ],
          ),
        ] else
          Text(
            context.t(_kmode == KMode.daily ? 'kt.daily.dek' : 'kt.mega.dek'),
            style: context.tx.bodyLarge?.copyWith(color: c.inkSoft),
          ),
        if (_kmode == KMode.daily && today != null) ...[
          const SizedBox(height: 12),
          Text(
            context.t('kt.doneToday', {'s': today[0], 'n': today[1]}),
            style: context.tx.bodyMedium,
          ),
        ],
        const SizedBox(height: 22),
        PrimaryButton(
          key: const Key('kt-start'),
          label: context.t('kt.start'),
          icon: Icons.arrow_forward_rounded,
          color: accent,
          foreground: Colors.white,
          onPressed: () => _start(bank),
        ),
      ],
    );
  }
}

// ── poster ───────────────────────────────────────────────────────────────

String _rankKey(double pct) => pct >= 0.9
    ? 'kt.rank.4'
    : pct >= 0.7
    ? 'kt.rank.3'
    : pct >= 0.5
    ? 'kt.rank.2'
    : 'kt.rank.1';

/// The challenge link opens the same test on the website, with the score.
String challengeLink(Lang lang, String testKey, String name, int s, int n) {
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({'n': name, 's': s, 't': n})))
      .replaceAll('=', '');
  final seg = lang == Lang.hg ? 'hinglish' : 'en';
  return 'https://theunfiltered.in/$seg/test/$testKey/?ch=$payload';
}

class KnowledgePosterScreen extends ConsumerStatefulWidget {
  final KResult result;
  const KnowledgePosterScreen({super.key, required this.result});

  @override
  ConsumerState<KnowledgePosterScreen> createState() =>
      _KnowledgePosterScreenState();
}

class _KnowledgePosterScreenState extends ConsumerState<KnowledgePosterScreen> {
  final _boundary = GlobalKey();
  late final TextEditingController _name;
  late final TextEditingController _age;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final me = ref.read(kScoresProvider);
    _name = TextEditingController(text: me.name);
    _age = TextEditingController(text: me.age);
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  String get _cleanName =>
      _name.text.replaceAll(RegExp(r'[\u0000-\u001f]'), '').trim();
  String get _cleanAge {
    final a = int.tryParse(_age.text.trim());
    return a != null && a >= 5 && a <= 99 ? '$a' : '';
  }

  Future<Uint8List?> _png() async {
    final b =
        _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (b == null) return null;
    final img = await b.toImage(pixelRatio: 1080 / _PosterCard.w);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = widget.result;
    ref.read(kScoresProvider.notifier).setMe(_cleanName, _cleanAge);
    final pct = (r.score * 100 / r.total).round();
    final link = challengeLink(
      context.lang,
      r.testKey,
      _cleanName,
      r.score,
      r.total,
    );
    final text =
        '${context.t('kt.share.text', {'s': r.score, 'n': r.total, 'p': pct, 'topic': r.topic})} $link';
    try {
      final png = await _png();
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: png == null
              ? null
              : [
                  XFile.fromData(
                    png,
                    mimeType: 'image/png',
                    name: 'unfiltered-score.png',
                  ),
                ],
        ),
      );
    } catch (_) {
      // cancelled or no share target
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    final r = widget.result;
    final link = challengeLink(
      context.lang,
      r.testKey,
      _cleanName,
      r.score,
      r.total,
    );
    await Clipboard.setData(ClipboardData(text: link));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t('kt.share.copied'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final c = context.c;
    final bank = ref.watch(knowledgeProvider).value;
    final pct = r.total == 0 ? 0.0 : r.score / r.total;
    final under18 = _cleanAge.isNotEmpty && int.parse(_cleanAge) < 18;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('kt.share.title'))),
      body: PageBody(
        children: [
          Text(
            context.t('kt.share.dek'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('kt-name'),
                  controller: _name,
                  maxLength: 24,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.t('kt.share.name'),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 92,
                child: TextField(
                  key: const Key('kt-age'),
                  controller: _age,
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: context.t('kt.share.age'),
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '🔒 ${context.t('kt.share.private')}',
            style: context.tx.bodySmall?.copyWith(color: c.inkSoft),
          ),
          if (under18) ...[
            const SizedBox(height: 4),
            Text(
              context.t('kt.share.kids'),
              style: context.tx.bodySmall?.copyWith(color: c.warning),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FittedBox(
                child: RepaintBoundary(
                  key: _boundary,
                  child: _PosterCard(
                    name: _cleanName,
                    age: _cleanAge,
                    score: r.score,
                    total: r.total,
                    pct: pct,
                    topic: r.topic,
                    accent: r.accent,
                    rank: context.t(_rankKey(pct)),
                    total0: bank?.rounded ?? 1200,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const Key('kt-share'),
            label: context.t('kt.share.btn'),
            icon: Icons.share_rounded,
            onPressed: _busy ? null : _share,
          ),
          const SizedBox(height: 10),
          SoftButton(
            label: context.t('kt.share.copy'),
            icon: Icons.link_rounded,
            onPressed: _copy,
          ),
          const SizedBox(height: 10),
          Text(
            context.t('kt.share.hint'),
            style: context.tx.bodySmall?.copyWith(color: c.inkSoft),
          ),
        ],
      ),
    );
  }
}

/// 4:5 score poster, drawn at 360×450 and saved at 1080×1350.
class _PosterCard extends StatelessWidget {
  static const double w = 360;
  static const double h = 450;
  final String name;
  final String age;
  final int score;
  final int total;
  final double pct;
  final String topic;
  final Color accent;
  final String rank;
  final int total0;
  const _PosterCard({
    required this.name,
    required this.age,
    required this.score,
    required this.total,
    required this.pct,
    required this.topic,
    required this.accent,
    required this.rank,
    required this.total0,
  });

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFFF1EDE6);
    const mint = Color(0xFF8FF0C9);
    TextStyle s(
      double size, {
      FontWeight w = FontWeight.w700,
      Color color = ink,
      double? ls,
      FontStyle? st,
    }) => TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: size,
      fontWeight: w,
      color: color,
      letterSpacing: ls,
      fontStyle: st,
      height: 1.1,
    );
    final who = name.isEmpty ? context.t('kt.poster.you') : name;
    final sub = [
      if (age.isNotEmpty) context.t('kt.poster.age', {'a': age}),
      if (name.isNotEmpty) context.t('kt.poster.scored'),
    ].join(' · ');
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
        width: w,
        height: h,
        color: const Color(0xFF0A0A0E),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, -0.95),
              radius: 0.95,
              colors: [
                accent.withValues(alpha: 0.42),
                accent.withValues(alpha: 0),
              ],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.95, 1),
                radius: 0.9,
                colors: [
                  mint.withValues(alpha: 0.14),
                  mint.withValues(alpha: 0),
                ],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UNFILTERED', style: s(19, w: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Container(
                            width: 108,
                            height: 3,
                            decoration: BoxDecoration(
                              color: mint,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.t('kt.title').toUpperCase(),
                            style: s(
                              8,
                              w: FontWeight.w800,
                              color: Color.lerp(accent, Colors.white, 0.35)!,
                              ls: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'THEUNFILTERED.IN',
                            style: s(
                              7,
                              w: FontWeight.w600,
                              color: ink.withValues(alpha: 0.6),
                              ls: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      border: Border.all(color: accent.withValues(alpha: 0.7)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      topic,
                      style: s(10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    child: Text(who, style: s(30, w: FontWeight.w800)),
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      style: s(
                        11,
                        w: FontWeight.w600,
                        color: ink.withValues(alpha: 0.72),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 136,
                    height: 136,
                    child: CustomPaint(
                      painter: _RingPainter(pct, accent),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$score/$total',
                              style: s(42, w: FontWeight.w800),
                            ),
                            Text(
                              '${(pct * 100).round()}%',
                              style: s(14, w: FontWeight.w800, color: accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: mint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '★  ${rank.toUpperCase()}',
                      style: s(
                        11,
                        w: FontWeight.w800,
                        color: const Color(0xFF06130D),
                        ls: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.t('kt.poster.beat'),
                    style: s(19, w: FontWeight.w700, st: FontStyle.italic),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${context.t('kt.poster.cta')} →',
                                style: s(9, color: const Color(0xFF16130F)),
                              ),
                              Text(
                                'theunfiltered.in/test',
                                style: s(
                                  14,
                                  w: FontWeight.w800,
                                  color: const Color(0xFF16130F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          context
                              .t('kt.poster.facts', {'n': total0})
                              .replaceAll(' · ', '\n'),
                          textAlign: TextAlign.right,
                          style: s(
                            7,
                            w: FontWeight.w600,
                            color: const Color(0xB316130F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'REAL TALK · REAL SCIENCE · ZERO SHAME',
                    style: s(
                      7,
                      w: FontWeight.w600,
                      color: ink.withValues(alpha: 0.6),
                      ls: 1,
                    ),
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

class _RingPainter extends CustomPainter {
  final double pct;
  final Color color;
  _RingPainter(this.pct, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      r,
      0,
      math.pi * 2,
      false,
      p..color = Colors.white.withValues(alpha: 0.1),
    );
    canvas.drawArc(
      r,
      -math.pi / 2,
      math.pi * 2 * math.max(0.002, pct),
      false,
      p..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.pct != pct || old.color != color;
}
