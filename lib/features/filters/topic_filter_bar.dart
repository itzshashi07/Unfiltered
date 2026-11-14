import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../home/cards.dart';

/// The learner's current "Topics I want to explore" selection.
final topicFilterProvider = Provider<TopicFilter>(
  (ref) => ref.watch(settingsProvider.select((s) => s.topics)),
);

/// "Topics I want to explore": optional chips that organise content by who it
/// is about and by body topic. They never restrict access and never unlock
/// anything outside the learner's age track.
class TopicFilterBar extends ConsumerStatefulWidget {
  final bool initiallyOpen;
  const TopicFilterBar({super.key, this.initiallyOpen = false});

  @override
  ConsumerState<TopicFilterBar> createState() => _TopicFilterBarState();
}

class _TopicFilterBarState extends ConsumerState<TopicFilterBar> {
  late bool _open = widget.initiallyOpen;

  // Lists build lazily, so the bar is rebuilt after scrolling away and back.
  // PageStorage keeps it open or closed the way the learner left it.
  static const _storageId = 'topic-filter-open';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final saved = PageStorage.maybeOf(
      context,
    )?.readState(context, identifier: _storageId);
    if (saved is bool) _open = saved;
  }

  void _toggle() {
    setState(() => _open = !_open);
    PageStorage.maybeOf(
      context,
    )?.writeState(context, _open, identifier: _storageId);
  }

  @override
  Widget build(BuildContext context) {
    final f = ref.watch(topicFilterProvider);
    final n = ref.read(settingsProvider.notifier);
    final c = context.c;
    return AppCard(
      key: const Key('topic-filter'),
      padding: const EdgeInsets.fromLTRB(14, 6, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tap(
            key: const Key('filter-toggle'),
            onTap: _toggle,
            child: Semantics(
              expanded: _open,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Icon(Icons.tune_rounded, color: c.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        context.t('filter.title'),
                        style: context.tx.titleMedium,
                      ),
                    ),
                    if (f.isActive)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Pill(
                          context.t('filter.active', {'n': f.count}),
                          color: c.primary,
                          foreground: c.onPrimary,
                        ),
                      ),
                    Icon(
                      _open
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: c.inkSoft,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_open && f.isActive) ...[
            // Collapsed: still show what is active, each chip removable.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in Audience.values)
                  if (f.audience.contains(a))
                    ChoicePill(
                      key: Key('filter-on-${a.key}'),
                      label: context.t(a.labelKey),
                      selected: true,
                      onTap: () => n.toggleAudience(a),
                    ),
                for (final b in BodyTopic.values)
                  if (f.body.contains(b))
                    ChoicePill(
                      key: Key('filter-on-${b.key}'),
                      label: context.t(b.labelKey),
                      selected: true,
                      onTap: () => n.toggleBodyTopic(b),
                    ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('filter-clear'),
                onPressed: n.clearTopics,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: Text(context.t('filter.clear')),
              ),
            ),
          ],
          if (_open) ...[
            Text(context.t('filter.sub'), style: context.tx.bodySmall),
            const SizedBox(height: 12),
            Text(
              context.t('filter.group.audience'),
              style: context.tx.labelMedium?.copyWith(color: c.inkSoft),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoicePill(
                  key: const Key('filter-all'),
                  label: context.t('filter.all'),
                  selected: !f.isActive,
                  onTap: n.clearTopics,
                ),
                for (final a in Audience.values)
                  ChoicePill(
                    key: Key('filter-aud-${a.key}'),
                    label: context.t(a.labelKey),
                    selected: f.audience.contains(a),
                    onTap: () => n.toggleAudience(a),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              context.t('filter.group.body'),
              style: context.tx.labelMedium?.copyWith(color: c.inkSoft),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in BodyTopic.values)
                  ChoicePill(
                    key: Key('filter-body-${b.key}'),
                    label: context.t(b.labelKey),
                    selected: f.body.contains(b),
                    onTap: () => n.toggleBodyTopic(b),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: c.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.t('filter.note'),
                    style: context.tx.bodySmall,
                  ),
                ),
              ],
            ),
            if (f.isActive)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('filter-clear'),
                  onPressed: n.clearTopics,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: Text(context.t('filter.clear')),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// "N lessons match your topics" with a clear action. Shown while a filter is on.
class FilterResultLine extends ConsumerWidget {
  final int count;

  /// One of: lessons, faqs, myths, quiz.
  final String noun;
  const FilterResultLine({super.key, required this.count, required this.noun});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Semantics(
    liveRegion: true,
    child: Row(
      children: [
        Expanded(
          child: Text(
            context.t('filter.results.$noun', {'n': count}),
            key: const Key('filter-count'),
            style: context.tx.titleSmall,
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

/// Helpful empty state for a filter that matches nothing.
class FilterEmptyState extends ConsumerWidget {
  final VoidCallback? alsoClear;
  const FilterEmptyState({super.key, this.alsoClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    key: const Key('filter-empty'),
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Column(
      children: [
        const Mascot(size: 88, mood: Mood.curious),
        const SizedBox(height: 12),
        Text(
          context.t('filter.empty.title'),
          style: context.tx.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          context.t('filter.empty.body'),
          style: context.tx.bodyMedium?.copyWith(color: context.c.inkSoft),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          key: const Key('filter-empty-clear'),
          label: context.t('filter.clear'),
          icon: Icons.close_rounded,
          expand: false,
          onPressed: () {
            ref.read(settingsProvider.notifier).clearTopics();
            alsoClear?.call();
          },
        ),
      ],
    ),
  );
}

/// Keeps consent, safety, relationships and communication one tap away while
/// a gender or body filter is narrowing the list.
class EssentialsStrip extends ConsumerWidget {
  const EssentialsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(topicFilterProvider);
    if (!f.isActive ||
        f.audience.contains(Audience.everyone) && f.body.isEmpty) {
      return const SizedBox.shrink();
    }
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final track = context.track;
    final domains = content.essentialDomainsFor(track);
    if (domains.isEmpty) return const SizedBox.shrink();
    return Column(
      key: const Key('essentials-strip'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
          child: Text(
            context.t('filter.essentials.title'),
            style: context.tx.headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            context.t('filter.essentials.body'),
            style: context.tx.bodyMedium?.copyWith(color: context.c.inkSoft),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150 * textScaleOf(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: domains.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 150 * textScaleOf(context),
              child: DomainTile(
                domain: domains[i],
                progress: content.domainProgress(
                  domains[i].id,
                  track,
                  progress.completedIds,
                ),
              ),
            ),
          ),
        ),
        if (!f.audience.contains(Audience.everyone) && f.audience.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 20, 0),
            child: TextButton.icon(
              key: const Key('filter-add-everyone'),
              onPressed: () => ref
                  .read(settingsProvider.notifier)
                  .toggleAudience(Audience.everyone),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.t('filter.essentials.add')),
            ),
          ),
      ],
    );
  }
}
