import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../filters/topic_filter_bar.dart';
import 'quiz_runner.dart';

/// Picks the questions for a quiz. `kind` is `domain`, `lesson` or `final`.
List<QuizQ> buildQuiz(
  ContentRepository content,
  Track track, {
  required String kind,
  required String id,
  Set<String> completed = const {},
  int max = 10,
  Random? random,
  TopicFilter filter = TopicFilter.all,
}) {
  final rnd = random ?? Random();
  List<QuizQ> pool;
  switch (kind) {
    case 'lesson':
      final l = content.lesson(id);
      pool = (l != null && l.visibleTo(track))
          ? l.quiz.where((q) => q.isValid).toList()
          : [];
      return pool;
    case 'domain':
      pool = content.quizFor(track, domain: id, filter: filter);
    default:
      // Final challenge: questions from completed lessons; if the learner has
      // finished fewer than three lessons, draw from everything on the track.
      // The topic filter, when on, narrows both pools.
      final done = content.quizFor(track, lessonIds: completed, filter: filter);
      pool = done.length >= 6 ? done : content.quizFor(track, filter: filter);
  }
  pool = [...pool]..shuffle(rnd);
  return pool.take(max).toList();
}

class QuizHubScreen extends ConsumerWidget {
  const QuizHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final c = context.c;
    final topics = ref.watch(topicFilterProvider);
    final domains = [
      for (final d in content.domainsFor(track))
        if (content.quizFor(track, domain: d.id, filter: topics).isNotEmpty) d,
    ];
    final finalBest = progress.quizBest['final'];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.quiz.title'))),
      body: PageBody(
        children: [
          Text(
            context.t('quizhub.sub'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          if (topics.isActive) ...[
            const SizedBox(height: 10),
            FilterResultLine(
              count: content.quizFor(track, filter: topics).length,
              noun: 'quiz',
            ),
          ],
          const SizedBox(height: 16),
          AppCard(
            key: const Key('quiz-final'),
            gradient: const LinearGradient(
              colors: [Palette.dark, Palette.purple],
            ),
            onTap: () => context.push('/quiz/final/all'),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('lab.final.title'),
                        style: context.tx.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        finalBest == null
                            ? context.t('lab.final.sub')
                            : context.t('quiz.best', {'pct': finalBest}),
                        style: context.tx.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(context.t('quizhub.byTopic'), style: context.tx.headlineSmall),
          const SizedBox(height: 12),
          for (final d in domains)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                key: Key('quiz-domain-${d.id}'),
                onTap: () => context.push('/quiz/domain/${d.id}'),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    DomainArt(d.id, size: 48, radius: 16),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.lx(d.titleFor(context.track)),
                            style: context.tx.titleMedium,
                          ),
                          Text(
                            context.t('quizhub.count', {
                              'n': content
                                  .quizFor(track, domain: d.id, filter: topics)
                                  .length,
                            }),
                            style: context.tx.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (progress.quizBest['domain:${d.id}'] != null)
                      Pill(
                        context.t('quiz.best', {
                          'pct': progress.quizBest['domain:${d.id}']!,
                        }),
                        icon: Icons.emoji_events_rounded,
                      )
                    else
                      Icon(Icons.chevron_right_rounded, color: c.inkSoft),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuizScreen extends ConsumerStatefulWidget {
  final String kind;
  final String id;
  const QuizScreen({super.key, required this.kind, required this.id});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<QuizQ>? _questions;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    _questions ??= buildQuiz(
      content,
      track,
      kind: widget.kind,
      id: widget.id,
      completed: ref.read(progressProvider).completedIds,
      filter: ref.read(topicFilterProvider),
    );
    final domain = widget.kind == 'domain' ? content.domain(widget.id) : null;
    final title = widget.kind == 'final'
        ? context.t('lab.final.title')
        : (domain != null
              ? context.lx(domain.titleFor(context.track))
              : context.t('lab.quiz.title'));
    final key = widget.kind == 'final'
        ? 'final'
        : '${widget.kind}:${widget.id}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageBody(
        children: [
          if (_questions!.isEmpty && ref.watch(topicFilterProvider).isActive)
            FilterEmptyState(alsoClear: () => setState(() => _questions = null))
          else
            QuizRunner(
              questions: _questions!,
              celebrate: !(domain?.sensitive ?? false),
              onFinished: (correct, total) => ref
                  .read(progressProvider.notifier)
                  .recordQuiz(key, correct, total),
              onDone: () => context.pop(),
            ),
        ],
      ),
    );
  }
}
