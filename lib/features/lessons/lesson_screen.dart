import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../home/cards.dart';
import '../labs/visual_explainers.dart';
import 'lesson_visual.dart';
import '../quiz/quiz_runner.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String id;
  const LessonScreen(this.id, {super.key});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final _scroll = ScrollController();
  final _read = ValueNotifier<double>(0);
  bool _quizDone = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final max = _scroll.position.maxScrollExtent;
      _read.value = max <= 0 ? 1 : (_scroll.offset / max).clamp(0.0, 1.0);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final content = ref.read(contentProvider);
      if (content.canOpenLesson(widget.id, context.track)) {
        ref.read(progressProvider.notifier).openLesson(widget.id);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _read.dispose();
    super.dispose();
  }

  void _complete(Lesson l) {
    ref.read(progressProvider.notifier).completeLesson(l.id);
    final content = ref.read(contentProvider);
    final track = context.track;
    final done = {...ref.read(progressProvider).completedIds, l.id};
    final sameDomain = content
        .lessonsFor(track, domain: l.domain)
        .where((x) => !done.contains(x.id))
        .toList();
    final next = sameDomain.isNotEmpty
        ? sameDomain.first
        : content
              .recommended(track, done)
              .cast<Lesson?>()
              .firstWhere((_) => true, orElse: () => null);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _DoneSheet(lesson: l, next: next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final l = content.lesson(widget.id);
    // Age-track gate: a lesson that is not part of this track never renders.
    if (l == null || !l.visibleTo(track)) return const NotAvailableScreen();
    final c = context.c;
    final st = DomainStyle.of(l.domain);
    final domain = content.domain(l.domain);
    final done = progress.completed.containsKey(l.id);
    final marked = progress.bookmarks.contains(l.id);
    final refs = [
      for (final r in l.refs)
        if (content.ref(r) != null) content.ref(r)!,
    ];
    final pending = [
      for (final p in l.prereqs)
        if (!progress.completed.containsKey(p) &&
            content.canOpenLesson(p, track))
          content.lesson(p)!,
    ];
    // Picture, at-a-glance visual: both optional, both gated by the age track.
    final picture = content.imageForLesson(l, track);
    final visual = content.visualFor(l.id);
    final lab =
        l.interactive != null &&
            (l.interactive == 'ask' ||
                content.labsFor(track).contains(l.interactive))
        ? l.interactive
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.lx(domain?.titleFor(context.track) ?? L.empty),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            key: const Key('lesson-bookmark'),
            tooltip: context.t(
              marked ? 'lesson.unbookmark' : 'lesson.bookmark',
            ),
            onPressed: () =>
                ref.read(progressProvider.notifier).toggleBookmark(l.id),
            icon: Icon(
              marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: ValueListenableBuilder<double>(
            valueListenable: _read,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 4,
              color: st.a,
              backgroundColor: c.surfaceAlt,
              semanticsLabel: context.t('lesson.readProgress'),
            ),
          ),
        ),
      ),
      body: PageBody(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [st.a, Color.lerp(st.a, st.b, 0.7)!],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (picture != null)
                  ContentPicture(
                    image: picture,
                    radius: 20,
                    captionColor: Colors.white,
                  )
                else
                  SceneArt.forLesson(l, height: 150),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(st.icon, color: Colors.white, size: 34),
                    const Spacer(),
                    if (done)
                      Pill(
                        context.t('lesson.done'),
                        icon: Icons.check_rounded,
                        color: Colors.white,
                        foreground: Palette.dark,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  child: Text(
                    context.lx(l.title),
                    style: context.tx.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.lx(l.subtitle),
                  style: context.tx.bodyLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Pill(
                      lessonMeta(context, l),
                      icon: Icons.schedule_rounded,
                      color: Colors.white24,
                      foreground: Colors.white,
                    ),
                    Pill(
                      '${context.t('common.ages')} ${l.tracks.first.ages}${l.tracks.length > 1 ? '+' : ''}',
                      color: Colors.white24,
                      foreground: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // ── Hook
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Mascot(size: 56, mood: l.sensitive ? Mood.calm : Mood.curious),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(22),
                      topLeft: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    context.lx(l.hook),
                    style: context.tx.titleMedium?.copyWith(height: 1.45),
                  ),
                ),
              ),
            ],
          ),
          if (l.warning != null) ...[
            const SizedBox(height: 16),
            InfoBanner(
              icon: Icons.medical_information_rounded,
              color: c.danger,
              title: context.t('lesson.warning'),
              text: context.lx(l.warning!),
            ),
          ],
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            InfoBanner(
              icon: Icons.low_priority_rounded,
              text:
                  '${context.t('lesson.prereq')} ${pending.map((p) => context.lx(p.title)).join(' · ')}',
            ),
          ],
          if (LegalBox.appliesTo(l)) ...[
            const SizedBox(height: 16),
            LegalBox(lesson: l),
          ],
          // ── Objectives
          const SizedBox(height: 22),
          Text(context.t('lesson.objectives'), style: context.tx.titleLarge),
          const SizedBox(height: 10),
          for (final o in l.objectives)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.adjust_rounded, size: 18, color: st.a),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(context.lx(o), style: context.tx.bodyLarge),
                  ),
                ],
              ),
            ),
          // ── At a glance
          if (visual != null) ...[
            const SizedBox(height: 16),
            LessonVisualCard(visual: visual, domain: l.domain),
          ],
          // ── Sections
          for (var i = 0; i < l.sections.length; i++) ...[
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: st.a,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(
                    '${i + 1}',
                    textScaler: TextScaler.noScaling,
                    style: context.tx.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      context.lx(l.sections[i].h),
                      style: context.tx.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(context.lx(l.sections[i].body), style: context.tx.bodyLarge),
          ],
          // ── Visual explainers for specific lessons
          if (kPeriodProductLessons.contains(l.id)) ...[
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.t('visual.products'),
                    style: context.tx.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const PeriodProducts(),
                ],
              ),
            ),
          ],
          if (kFertilizationLessons.contains(l.id) &&
              track.index >= Track.c.index) ...[
            const SizedBox(height: 24),
            const FertilizationJourney(),
          ],
          // ── Interactive lab
          if (lab != null) ...[
            const SizedBox(height: 24),
            Text(context.t('lesson.tryIt'), style: context.tx.titleLarge),
            const SizedBox(height: 10),
            lab == 'ask'
                ? SoftButton(
                    label: context.t('ask.title'),
                    icon: Icons.forum_rounded,
                    onPressed: () => context.go(labRoute('ask')),
                  )
                : LabCard(
                    labKey: lab,
                    wide: true,
                    onTap: () => context.push(labRoute(lab)),
                  ),
          ],
          // ── Myth vs fact
          const SizedBox(height: 24),
          AppCard(
            color: c.coral.withValues(alpha: context.isDark ? 0.16 : 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(
                  context.t('verdict.myth'),
                  icon: Icons.close_rounded,
                  color: c.danger,
                  foreground: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  '“${context.lx(l.mythClaim)}”',
                  style: context.tx.titleMedium,
                ),
                const SizedBox(height: 14),
                Pill(
                  context.t('verdict.fact'),
                  icon: Icons.check_rounded,
                  color: c.success,
                  foreground: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(context.lx(l.mythFact), style: context.tx.bodyLarge),
              ],
            ),
          ),
          // ── Takeaways
          const SizedBox(height: 24),
          Text(context.t('lesson.takeaways'), style: context.tx.titleLarge),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                for (final t in l.takeaways)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 20,
                          color: c.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            context.lx(t),
                            style: context.tx.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // ── Activity
          const SizedBox(height: 16),
          AppCard(
            color: c.mint.withValues(alpha: context.isDark ? 0.14 : 0.35),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.self_improvement_rounded, color: c.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('lesson.activity'),
                        style: context.tx.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(context.lx(l.activity), style: context.tx.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Quiz
          if (l.quiz.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(context.t('lesson.quiz'), style: context.tx.titleLarge),
            const SizedBox(height: 10),
            AppCard(
              child: QuizRunner(
                questions: l.quiz,
                compact: true,
                celebrate: false,
                onFinished: (correct, total) {
                  ref
                      .read(progressProvider.notifier)
                      .recordQuiz('lesson:${l.id}', correct, total);
                  setState(() => _quizDone = true);
                },
              ),
            ),
          ],
          // ── Sources
          const SizedBox(height: 24),
          Text(context.t('common.sources'), style: context.tx.titleLarge),
          const SizedBox(height: 10),
          SourceList(refs),
          const ReviewNote(),
          const SizedBox(height: 4),
          Text(
            context.t('lesson.revised', {'date': l.revised}),
            style: context.tx.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(context.t('lesson.disclaimer'), style: context.tx.bodySmall),
          const SizedBox(height: 22),
          PrimaryButton(
            key: const Key('lesson-complete'),
            label: context.t(done ? 'lesson.completedCta' : 'lesson.complete'),
            icon: done ? Icons.check_rounded : Icons.arrow_forward_rounded,
            color: done
                ? c.success
                : (_quizDone || l.quiz.isEmpty ? c.primary : c.primary),
            onPressed: () => done ? context.pop() : _complete(l),
          ),
        ],
      ),
    );
  }
}

class _DoneSheet extends StatelessWidget {
  final Lesson lesson;
  final Lesson? next;
  const _DoneSheet({required this.lesson, this.next});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    // Trauma-related lessons end calmly: no confetti, no cheering.
    final calm = lesson.sensitive;
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Mascot(size: 104, mood: calm ? Mood.calm : Mood.wow),
                const SizedBox(height: 14),
                Text(
                  context.t(
                    calm ? 'lesson.done.calm.title' : 'lesson.done.title',
                  ),
                  key: const Key('lesson-done-title'),
                  style: context.tx.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  context.t(
                    calm ? 'lesson.done.calm.body' : 'lesson.done.body',
                  ),
                  style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (next != null)
                  PrimaryButton(
                    label:
                        '${context.t('lesson.next')}: ${context.lx(next!.title)}',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      context.pushReplacement('/lesson/${next!.id}');
                    },
                  ),
                const SizedBox(height: 10),
                SoftButton(
                  key: const Key('lesson-done-close'),
                  label: context.t('lesson.backToTopic'),
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                ),
                if (calm) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/safety');
                    },
                    icon: const Icon(Icons.health_and_safety_rounded),
                    label: Text(context.t('safety.title')),
                  ),
                ],
              ],
            ),
          ),
          if (!calm) const Positioned.fill(child: Celebration()),
        ],
      ),
    );
  }
}
