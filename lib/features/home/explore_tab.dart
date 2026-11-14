import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../filters/topic_filter_bar.dart';
import 'cards.dart';

/// Lesson-type filters for Explore.
enum LessonKind { all, quick, lab, deep, unread }

class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab> {
  int _difficulty = 0; // 0 = any
  LessonKind _kind = LessonKind.all;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final topics = ref.watch(topicFilterProvider);
    final track = context.track;
    final done = progress.completedIds;
    final domains = content.domainsFor(track);
    final filtering =
        _difficulty != 0 || _kind != LessonKind.all || topics.isActive;
    // The topic filter is applied by the repository on top of the age track.
    final lessons = [
      for (final l in content.lessonsFor(track, filter: topics))
        if ((_difficulty == 0 || l.difficulty == _difficulty) &&
            switch (_kind) {
              LessonKind.all => true,
              LessonKind.quick => l.minutes <= 4,
              LessonKind.lab => l.interactive != null,
              LessonKind.deep => l.minutes >= 7,
              LessonKind.unread => !done.contains(l.id),
            })
          l,
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    context.t('explore.title'),
                    style: context.tx.displaySmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('explore.sub', {
                    'ages': track.ages,
                    'n': domains.length,
                  }),
                  style: context.tx.bodyMedium?.copyWith(
                    color: context.c.inkSoft,
                  ),
                ),
                const SizedBox(height: 14),
                const TopicFilterBar(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 18 + 44 * textScaleOf(context),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              children: [
                for (final (d, key) in const [
                  (1, 'difficulty.1'),
                  (2, 'difficulty.2'),
                  (3, 'difficulty.3'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoicePill(
                      key: Key('filter-d$d'),
                      label: context.t(key),
                      selected: _difficulty == d,
                      onTap: () => setState(
                        () => _difficulty = _difficulty == d ? 0 : d,
                      ),
                    ),
                  ),
                for (final k in LessonKind.values.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoicePill(
                      key: Key('filter-${k.name}'),
                      label: context.t('explore.kind.${k.name}'),
                      selected: _kind == k,
                      onTap: () => setState(
                        () => _kind = _kind == k ? LessonKind.all : k,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!filtering)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220 * textScaleOf(context),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 196 * textScaleOf(context),
              ),
              delegate: SliverChildBuilderDelegate(childCount: domains.length, (
                context,
                i,
              ) {
                final d = domains[i];
                final ls = content.lessonsFor(track, domain: d.id);
                final p = content.domainProgress(d.id, track, done);
                final st = DomainStyle.of(d.id);
                return FadeSlide(
                  delayMs: (i % 6) * 40,
                  child: AppCard(
                    key: Key('explore-${d.id}'),
                    onTap: () => context.push('/domain/${d.id}'),
                    semanticLabel: context.lx(d.titleFor(context.track)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [st.a, Color.lerp(st.a, st.b, 0.7)!],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                st.icon,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // A small still scene of the topic.
                            Expanded(
                              child: ExcludeSemantics(
                                child: SceneArt(
                                  kind: sceneForTopic(d.id, [track], 1),
                                  kids: track.isChild,
                                  seed: d.id.hashCode,
                                  height: 56,
                                  animate: false,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          context.lx(d.titleFor(context.track)),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: context.tx.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: p,
                            minHeight: 6,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                            semanticsLabel: context.lx(d.titleFor(context.track)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.t('explore.lessons', {'n': ls.length}),
                          style: context.tx.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          )
        else ...[
          if (lessons.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FilterEmptyState(
                  alsoClear: () => setState(() {
                    _difficulty = 0;
                    _kind = LessonKind.all;
                  }),
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 8, 0),
                child: topics.isActive
                    ? FilterResultLine(count: lessons.length, noun: 'lessons')
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          context.t('explore.lessons', {'n': lessons.length}),
                          style: context.tx.titleSmall,
                        ),
                      ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              sliver: SliverList.separated(
                itemCount: lessons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    LessonRow(lesson: lessons[i], showDomain: true),
              ),
            ),
          ],
          // Consent, safety, relationships and communication stay one tap away.
          const SliverToBoxAdapter(child: EssentialsStrip()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ],
    );
  }
}
