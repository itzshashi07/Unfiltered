import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../filters/topic_filter_bar.dart';

/// "Myth or Science": judge a claim, then the card flips to the evidence.
class MythBusterScreen extends ConsumerStatefulWidget {
  final String? domain;
  const MythBusterScreen({super.key, this.domain});

  @override
  ConsumerState<MythBusterScreen> createState() => _MythBusterScreenState();
}

class _MythBusterScreenState extends ConsumerState<MythBusterScreen> {
  List<MythCard>? _deck;
  TopicFilter _deckTopics = TopicFilter.all;
  int _i = 0;
  bool? _guessMyth; // null = not answered yet
  int _right = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('myth_buster'),
    );
  }

  void _guess(MythCard m, bool saysMyth) {
    if (_guessMyth != null) return;
    final correct = saysMyth == (m.verdict == Verdict.myth);
    setState(() {
      _guessMyth = saysMyth;
      if (correct) _right++;
    });
    ref.read(progressProvider.notifier).seeMyth(m.id);
  }

  void _next() => setState(() {
    _i++;
    _guessMyth = null;
  });

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final c = context.c;
    final topics = ref.watch(topicFilterProvider);
    if (_deck == null || _deckTopics != topics) {
      // A new topic selection deals a fresh deck (always inside the age track).
      _deckTopics = topics;
      _i = 0;
      _right = 0;
      _guessMyth = null;
      final seen = ref.read(progressProvider).mythsSeen;
      final all = content.mythsFor(track, domain: widget.domain, filter: topics)
        ..shuffle(math.Random());
      // Unseen cards first so the deck always feels fresh.
      _deck = [
        ...all.where((m) => !seen.contains(m.id)),
        ...all.where((m) => seen.contains(m.id)),
      ];
    }
    final deck = _deck!;
    final finished = _i >= deck.length;
    final domain = widget.domain == null
        ? null
        : content.domain(widget.domain!);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          domain == null
              ? context.t('lab.myth_buster.title')
              : context.lx(domain.titleFor(context.track)),
        ),
      ),
      body: PageBody(
        children: [
          Semantics(
            header: true,
            child: Text(
              context.t('myth.dark'),
              style: context.tx.headlineSmall,
            ),
          ),
          const SizedBox(height: 10),
          const TopicFilterBar(),
          const SizedBox(height: 8),
          if (topics.isActive && deck.isNotEmpty)
            FilterResultLine(count: deck.length, noun: 'myths'),
          if (deck.isEmpty && topics.isActive)
            const FilterEmptyState()
          else if (deck.isEmpty)
            EmptyState(
              title: context.t('myth.empty'),
              body: context.t('myth.empty.body'),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.t('myth.tagline'),
                    style: context.tx.titleMedium?.copyWith(color: c.inkSoft),
                  ),
                ),
                Pill(
                  '${math.min(_i + 1, deck.length)}/${deck.length}',
                  icon: Icons.style_rounded,
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (finished)
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Mascot(size: 120, mood: Mood.wow),
                  const SizedBox(height: 14),
                  Text(
                    context.t('myth.done', {
                      'right': _right,
                      'total': deck.length,
                    }),
                    style: context.tx.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.t('myth.done.body'),
                    style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: context.t('myth.again'),
                    icon: Icons.refresh_rounded,
                    onPressed: () => setState(() {
                      _deck = [...deck]..shuffle(math.Random());
                      _i = 0;
                      _right = 0;
                      _guessMyth = null;
                    }),
                  ),
                ],
              )
            else ...[
              _FlipCard(
                key: ValueKey(deck[_i].id),
                flipped: _guessMyth != null,
                front: _Front(myth: deck[_i]),
                back: _Back(myth: deck[_i], guessedMyth: _guessMyth ?? true),
              ),
              const SizedBox(height: 16),
              if (_guessMyth == null)
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        key: const Key('myth-say-myth'),
                        label: context.t('verdict.myth'),
                        icon: Icons.close_rounded,
                        color: c.danger,
                        foreground: Colors.white,
                        onPressed: () => _guess(deck[_i], true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        key: const Key('myth-say-fact'),
                        label: context.t('verdict.fact'),
                        icon: Icons.check_rounded,
                        color: c.success,
                        foreground: Colors.white,
                        onPressed: () => _guess(deck[_i], false),
                      ),
                    ),
                  ],
                )
              else ...[
                if (deck[_i].lesson != null &&
                    content.canOpenLesson(deck[_i].lesson!, track))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftButton(
                      label: context.t('common.learnMore'),
                      icon: Icons.menu_book_rounded,
                      onPressed: () =>
                          context.push('/lesson/${deck[_i].lesson}'),
                    ),
                  ),
                PrimaryButton(
                  key: const Key('myth-next'),
                  label: context.t(
                    _i < deck.length - 1 ? 'myth.next' : 'quiz.finish',
                  ),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final bool flipped;
  final Widget front;
  final Widget back;
  const _FlipCard({
    super.key,
    required this.flipped,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return flipped ? back : front;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: flipped ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      builder: (_, v, _) {
        final showBack = v > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(math.pi * v),
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

class _Front extends StatelessWidget {
  final MythCard myth;
  const _Front({required this.myth});

  @override
  Widget build(BuildContext context) {
    final st = DomainStyle.of(myth.domain);
    return Container(
      key: const Key('myth-front'),
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [st.a, Color.lerp(st.a, st.b, 0.7)!],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SceneArt.forTopic(
            myth.domain,
            myth.tracks,
            seed: myth.id.hashCode,
            height: 110,
          ),
          const SizedBox(height: 6),
          Icon(
            Icons.format_quote_rounded,
            color: Colors.white.withValues(alpha: 0.7),
            size: 40,
          ),
          const SizedBox(height: 6),
          Text(
            context.lx(myth.claim),
            style: context.tx.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 22),
          Text(
            context.t('myth.ask'),
            style: context.tx.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Back extends ConsumerWidget {
  final MythCard myth;
  final bool guessedMyth;
  const _Back({required this.myth, required this.guessedMyth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final c = context.c;
    final right = guessedMyth == (myth.verdict == Verdict.myth);
    final vColor = switch (myth.verdict) {
      Verdict.myth => c.danger,
      Verdict.fact => c.success,
      Verdict.partly => c.warning,
    };
    final refs = [
      for (final r in myth.refs)
        if (content.ref(r) != null) content.ref(r)!,
    ];
    return Container(
      key: const Key('myth-back'),
      constraints: const BoxConstraints(minHeight: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: vColor, width: 2.4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Pill(
                      context.t('verdict.${myth.verdict.name}'),
                      key: const Key('myth-verdict'),
                      icon: switch (myth.verdict) {
                        Verdict.myth => Icons.close_rounded,
                        Verdict.fact => Icons.check_rounded,
                        Verdict.partly => Icons.contrast_rounded,
                      },
                      color: vColor,
                      foreground: context.isDark ? Palette.dark : Colors.white,
                    ),
                    Pill(
                      context.t(right ? 'myth.youRight' : 'myth.youWrong'),
                      icon: right
                          ? Icons.thumb_up_alt_rounded
                          : Icons.lightbulb_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              VerdictStamp(verdict: myth.verdict, color: vColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '“${context.lx(myth.claim)}”',
            style: context.tx.titleMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 12),
          Text(context.t('myth.science'), style: context.tx.labelMedium),
          const SizedBox(height: 4),
          Text(context.lx(myth.fact), style: context.tx.bodyLarge),
          const SizedBox(height: 14),
          Text(context.t('myth.why'), style: context.tx.labelMedium),
          const SizedBox(height: 4),
          Text(context.lx(myth.why), style: context.tx.bodyMedium),
          const SizedBox(height: 14),
          Text(context.t('common.sources'), style: context.tx.labelMedium),
          const SizedBox(height: 8),
          SourceList(refs),
          const ReviewNote(),
        ],
      ),
    );
  }
}

/// A rubber stamp that thumps onto the card when the answer is revealed.
class VerdictStamp extends StatelessWidget {
  final Verdict verdict;
  final Color color;
  final double size;
  const VerdictStamp({
    super.key,
    required this.verdict,
    required this.color,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    final stamp = Transform.rotate(
      angle: -0.2,
      child: Container(
        key: const Key('verdict-stamp'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3.5),
          color: color.withValues(alpha: 0.08),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (verdict) {
                Verdict.myth => Icons.close_rounded,
                Verdict.fact => Icons.check_rounded,
                Verdict.partly => Icons.contrast_rounded,
              },
              color: color,
              size: size * 0.38,
            ),
            Text(
              context.t('verdict.${verdict.name}').toUpperCase(),
              textScaler: TextScaler.noScaling,
              maxLines: 1,
              style: context.tx.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.13,
              ),
            ),
          ],
        ),
      ),
    );
    if (context.reducedMotion) return ExcludeSemantics(child: stamp);
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 700),
        curve: Curves.elasticOut,
        builder: (_, v, child) => Opacity(
          opacity: v.clamp(0, 1),
          child: Transform.scale(scale: 2.2 - 1.2 * v, child: child),
        ),
        child: stamp,
      ),
    );
  }
}
