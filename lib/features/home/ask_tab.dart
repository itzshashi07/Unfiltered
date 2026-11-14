import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/search.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../filters/topic_filter_bar.dart';
import '../lessons/lesson_visual.dart';

/// "Ask Unfiltered": private, offline search over curated answers.
/// It is retrieval, not AI — it can only show answers bundled with the app.
class AskTab extends ConsumerStatefulWidget {
  const AskTab({super.key});

  @override
  ConsumerState<AskTab> createState() => _AskTabState();
}

class _AskTabState extends ConsumerState<AskTab> {
  final _ctrl = TextEditingController();
  String _query = '';
  String? _open;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _run(String q) {
    FocusScope.of(context).unfocus();
    setState(() {
      _query = q.trim();
      _open = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final c = context.c;
    final hasQuery = _query.isNotEmpty;
    final topics = ref.watch(topicFilterProvider);
    var results = const <Faq>[];
    var myths = const <MythCard>[];
    var terms = const <GlossaryTerm>[];
    var urgent = false;
    var hidden = 0; // answers that match the words but not the chosen topics
    if (hasQuery) {
      final engine = ref.watch(searchProvider);
      // Age track first, always; the topic filter only narrows further.
      final inTrack = engine.search(_query, where: (f) => f.visibleTo(track));
      results = [
        for (final f in inTrack)
          if (topics.matches(f)) f,
      ];
      hidden = inTrack.length - results.length;
      myths = engine.searchMyths(
        _query,
        where: (m) => m.visibleTo(track) && topics.matches(m),
      );
      terms = engine.searchTerms(_query, where: (g) => g.visibleTo(track));
      urgent =
          SearchEngine.isUrgent(_query) || inTrack.take(2).any((f) => f.urgent);
    }
    // The FAQ library: every prepared answer for this track, filterable.
    final library = hasQuery
        ? const <Faq>[]
        : content.faqsFor(track, filter: topics);

    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Semantics(
          header: true,
          child: Text(context.t('ask.title'), style: context.tx.displaySmall),
        ),
        const SizedBox(height: 4),
        Text(
          context.t('ask.sub'),
          style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('ask-field'),
          controller: _ctrl,
          textInputAction: TextInputAction.search,
          minLines: 1,
          maxLines: 3,
          onSubmitted: _run,
          decoration: InputDecoration(
            hintText: context.t('ask.hint'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              key: const Key('ask-go'),
              tooltip: context.t('ask.search'),
              icon: Icon(
                Icons.arrow_circle_right_rounded,
                color: c.primary,
                size: 30,
              ),
              onPressed: () => _run(_ctrl.text),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, size: 15, color: c.inkSoft),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                context.t('ask.privacy'),
                style: context.tx.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (urgent) ...[
          _UrgentCard(key: const Key('ask-urgent')),
          const SizedBox(height: 14),
        ],
        if (!hasQuery) ...[
          Semantics(
            header: true,
            child: Text(
              context.t('ask.library'),
              style: context.tx.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.t('ask.library.sub'),
            style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
          ),
          const SizedBox(height: 12),
          const TopicFilterBar(),
          const SizedBox(height: 8),
          if (topics.isActive && library.isNotEmpty)
            FilterResultLine(count: library.length, noun: 'faqs')
          else if (library.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                context.t('ask.results', {'n': library.length}),
                style: context.tx.titleSmall,
              ),
            ),
          if (library.isEmpty)
            const FilterEmptyState()
          else
            for (final f in library)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FaqCard(
                  faq: f,
                  open: _open == f.id,
                  onToggle: () =>
                      setState(() => _open = _open == f.id ? null : f.id),
                ),
              ),
          if (topics.audience.isNotEmpty &&
              !topics.audience.contains(Audience.everyone))
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => ref
                    .read(settingsProvider.notifier)
                    .toggleAudience(Audience.everyone),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.t('filter.essentials.add')),
              ),
            ),
        ] else if (results.isEmpty && myths.isEmpty && terms.isEmpty)
          Padding(
            key: const Key('ask-none'),
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                const Mascot(size: 96, mood: Mood.calm),
                const SizedBox(height: 12),
                Text(
                  context.t('ask.none.title'),
                  style: context.tx.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('ask.none.body'),
                  style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
                  textAlign: TextAlign.center,
                ),
                if (hidden > 0) _HiddenByFilter(count: hidden),
                const SizedBox(height: 16),
                SoftButton(
                  label: context.t('safety.title'),
                  icon: Icons.health_and_safety_rounded,
                  onPressed: () => context.push('/safety'),
                ),
              ],
            ),
          )
        else ...[
          if (results.isNotEmpty)
            Text(
              context.t('ask.results', {'n': results.length}),
              style: context.tx.titleMedium,
            ),
          if (hidden > 0) _HiddenByFilter(count: hidden),
          const SizedBox(height: 10),
          for (final f in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FaqCard(
                faq: f,
                open: _open == f.id || (results.length == 1),
                onToggle: () =>
                    setState(() => _open = _open == f.id ? null : f.id),
              ),
            ),
          if (myths.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(context.t('ask.myths'), style: context.tx.titleMedium),
            const SizedBox(height: 10),
            for (final m in myths)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill(
                        context.t('verdict.${m.verdict.name}'),
                        icon: m.verdict == Verdict.myth
                            ? Icons.close_rounded
                            : Icons.check_rounded,
                        color:
                            (m.verdict == Verdict.myth ? c.danger : c.success)
                                .withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '“${context.lx(m.claim)}”',
                        style: context.tx.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(context.lx(m.fact), style: context.tx.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
          if (terms.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(context.t('ask.terms'), style: context.tx.titleMedium),
            const SizedBox(height: 10),
            for (final t in terms)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.lx(t.term), style: context.tx.titleMedium),
                      const SizedBox(height: 4),
                      Text(context.lx(t.def), style: context.tx.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 6),
          Text(context.t('ask.disclaimer'), style: context.tx.bodySmall),
        ],
      ],
    );
  }
}

/// Tells the learner that their topic chips, not the app, hid some answers.
class _HiddenByFilter extends ConsumerWidget {
  final int count;
  const _HiddenByFilter({required this.count});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    key: const Key('ask-hidden'),
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(Icons.tune_rounded, size: 18, color: context.c.inkSoft),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.t('filter.hidden', {'n': count}),
            style: context.tx.bodySmall,
          ),
        ),
        TextButton(
          onPressed: ref.read(settingsProvider.notifier).clearTopics,
          child: Text(context.t('filter.clear')),
        ),
      ],
    ),
  );
}

class _UrgentCard extends StatelessWidget {
  const _UrgentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return AppCard(
      color: c.coral.withValues(alpha: context.isDark ? 0.2 : 0.14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_rounded, color: c.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.t('ask.urgent.title'),
                  style: context.tx.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(context.t('ask.urgent.body'), style: context.tx.bodyMedium),
          const SizedBox(height: 12),
          PrimaryButton(
            label: context.t('ask.urgent.cta'),
            color: c.danger,
            foreground: Colors.white,
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.push('/safety'),
          ),
        ],
      ),
    );
  }
}

/// A curated question with its referenced answer.
class FaqCard extends ConsumerWidget {
  final Faq faq;
  final bool open;
  final VoidCallback onToggle;
  const FaqCard({
    super.key,
    required this.faq,
    required this.open,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final c = context.c;
    final refs = [
      for (final r in faq.refs)
        if (content.ref(r) != null) content.ref(r)!,
    ];
    final lesson = faq.lesson == null ? null : content.lesson(faq.lesson!);
    return AppCard(
      key: Key('faq-${faq.id}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tap(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      context.lx(faq.q),
                      style: context.tx.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TopicBanner(
                    domain: faq.domain,
                    tracks: faq.tracks,
                    seed: faq.id.hashCode,
                    lesson: faq.lesson,
                  ),
                  Text(context.lx(faq.a), style: context.tx.bodyLarge),
                  if (faq.urgent) ...[
                    const SizedBox(height: 12),
                    InfoBanner(
                      icon: Icons.support_rounded,
                      color: c.danger,
                      text: context.t('ask.urgent.inline'),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    context.t('common.sources'),
                    style: context.tx.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  SourceList(refs),
                  const ReviewNote(),
                  if (lesson != null && lesson.visibleTo(context.track)) ...[
                    const SizedBox(height: 12),
                    SoftButton(
                      label:
                          '${context.t('common.learnMore')}: ${context.lx(lesson.title)}',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.push('/lesson/${lesson.id}'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
