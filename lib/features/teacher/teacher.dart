import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/content.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../home/cards.dart';
import '../settings/educator.dart';
import '../lessons/lesson_visual.dart';

/// Teacher Mode: curriculum, lesson plans, classroom tools.
/// It reads only the bundled curriculum — never a learner's notes, searches,
/// quiz results or progress.
class TeacherScreen extends ConsumerStatefulWidget {
  const TeacherScreen({super.key});

  @override
  ConsumerState<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends ConsumerState<TeacherScreen> {
  Track? _track;
  String _tab = 'curriculum';
  String? _open;
  bool _unlocked = false;

  Future<void> _unlock() async {
    final pin = await askPin(context);
    if (pin == null || !mounted) return;
    final ok = ref.read(settingsProvider.notifier).checkPin(pin);
    if (ok) {
      setState(() => _unlocked = true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.t('lock.wrong'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final settings = ref.watch(settingsProvider);
    final c = context.c;
    if (settings.locked && !_unlocked) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t('me.teacher.title'))),
        body: EmptyState(
          title: context.t('teacher.locked'),
          body: context.t('teacher.locked.body'),
          mood: Mood.calm,
          action: PrimaryButton(
            label: context.t('lock.enter'),
            icon: Icons.lock_open_rounded,
            expand: false,
            onPressed: _unlock,
          ),
        ),
      );
    }
    // With the educator lock verified, a teacher may browse every track in this edition.
    final tracks = settings.locked ? editionTracks : settings.selectableTracks;
    final track = tracks.contains(_track)
        ? _track!
        : (tracks.contains(context.track) ? context.track : tracks.first);
    final domains = content.domainsFor(track);

    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.teacher.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(screen: 'teacher'),
          InfoBanner(
            icon: Icons.visibility_off_rounded,
            color: c.success,
            title: context.t('teacher.privacy.title'),
            text: context.t('teacher.privacy'),
          ),
          const SizedBox(height: 14),
          Text(context.t('teacher.pickTrack'), style: context.tx.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in tracks)
                ChoicePill(
                  key: Key('teacher-track-${t.name}'),
                  label: '${t.ages} · ${context.t(t.nameKey)}',
                  selected: t == track,
                  onTap: () => setState(() => _track = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in const [
                'curriculum',
                'rules',
                'safeguarding',
                'coverage',
              ])
                ChoicePill(
                  key: Key('teacher-tab-$t'),
                  label: context.t('teacher.tab.$t'),
                  selected: _tab == t,
                  onTap: () => setState(() => _tab = t),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_tab == 'curriculum')
            for (final d in domains) _domainCard(context, content, d, track)
          else if (_tab == 'rules') ...[
            Text(
              context.t('teacher.rules.title'),
              style: context.tx.headlineSmall,
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < content.groundRules.length; i++)
              _Numbered(n: i + 1, text: context.lx(content.groundRules[i])),
            const SizedBox(height: 12),
            AppCard(
              color: c.surfaceAlt,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.how_to_vote_rounded, color: c.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.t('teacher.box'),
                          style: context.tx.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.lx(content.questionBox),
                    style: context.tx.bodyLarge,
                  ),
                ],
              ),
            ),
          ] else if (_tab == 'safeguarding') ...[
            Text(
              context.t('teacher.safe.title'),
              style: context.tx.headlineSmall,
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < content.safeguarding.length; i++)
              _Numbered(n: i + 1, text: context.lx(content.safeguarding[i])),
            const SizedBox(height: 12),
            InfoBanner(
              icon: Icons.gavel_rounded,
              color: c.warning,
              text: context.t('teacher.safe.legal'),
            ),
            const SizedBox(height: 12),
            SoftButton(
              label: context.t('safety.title'),
              icon: Icons.health_and_safety_rounded,
              onPressed: () => context.push('/safety'),
            ),
          ] else
            _Coverage(content: content, tracks: tracks),
        ],
      ),
    );
  }

  Widget _domainCard(
    BuildContext context,
    ContentRepository content,
    Domain d,
    Track track,
  ) {
    final c = context.c;
    final lessons = content.lessonsFor(track, domain: d.id);
    final note = content.teacherNotes[d.id];
    final open = _open == d.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        key: Key('teacher-domain-${d.id}'),
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tap(
              onTap: () => setState(() => _open = open ? null : d.id),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    DomainArt(d.id, size: 46, radius: 15),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.lx(d.title),
                            style: context.tx.titleMedium,
                          ),
                          Text(
                            '${context.t('explore.lessons', {'n': lessons.length})} · ${context.t('teacher.minutes', {'n': lessons.fold<int>(0, (a, l) => a + l.minutes)})}',
                            style: context.tx.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: c.inkSoft,
                    ),
                  ],
                ),
              ),
            ),
            if (open)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final u in d.unesco)
                          Pill(
                            context.t('unesco.$u'),
                            icon: Icons.public_rounded,
                          ),
                      ],
                    ),
                    if (note != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        context.t('teacher.facilitation'),
                        style: context.tx.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.lx(note.notes),
                        style: context.tx.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.t('teacher.prompts'),
                        style: context.tx.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      for (final p in note.prompts)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: c.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.lx(p),
                                  style: context.tx.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      InfoBanner(
                        icon: Icons.shield_rounded,
                        color: c.warning,
                        text: context.lx(note.caution),
                      ),
                    ],
                    const SizedBox(height: 12),
                    for (final l in lessons)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Tap(
                          key: Key('teacher-lesson-${l.id}'),
                          onTap: () => context.push('/teacher/lesson/${l.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: c.surfaceAlt,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.lx(l.title),
                                        style: context.tx.titleSmall,
                                      ),
                                      Text(
                                        lessonMeta(context, l),
                                        style: context.tx.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: c.inkSoft,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    SoftButton(
                      key: Key('teacher-quiz-${d.id}'),
                      label: context.t('teacher.groupQuiz'),
                      icon: Icons.groups_rounded,
                      onPressed: () =>
                          context.push('/teacher/quiz/${track.name}/${d.id}'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Numbered extends StatelessWidget {
  final int n;
  final String text;
  const _Numbered({required this.n, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.c.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$n',
            textScaler: TextScaler.noScaling,
            style: context.tx.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: context.tx.bodyLarge)),
      ],
    ),
  );
}

/// Curriculum coverage matrix: lessons per domain per age track.
class _Coverage extends StatelessWidget {
  final ContentRepository content;
  final List<Track> tracks;
  const _Coverage({required this.content, required this.tracks});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final counts = content.counts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('teacher.coverage.title'),
          style: context.tx.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          context.t('teacher.coverage.sub'),
          style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in const [
              'lessons',
              'faqs',
              'myths',
              'quiz',
              'scenarios',
              'glossaryTerms',
            ])
              Pill('${counts[k]} ${context.t('refs.count.$k')}'),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Table(
            columnWidths: {
              0: const FlexColumnWidth(),
              for (var i = 0; i < tracks.length; i++)
                i + 1: const FixedColumnWidth(40),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  Text(
                    context.t('teacher.coverage.domain'),
                    style: context.tx.labelMedium,
                  ),
                  for (final t in tracks)
                    Center(
                      child: Text(
                        t.ages,
                        textScaler: TextScaler.noScaling,
                        style: context.tx.labelSmall,
                      ),
                    ),
                ],
              ),
              for (final d in content.domains)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Text(
                        '${d.number}. ${context.lx(d.title)}',
                        style: context.tx.bodySmall?.copyWith(color: c.ink),
                      ),
                    ),
                    for (final t in tracks)
                      Center(
                        child: Builder(
                          builder: (context) {
                            final n = content
                                .lessonsFor(t, domain: d.id)
                                .length;
                            return Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: n == 0
                                    ? c.surfaceAlt
                                    : DomainStyle.of(d.id).a.withValues(
                                        alpha: 0.2 + 0.12 * n.clamp(0, 5),
                                      ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                n == 0 ? '–' : '$n',
                                textScaler: TextScaler.noScaling,
                                style: context.tx.labelMedium,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.t('teacher.coverage.unesco'),
          style: context.tx.titleLarge,
        ),
        const SizedBox(height: 10),
        for (final u in kUnescoConcepts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$u. ${context.t('unesco.$u')}',
                    style: context.tx.bodyMedium,
                  ),
                ),
                Pill(
                  context.t('explore.lessons', {
                    'n': content.lessons
                        .where((l) => l.unesco.contains(u))
                        .length,
                  }),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        const ReviewNote(),
        const SizedBox(height: 6),
        Text(context.t('teacher.noEndorse'), style: context.tx.bodySmall),
      ],
    );
  }
}

bool _teacherCanSee(WidgetRef ref, Lesson l) {
  final s = ref.read(settingsProvider);
  final tracks = s.locked ? editionTracks : s.selectableTracks;
  return l.tracks.any(tracks.contains);
}

/// Plain-text, non-identifiable lesson summary for sharing or printing.
String lessonSummaryText(
  BuildContext context,
  ContentRepository content,
  Lesson l,
) {
  final note = content.teacherNotes[l.domain];
  final b = StringBuffer()
    ..writeln('UNFILTERED — ${context.lx(l.title)}')
    ..writeln(context.lx(l.subtitle))
    ..writeln(
      '${context.t('common.ages')} ${l.tracks.map((t) => t.ages).join(', ')} · ${lessonMeta(context, l)}',
    )
    ..writeln()
    ..writeln(context.t('lesson.objectives'));
  for (final o in l.objectives) {
    b.writeln('• ${context.lx(o)}');
  }
  b
    ..writeln()
    ..writeln(context.t('lesson.takeaways'));
  for (final t in l.takeaways) {
    b.writeln('• ${context.lx(t)}');
  }
  if (note != null) {
    b
      ..writeln()
      ..writeln(context.t('teacher.prompts'));
    for (final p in note.prompts) {
      b.writeln('• ${context.lx(p)}');
    }
  }
  b
    ..writeln()
    ..writeln(context.t('common.sources'));
  for (final r in l.refs) {
    final e = content.ref(r);
    if (e != null) b.writeln('• ${e.title} — ${e.publisher} — ${e.url}');
  }
  b
    ..writeln()
    ..writeln(context.t('review.pending'));
  return b.toString();
}

class TeacherLessonScreen extends ConsumerWidget {
  final String id;
  const TeacherLessonScreen(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final l = content.lesson(id);
    if (l == null || !_teacherCanSee(ref, l)) return const NotAvailableScreen();
    final c = context.c;
    final note = content.teacherNotes[l.domain];
    Widget h(String key) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(context.t(key), style: context.tx.titleLarge),
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.t('teacher.plan'))),
      body: PageBody(
        children: [
          Text(context.lx(l.title), style: context.tx.displaySmall),
          const SizedBox(height: 6),
          Text(
            context.lx(l.subtitle),
            style: context.tx.bodyLarge?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              Pill(
                '${context.t('common.ages')} ${l.tracks.map((t) => t.ages).join(', ')}',
                icon: Icons.school_rounded,
              ),
              Pill(lessonMeta(context, l), icon: Icons.schedule_rounded),
              for (final u in l.unesco)
                Pill(context.t('unesco.$u'), icon: Icons.public_rounded),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  key: const Key('teacher-present'),
                  label: context.t('teacher.present'),
                  icon: Icons.slideshow_rounded,
                  onPressed: () => context.push('/teacher/present/${l.id}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SoftButton(
                  key: const Key('teacher-copy'),
                  label: context.t('teacher.copy'),
                  icon: Icons.copy_rounded,
                  onPressed: () async {
                    final text = lessonSummaryText(context, content, l);
                    final done = context.t('teacher.copied');
                    final messenger = ScaffoldMessenger.of(context);
                    await Clipboard.setData(ClipboardData(text: text));
                    messenger.showSnackBar(SnackBar(content: Text(done)));
                  },
                ),
              ),
            ],
          ),
          if (l.warning != null) ...[
            const SizedBox(height: 14),
            InfoBanner(
              icon: Icons.medical_information_rounded,
              color: c.danger,
              text: context.lx(l.warning!),
            ),
          ],
          h('lesson.objectives'),
          for (final o in l.objectives)
            _Numbered(n: l.objectives.indexOf(o) + 1, text: context.lx(o)),
          h('teacher.outline'),
          for (final s in l.sections) ...[
            Text(context.lx(s.h), style: context.tx.titleMedium),
            const SizedBox(height: 4),
            Text(context.lx(s.body), style: context.tx.bodyMedium),
            const SizedBox(height: 12),
          ],
          h('teacher.mythToAddress'),
          Text('“${context.lx(l.mythClaim)}”', style: context.tx.titleMedium),
          const SizedBox(height: 4),
          Text(context.lx(l.mythFact), style: context.tx.bodyMedium),
          h('lesson.activity'),
          Text(context.lx(l.activity), style: context.tx.bodyLarge),
          if (note != null) ...[
            h('teacher.prompts'),
            for (final p in note.prompts)
              _Numbered(n: note.prompts.indexOf(p) + 1, text: context.lx(p)),
            InfoBanner(
              icon: Icons.shield_rounded,
              color: c.warning,
              text: context.lx(note.caution),
            ),
          ],
          h('teacher.check'),
          for (final q in l.quiz)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.lx(q.q), style: context.tx.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      '${context.t('teacher.answer')}: ${q.isValid ? context.lx(q.options[q.answer]) : ''}',
                      style: context.tx.bodyMedium?.copyWith(color: c.success),
                    ),
                    Text(context.lx(q.explain), style: context.tx.bodySmall),
                  ],
                ),
              ),
            ),
          h('common.sources'),
          SourceList([
            for (final r in l.refs)
              if (content.ref(r) != null) content.ref(r)!,
          ]),
          const ReviewNote(),
        ],
      ),
    );
  }
}

/// Projector-safe presentation: large type, high contrast, one idea per slide.
class PresentScreen extends ConsumerStatefulWidget {
  final String id;
  const PresentScreen(this.id, {super.key});

  @override
  ConsumerState<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends ConsumerState<PresentScreen> {
  final _ctrl = PageController();
  int _i = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final l = content.lesson(widget.id);
    if (l == null || !_teacherCanSee(ref, l)) return const NotAvailableScreen();
    final note = content.teacherNotes[l.domain];
    final st = DomainStyle.of(l.domain);
    final slides = <(String, String, String)>[
      (
        context.lx(content.domain(l.domain)?.title ?? L.empty),
        context.lx(l.title),
        context.lx(l.hook),
      ),
      for (final s in l.sections) ('', context.lx(s.h), context.lx(s.body)),
      (
        context.t('verdict.myth'),
        '“${context.lx(l.mythClaim)}”',
        context.lx(l.mythFact),
      ),
      (
        context.t('lesson.takeaways'),
        '',
        l.takeaways.map((t) => '• ${context.lx(t)}').join('\n\n'),
      ),
      if (note != null && note.prompts.isNotEmpty)
        (
          context.t('teacher.prompts'),
          '',
          note.prompts.map((p) => '• ${context.lx(p)}').join('\n\n'),
        ),
    ];
    void go(int d) {
      final n = (_i + d).clamp(0, slides.length - 1);
      context.reducedMotion
          ? _ctrl.jumpToPage(n)
          : _ctrl.animateToPage(
              n,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
    }

    return Scaffold(
      backgroundColor: Palette.dark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.t('common.close'),
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    '${_i + 1} / ${slides.length}',
                    key: const Key('present-count'),
                    style: context.tx.labelLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                itemCount: slides.length,
                onPageChanged: (p) => setState(() => _i = p),
                itemBuilder: (_, i) {
                  final (kicker, title, body) = slides[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (kicker.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Pill(
                                  kicker,
                                  color: st.b,
                                  foreground: Palette.dark,
                                ),
                              ),
                            if (title.isNotEmpty)
                              Text(
                                title,
                                style: context.tx.displayMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            if (title.isNotEmpty) const SizedBox(height: 18),
                            Text(
                              body,
                              style: context.tx.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: context.t('common.back'),
                      color: Colors.white12,
                      foreground: Colors.white,
                      onPressed: _i == 0 ? null : () => go(-1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      key: const Key('present-next'),
                      label: context.t('common.next'),
                      color: st.a,
                      foreground: Colors.white,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _i == slides.length - 1 ? null : () => go(1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group quiz for a classroom: show, discuss, reveal. Nothing is recorded.
class GroupQuizScreen extends ConsumerStatefulWidget {
  final Track track;
  final String domain;
  const GroupQuizScreen({super.key, required this.track, required this.domain});

  @override
  ConsumerState<GroupQuizScreen> createState() => _GroupQuizScreenState();
}

class _GroupQuizScreenState extends ConsumerState<GroupQuizScreen> {
  int _i = 0;
  bool _reveal = false;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final s = ref.watch(settingsProvider);
    final tracks = s.locked ? editionTracks : s.selectableTracks;
    if (!tracks.contains(widget.track)) return const NotAvailableScreen();
    final qs = content
        .quizFor(widget.track, domain: widget.domain)
        .take(12)
        .toList();
    final c = context.c;
    if (qs.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          title: context.t('quiz.empty'),
          body: context.t('quiz.empty.body'),
        ),
      );
    }
    final q = qs[_i];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${context.t('teacher.groupQuiz')} · ${_i + 1}/${qs.length}',
        ),
      ),
      body: PageBody(
        children: [
          Text(context.lx(q.q), style: context.tx.displaySmall),
          const SizedBox(height: 18),
          for (var o = 0; o < q.options.length; o++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _reveal && o == q.answer
                      ? c.success.withValues(alpha: 0.16)
                      : c.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _reveal && o == q.answer ? c.success : c.outline,
                    width: _reveal && o == q.answer ? 2.4 : 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      String.fromCharCode(65 + o),
                      style: context.tx.titleLarge,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        context.lx(q.options[o]),
                        style: context.tx.titleMedium,
                      ),
                    ),
                    if (_reveal && o == q.answer)
                      Icon(Icons.check_circle_rounded, color: c.success),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          if (_reveal) ...[
            InfoBanner(
              key: const Key('group-explain'),
              icon: Icons.lightbulb_rounded,
              color: c.success,
              text: context.lx(q.explain),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              label: context.t(
                _i < qs.length - 1 ? 'quiz.next' : 'common.done',
              ),
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _i < qs.length - 1
                  ? setState(() {
                      _i++;
                      _reveal = false;
                    })
                  : context.pop(),
            ),
          ] else
            PrimaryButton(
              key: const Key('group-reveal'),
              label: context.t('teacher.reveal'),
              icon: Icons.visibility_rounded,
              onPressed: () => setState(() => _reveal = true),
            ),
          const SizedBox(height: 12),
          Text(context.t('teacher.groupNote'), style: context.tx.bodySmall),
        ],
      ),
    );
  }
}
