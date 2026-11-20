import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../onboarding/splash.dart';
import 'ask_tab.dart';
import 'cards.dart';
import 'explore_tab.dart';
import 'labs_tab.dart';
import 'me_tab.dart';

class ShellScreen extends StatefulWidget {
  final int initialTab;
  const ShellScreen({super.key, this.initialTab = 0});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  late int _tab = widget.initialTab.clamp(0, 4);

  @override
  void didUpdateWidget(ShellScreen old) {
    super.didUpdateWidget(old);
    if (old.initialTab != widget.initialTab) {
      _tab = widget.initialTab.clamp(0, 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    const icons = [
      (Icons.home_outlined, Icons.home_rounded, 'nav.home'),
      (Icons.explore_outlined, Icons.explore_rounded, 'nav.explore'),
      (Icons.science_outlined, Icons.science_rounded, 'nav.labs'),
      (Icons.forum_outlined, Icons.forum_rounded, 'nav.ask'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'nav.me'),
    ];
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _tab = 0);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _tab,
            children: [
              HomeTab(onTab: (i) => setState(() => _tab = i)),
              const ExploreTab(),
              const LabsTab(),
              const AskTab(),
              const MeTab(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.outline)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Row(
                children: [
                  for (var i = 0; i < icons.length; i++)
                    Expanded(
                      child: Tap(
                        key: Key('nav-$i'),
                        onTap: () => setState(() => _tab = i),
                        child: Semantics(
                          selected: _tab == i,
                          label: context.t(icons[i].$3),
                          child: ExcludeSemantics(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _tab == i
                                        ? c.primarySoft
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Icon(
                                    _tab == i ? icons[i].$2 : icons[i].$1,
                                    color: _tab == i
                                        ? (context.isDark
                                              ? Colors.white
                                              : c.primary)
                                        : c.inkSoft,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  context.t(icons[i].$3),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textScaler: TextScaler.noScaling,
                                  style: context.tx.labelSmall?.copyWith(
                                    color: _tab == i ? c.ink : c.inkSoft,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

class HomeTab extends ConsumerWidget {
  final ValueChanged<int> onTab;
  const HomeTab({super.key, required this.onTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    final track = context.track;
    final c = context.c;
    final done = progress.completedIds;
    final all = content.lessonsFor(track);
    final doneHere = all.where((l) => done.contains(l.id)).length;
    final topics = settings.topics;
    // The learning path follows "Topics I want to explore" when it is set.
    final recs = content.recommended(
      track,
      done,
      interests: settings.interests,
      filter: topics,
    );
    final last = progress.lastLesson == null
        ? null
        : content.lesson(progress.lastLesson!);
    final Lesson? cont =
        (last != null && last.visibleTo(track) && !done.contains(last.id))
        ? last
        : (recs.isNotEmpty ? recs.first : null);
    final now = DateTime.now();
    final fact = content.factOfTheDay(track, now);
    final myths = content.mythsFor(track);
    final myth = myths.isEmpty
        ? null
        : myths[(now.day + now.month * 31) % myths.length];
    final labs = content.labsFor(track);
    final featured = labs.isEmpty ? null : labs[now.day % labs.length];
    final greet = now.hour < 12
        ? 'home.greet.morning'
        : (now.hour < 17 ? 'home.greet.afternoon' : 'home.greet.evening');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 4),
            child: Row(
              children: [
                const Wordmark(size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Tap(
                      onTap: () => context.push('/settings'),
                      semanticLabel: context.t('settings.track'),
                      child: Pill(
                        '${track.ages} · ${context.t(track.nameKey)}',
                        icon: Icons.school_rounded,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('home-safety'),
                  tooltip: context.t('safety.title'),
                  onPressed: () => context.push('/safety'),
                  icon: Icon(Icons.health_and_safety_rounded, color: c.coral),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: FadeSlide(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.hero, const Color(0xFF34298A)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t(greet),
                            style: context.tx.labelLarge?.copyWith(
                              color: Palette.mint,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.t('home.hero'),
                            style: context.tx.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              ProgressRing(
                                value: all.isEmpty ? 0 : doneHere / all.length,
                                size: 46,
                                stroke: 6,
                                color: Palette.mint,
                                track: Colors.white24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.t('home.progress', {
                                    'done': doneHere,
                                    'total': all.length,
                                  }),
                                  style: context.tx.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Mascot(size: 92, mood: Mood.curious),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (labs.contains('magazine'))
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: FadeSlide(
                delayMs: 60,
                child: AppCard(
                  key: const Key('home-magazine'),
                  onTap: () => context.push('/magazine'),
                  semanticLabel: context.t('lab.magazine.title'),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2B0C12), Color(0xFF0E0D12)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2142B),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t('lab.magazine.title'),
                              style: context.tx.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.t('lab.magazine.sub'),
                              style: context.tx.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (cont != null) ...[
          SliverToBoxAdapter(
            child: SectionTitle(
              context.t(done.isEmpty ? 'home.start' : 'home.continue'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FadeSlide(delayMs: 80, child: ContinueCard(lesson: cont)),
            ),
          ),
        ],
        if (fact != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: FadeSlide(
                delayMs: 140,
                child: AppCard(
                  color: c.sun.withValues(alpha: context.isDark ? 0.2 : 0.32),
                  onTap: content.ref(fact.ref) == null
                      ? null
                      : () => showRefSheet(context, content.ref(fact.ref)!),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFFE39A00),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.t('home.fact'),
                              style: context.tx.labelMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              context.lx(fact.text),
                              style: context.tx.bodyLarge,
                            ),
                            if (content.ref(fact.ref) != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${context.t('common.source')}: ${content.ref(fact.ref)!.publisher}',
                                style: context.tx.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (topics.isActive)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 0),
              child: Row(
                key: const Key('home-filter-note'),
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: c.inkSoft),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.t('filter.path.note'),
                      style: context.tx.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: ref.read(settingsProvider.notifier).clearTopics,
                    child: Text(context.t('filter.clear')),
                  ),
                ],
              ),
            ),
          ),
        if (recs.length > 1) ...[
          SliverToBoxAdapter(child: SectionTitle(context.t('home.path'))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 178 * textScaleOf(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recs.take(8).length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => PathCard(lesson: recs[i], step: i + 1),
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SectionTitle(
            context.t('home.topics'),
            action: context.t('common.seeAll'),
            onAction: () => onTab(1),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150 * textScaleOf(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: content.domainsFor(track).length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final d = content.domainsFor(track)[i];
                return SizedBox(
                  width: 150 * textScaleOf(context),
                  child: DomainTile(
                    domain: d,
                    progress: content.domainProgress(d.id, track, done),
                  ),
                );
              },
            ),
          ),
        ),
        if (myth != null) ...[
          SliverToBoxAdapter(child: SectionTitle(context.t('home.myth'))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                key: const Key('home-myth'),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A5B), Palette.coral],
                ),
                onTap: () => context.push('/lab/myth_buster'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('myth.tagline'),
                      style: context.tx.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '“${context.lx(myth.claim)}”',
                      style: context.tx.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Pill(
                          context.t('myth.play'),
                          color: Colors.white,
                          foreground: Palette.dark,
                          icon: Icons.touch_app_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (featured != null) ...[
          SliverToBoxAdapter(
            child: SectionTitle(
              context.t('home.featured'),
              action: context.t('common.seeAll'),
              onAction: () => onTab(2),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LabCard(
                labKey: featured,
                wide: true,
                onTap: () => context.push(labRoute(featured)),
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: AppCard(
              color: c.mint.withValues(alpha: context.isDark ? 0.16 : 0.4),
              onTap: () => context.push('/safety'),
              child: Row(
                children: [
                  Icon(Icons.support_rounded, color: c.success, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('home.safety.title'),
                          style: context.tx.titleMedium,
                        ),
                        Text(
                          context.t('home.safety.body'),
                          style: context.tx.bodySmall?.copyWith(color: c.ink),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: c.ink),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
