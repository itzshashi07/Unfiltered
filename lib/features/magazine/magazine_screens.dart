import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/magazine.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import 'story_text.dart';

const _ink = Color(0xFF0E0D12);
const _blood = Color(0xFFD2142B);

bool _allowed(BuildContext context) => context.track.index >= Track.d.index;

String _date(DateTime? d, Lang lang) {
  if (d == null) return '';
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

/// Loading / error states shared by the magazine screens.
Widget _async<T>(
  BuildContext context,
  AsyncValue<T> v,
  Widget Function(T) data,
) => v.when(
  data: data,
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, _) => EmptyState(title: context.t('mag.error'), body: '$e'),
);

// ───────────────────────────── Magazine home

class MagazineScreen extends ConsumerStatefulWidget {
  const MagazineScreen({super.key});
  @override
  ConsumerState<MagazineScreen> createState() => _MagazineScreenState();
}

class _MagazineScreenState extends ConsumerState<MagazineScreen> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('magazine'),
    );
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed(context)) return const NotAvailableScreen();
    final mag = ref.watch(magazineProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('mag.title'))),
      body: _async(context, mag, (m) {
        final track = context.track;
        final all = m.visible(track);
        if (all.isEmpty) return const NotAvailableScreen();
        final lang = context.lang;
        final featured = [
          for (final s in all)
            if (s.featured) s,
        ];
        final results = _query.trim().isEmpty ? null : m.search(_query, track);
        return CustomScrollView(
          slivers: [
            if (m.ticker.isNotEmpty)
              SliverToBoxAdapter(
                child: _Ticker(items: [for (final t in m.ticker) t.of(lang)]),
              ),
            SliverToBoxAdapter(
              child: _Masthead(count: all.length, mag: m),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: TextField(
                  key: const Key('mag-search'),
                  controller: _q,
                  onChanged: (v) => setState(() => _query = v),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    hintText: context.t('mag.search.hint'),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: context.t('common.close'),
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() {
                              _q.clear();
                              _query = '';
                            }),
                          ),
                  ),
                ),
              ),
            ),
            if (results != null) ...[
              SliverToBoxAdapter(
                child: SectionTitle(
                  context.t('mag.search.results', {'n': results.length}),
                ),
              ),
              if (results.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      context.t('mag.search.none'),
                      style: context.tx.bodyMedium,
                    ),
                  ),
                ),
              _storyList(results.take(60).toList(), m),
            ] else ...[
              if (featured.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionTitle(context.t('mag.featured')),
                ),
                SliverToBoxAdapter(
                  child: _FeaturedCarousel(stories: featured, mag: m),
                ),
              ],
              if (m.stats.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: SectionTitle(context.t('mag.numbers')),
                ),
                SliverToBoxAdapter(child: _StatGrid(stats: m.stats)),
              ],
              if (_timelineStories(m, track).length > 2) ...[
                SliverToBoxAdapter(
                  child: SectionTitle(
                    context.t('mag.timeline'),
                    action: context.t('common.seeAll'),
                    onAction: () => context.push('/magazine/timeline'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _TimelineStrip(stories: _timelineStories(m, track)),
                ),
              ],
              SliverToBoxAdapter(
                child: SectionTitle(context.t('mag.sections')),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: m.sections.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = m.sections[i];
                    final n = m.visible(track, section: s.key).length;
                    if (n == 0) return const SizedBox.shrink();
                    return _SectionTile(section: s, count: n, lang: lang);
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SoftButton(
                          key: const Key('mag-datadesk'),
                          label: context.t('lab.data_desk.title'),
                          icon: Icons.query_stats_rounded,
                          onPressed: () => context.push('/datadesk'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SoftButton(
                          label: context.t('lab.poster_wall.title'),
                          icon: Icons.newspaper_rounded,
                          onPressed: () => context.push('/lab/poster_wall'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: SoftButton(
                    key: const Key('mag-sources'),
                    label: context.t('mag.allSources'),
                    icon: Icons.library_books_rounded,
                    onPressed: () => context.push('/magazine/sources'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _HelpStrip()),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }

  Widget _storyList(List<MagStory> stories, Magazine m) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: SliverList.separated(
      itemCount: stories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => StoryCard(story: stories[i], mag: m),
    ),
  );
}

class _Masthead extends StatelessWidget {
  final int count;
  final Magazine mag;
  const _Masthead({required this.count, required this.mag});

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final stat = mag.stats.isEmpty
        ? null
        : mag.stats[DateTime.now().day % mag.stats.length];
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ink,
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A0B10), _ink],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('mag.kicker', {'n': count}).toUpperCase(),
            style: context.tx.labelSmall?.copyWith(
              color: const Color(0xFFFF5A67),
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('mag.title'),
            style: context.tx.displaySmall?.copyWith(
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.t('mag.sub'),
            style: context.tx.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (stat != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    stat.value,
                    style: context.tx.headlineMedium?.copyWith(
                      color: const Color(0xFFFF5A67),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stat.label.of(lang),
                      style: context.tx.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturedCarousel extends StatefulWidget {
  final List<MagStory> stories;
  final Magazine mag;
  const _FeaturedCarousel({required this.stories, required this.mag});
  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  final _page = PageController(viewportFraction: 0.88);
  int _i = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = 330 * textScaleOf(context).clamp(1.0, 1.5);
    return Column(
      children: [
        SizedBox(
          height: h,
          child: PageView.builder(
            key: const Key('mag-featured'),
            controller: _page,
            itemCount: widget.stories.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _CoverCard(story: widget.stories[i], mag: widget.mag),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var k = 0; k < widget.stories.length; k++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: k == _i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: k == _i ? context.c.coral : context.c.outline,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Big cover: documentary photo (or the section colour), the headline number and the title.
class _CoverCard extends StatelessWidget {
  final MagStory story;
  final Magazine mag;
  const _CoverCard({required this.story, required this.mag});

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final sec = mag.section(story.section);
    final accent = sec?.accent ?? _blood;
    return Tap(
      onTap: () => context.push('/magazine/story/${story.slug}'),
      semanticLabel: story.title.of(lang),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _CoverBackground(story: story, mag: mag, accent: accent),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (sec?.title.of(lang) ?? '').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tx.labelSmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  if (story.stat.isNotEmpty)
                    Text(
                      story.stat,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.tx.displaySmall?.copyWith(
                        color: Color.lerp(accent, Colors.white, 0.25),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    story.title.of(lang),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: context.tx.titleLarge?.copyWith(
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.t('mag.format.${story.format}')} · ${context.t('mag.minutes', {'n': story.minutes})}',
                    style: context.tx.labelMedium?.copyWith(
                      color: Colors.white70,
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

class _CoverBackground extends StatelessWidget {
  final MagStory story;
  final Magazine mag;
  final Color accent;
  const _CoverBackground({
    required this.story,
    required this.mag,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        story.photo.isNotEmpty && mag.photos.containsKey(story.photo);
    final gradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(accent, _ink, 0.35)!, _ink],
        ),
      ),
    );
    final background = hasPhoto
        ? ColorFiltered(
            // a dark duotone keeps photos sombre and the text readable
            colorFilter: ColorFilter.mode(
              Color.lerp(accent, _ink, 0.55)!.withValues(alpha: 0.55),
              BlendMode.multiply,
            ),
            child: Image.asset(
              Magazine.photoAsset(story.photo),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => gradient,
            ),
          )
        : gradient;
    if (story.motif.isEmpty) return background;
    // The story's motif, large and faint, as on the website's covers.
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest.shortestSide * (hasPhoto ? 0.62 : 0.8);
        return Stack(
          fit: StackFit.expand,
          children: [
            background,
            Positioned(
              right: -size * 0.12,
              top: box.maxHeight * 0.06,
              width: size,
              height: size,
              child: Opacity(
                opacity: hasPhoto ? 0.28 : 0.42,
                child: Image.asset(
                  Magazine.motifAsset(story.motif),
                  color: Color.lerp(accent, Colors.white, 0.45),
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The scrolling "FACT" strip from the website's home page.
class _Ticker extends StatefulWidget {
  final List<String> items;
  const _Ticker({required this.items});
  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> {
  final _scroll = ScrollController();
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    _timer = null;
    // Moves only when motion is allowed; otherwise it is a swipeable strip.
    if (!context.reducedMotion) {
      _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
        if (!_scroll.hasClients) return;
        final max = _scroll.position.maxScrollExtent;
        final next = _scroll.offset + 1.2;
        _scroll.jumpTo(next >= max ? 0 : next);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [...widget.items, ...widget.items];
    return Container(
      height: 44,
      color: _ink,
      child: Row(
        children: [
          Container(
            color: _blood,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Text(
              'FACT',
              style: context.tx.labelSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 1.6,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('mag-ticker'),
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _blood,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      items[i],
                      style: context.tx.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The eight headline numbers from the website's home page.
class _StatGrid extends StatelessWidget {
  final List<MagStat> stats;
  const _StatGrid({required this.stats});
  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 10) / 2;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final s in stats)
                Container(
                  width: w,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          s.value,
                          style: context.tx.headlineMedium?.copyWith(
                            color: const Color(0xFFFF5A67),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.label.of(lang),
                        style: context.tx.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Case files and timelines in year order: the website's case timeline.
List<MagStory> _timelineStories(Magazine m, Track t) {
  final list = [
    for (final s in m.visible(t))
      if (s.year != null && (s.format == 'case-file' || s.format == 'timeline'))
        s,
  ];
  list.sort((a, b) => a.year!.compareTo(b.year!));
  return list;
}

class _TimelineStrip extends StatelessWidget {
  final List<MagStory> stories;
  const _TimelineStrip({required this.stories});
  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final c = context.c;
    return SizedBox(
      height: 190 * textScaleOf(context).clamp(1.0, 1.4),
      child: ListView.separated(
        key: const Key('mag-timeline'),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = stories[i];
          return SizedBox(
            width: 200,
            child: AppCard(
              onTap: () => context.push('/magazine/story/${s.slug}'),
              semanticLabel: '${s.year}: ${s.title.of(lang)}',
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _blood,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${s.year}',
                        style: context.tx.headlineSmall?.copyWith(
                          color: _blood,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      s.title.of(lang),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: context.tx.titleSmall?.copyWith(color: c.ink),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final MagSection section;
  final int count;
  final Lang lang;
  const _SectionTile({
    required this.section,
    required this.count,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    key: Key('mag-section-${section.key}'),
    onTap: () => context.push('/magazine/section/${section.key}'),
    semanticLabel: section.title.of(lang),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 48,
          decoration: BoxDecoration(
            color: section.accent,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title.of(lang), style: context.tx.titleMedium),
              const SizedBox(height: 2),
              Text(
                section.tagline.of(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.tx.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Pill('$count'),
      ],
    ),
  );
}

/// A story in a list: thumbnail, section, title, summary and reading time.
class StoryCard extends StatelessWidget {
  final MagStory story;
  final Magazine mag;
  const StoryCard({super.key, required this.story, required this.mag});

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final sec = mag.section(story.section);
    final accent = sec?.accent ?? _blood;
    return AppCard(
      key: Key('story-${story.slug}'),
      onTap: () => context.push('/magazine/story/${story.slug}'),
      semanticLabel: story.title.of(lang),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 92,
              height: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverBackground(story: story, mag: mag, accent: accent),
                  if (story.stat.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            story.stat,
                            style: context.tx.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('mag.format.${story.format}').toUpperCase(),
                  style: context.tx.labelSmall?.copyWith(
                    color: accent,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  story.title.of(lang),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: context.tx.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  story.dek.of(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.tx.bodySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('mag.minutes', {'n': story.minutes}) +
                      (story.minAge >= 18 ? ' · 18+' : ' · 16+'),
                  style: context.tx.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpStrip extends StatelessWidget {
  const _HelpStrip();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
    child: AppCard(
      color: context.c.coral.withValues(alpha: context.isDark ? 0.18 : 0.12),
      onTap: () => context.push('/safety'),
      semanticLabel: context.t('mag.help'),
      child: Row(
        children: [
          Icon(Icons.health_and_safety_rounded, color: context.c.coral),
          const SizedBox(width: 12),
          Expanded(
            child: Text(context.t('mag.help'), style: context.tx.bodyMedium),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    ),
  );
}

// ───────────────────────────── Section

class MagSectionScreen extends ConsumerWidget {
  final String sectionKey;
  const MagSectionScreen(this.sectionKey, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_allowed(context)) return const NotAvailableScreen();
    final lang = context.lang;
    return _async(context, ref.watch(magazineProvider), (m) {
      final sec = m.section(sectionKey);
      final stories = m.visible(context.track, section: sectionKey);
      if (sec == null || stories.isEmpty) return const NotAvailableScreen();
      return Scaffold(
        appBar: AppBar(title: Text(sec.title.of(lang))),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          itemCount: stories.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: sec.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sec.tagline.of(lang),
                      style: context.tx.bodyMedium?.copyWith(
                        color: context.c.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.t('mag.stories', {'n': stories.length}),
                      style: context.tx.labelMedium,
                    ),
                  ],
                ),
              );
            }
            return StoryCard(story: stories[i - 1], mag: m);
          },
        ),
      );
    });
  }
}

// ───────────────────────────── Story

class StoryScreen extends ConsumerStatefulWidget {
  final String slug;
  const StoryScreen(this.slug, {super.key});
  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final _scroll = ScrollController();
  final _sourcesKey = GlobalKey();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _showSource(
    BuildContext context,
    Magazine m,
    MagStory story,
    String id,
  ) {
    final s = m.sources[id];
    final n = story.citeNumber(id);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.t('common.source')} $n', style: ctx.tx.labelMedium),
            const SizedBox(height: 6),
            Text(s?.title ?? id, style: ctx.tx.titleMedium),
            if (s != null && s.publisher.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                [s.publisher, s.year].where((x) => x.isNotEmpty).join(', '),
                style: ctx.tx.bodySmall,
              ),
            ],
            if (s != null && s.url.isNotEmpty) ...[
              const SizedBox(height: 14),
              PrimaryButton(
                label: context.t('mag.openSource'),
                icon: Icons.open_in_new_rounded,
                onPressed: () => launchUrl(
                  Uri.parse(s.url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed(context)) return const NotAvailableScreen();
    final lang = context.lang;
    final c = context.c;
    return _async(context, ref.watch(magazineProvider), (m) {
      final story = m.story(widget.slug);
      if (story == null || !story.visibleTo(context.track)) {
        return const NotAvailableScreen();
      }
      final sec = m.section(story.section);
      final accent = sec?.accent ?? _blood;
      final bodies = ref.watch(storyBodiesProvider(story.section));
      final credit = m.photos[story.photo];
      final related = [
        for (final s in m.visible(context.track, section: story.section))
          if (s.slug != story.slug) s,
      ];
      final start = related.isEmpty
          ? 0
          : story.slug.hashCode.abs() % related.length;
      final more = [
        for (var i = 0; i < related.length && i < 3; i++)
          related[(start + i) % related.length],
      ];
      return Scaffold(
        body: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 300,
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _CoverBackground(story: story, mag: m, accent: accent),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                    if (story.stat.isNotEmpty)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              story.stat,
                              style: context.tx.displayMedium?.copyWith(
                                color: Color.lerp(accent, Colors.white, 0.2),
                              ),
                            ),
                            Text(
                              story.statLabel.of(lang),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: context.tx.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              sliver: SliverList.list(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Pill(
                        (sec?.title.of(lang) ?? story.section),
                        color: accent.withValues(alpha: 0.16),
                        foreground: c.ink,
                      ),
                      Pill(context.t('mag.format.${story.format}')),
                      Pill(story.minAge >= 18 ? '18+' : '16+'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: Text(
                      story.title.of(lang),
                      style: context.tx.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    story.dek.of(lang),
                    style: context.tx.bodyLarge?.copyWith(color: c.inkSoft),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${context.t('mag.byline')} · ${_date(story.date, lang)} · ${context.t('mag.minutes', {'n': story.minutes})}',
                    style: context.tx.labelMedium?.copyWith(color: c.inkSoft),
                  ),
                  if (story.cw.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Tap(
                      onTap: () => context.push('/safety'),
                      semanticLabel: context.t('mag.getHelp'),
                      child: InfoBanner(
                        icon: Icons.warning_amber_rounded,
                        color: c.warning,
                        title: context.t('mag.cwTitle'),
                        text:
                            '${context.t('mag.cw', {'topics': story.cw.join(', ')})} ${context.t('mag.getHelp')}.',
                      ),
                    ),
                  ],
                  if (story.keyNumbers.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      context.t('mag.keyNumbers'),
                      style: context.tx.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final k in story.keyNumbers)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                            left: BorderSide(color: accent, width: 4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              k.value,
                              style: context.tx.headlineSmall?.copyWith(
                                color: _blood,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              k.label.of(lang),
                              style: context.tx.bodyMedium,
                            ),
                            if (story.citeNumber(k.source) > 0)
                              InkWell(
                                onTap: () =>
                                    _showSource(context, m, story, k.source),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${context.t('common.source')} ${story.citeNumber(k.source)}',
                                    style: context.tx.labelSmall?.copyWith(
                                      color: c.primary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  bodies.when(
                    data: (b) {
                      final md = b[story.slug];
                      if (md == null) return Text(context.t('mag.error'));
                      return StoryText(
                        key: Key('story-text-${story.slug}'),
                        markdown: md.of(lang),
                        citeNumber: story.citeNumber,
                        onCite: (id) => _showSource(context, m, story, id),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('${context.t('mag.error')} $e'),
                  ),
                  if (story.mythClaim != null) ...[
                    const SizedBox(height: 18),
                    _MythBox(
                      claim: story.mythClaim!.of(lang),
                      truth: story.mythTruth!.of(lang),
                    ),
                  ],
                  if (story.actions.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    AppCard(
                      color: c.mint.withValues(
                        alpha: context.isDark ? 0.14 : 0.18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t('mag.actions'),
                            style: context.tx.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final a in story.actions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 20,
                                    color: c.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      a.of(lang),
                                      style: context.tx.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Text(
                    context.t('mag.sources'),
                    key: _sourcesKey,
                    style: context.tx.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < story.sources.length; i++)
                    _SourceRow(
                      n: i + 1,
                      id: story.sources[i],
                      source: m.sources[story.sources[i]],
                    ),
                  const SizedBox(height: 6),
                  Text(
                    context.t('mag.sourcesNote'),
                    style: context.tx.bodySmall,
                  ),
                  if (credit != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${context.t('mag.photo')}: ${credit.author}, ${credit.license}, Wikimedia Commons',
                      style: context.tx.bodySmall,
                    ),
                  ],
                  if (more.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(context.t('mag.more'), style: context.tx.titleMedium),
                    const SizedBox(height: 10),
                    for (final s in more)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StoryCard(story: s, mag: m),
                      ),
                  ],
                  const _HelpStrip(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MythBox extends StatelessWidget {
  final String claim;
  final String truth;
  const _MythBox({required this.claim, required this.truth});
  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _ink,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('mag.myth').toUpperCase(),
                  style: context.tx.labelSmall?.copyWith(
                    color: const Color(0xFFFF5A67),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“$claim”',
                  style: context.tx.titleMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            color: c.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('mag.truth').toUpperCase(),
                  style: context.tx.labelSmall?.copyWith(
                    color: c.success,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(truth, style: context.tx.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final int n;
  final String id;
  final MagSource? source;
  const _SourceRow({required this.n, required this.id, required this.source});
  @override
  Widget build(BuildContext context) {
    final s = source;
    final text = s == null
        ? id
        : '${s.title}${s.publisher.isEmpty ? '' : ' — ${s.publisher}'}${s.year.isEmpty ? '' : ', ${s.year}'}';
    return InkWell(
      onTap: s == null || s.url.isEmpty
          ? null
          : () => launchUrl(
              Uri.parse(s.url),
              mode: LaunchMode.externalApplication,
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 26,
              child: Text('$n.', style: context.tx.labelMedium),
            ),
            Expanded(
              child: Text(
                text,
                style: context.tx.bodySmall?.copyWith(color: context.c.ink),
              ),
            ),
            if (s != null && s.url.isNotEmpty)
              Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: context.c.inkSoft,
              ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Data Desk

class DataDeskScreen extends ConsumerStatefulWidget {
  const DataDeskScreen({super.key});
  @override
  ConsumerState<DataDeskScreen> createState() => _DataDeskScreenState();
}

class _DataDeskScreenState extends ConsumerState<DataDeskScreen> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('data_desk'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed(context)) return const NotAvailableScreen();
    final lang = context.lang;
    final mag = ref.watch(magazineProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.data_desk.title'))),
      body: _async(context, ref.watch(dataDeskProvider), (areas) {
        final total = areas.fold<int>(0, (n, a) => n + a.facts.length);
        final q = _query.trim().toLowerCase();
        bool hit(Fact f) =>
            q.isEmpty ||
            f.text.en.toLowerCase().contains(q) ||
            f.text.hg.toLowerCase().contains(q);
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Text(
              context.t('datadesk.sub', {'n': total}),
              style: context.tx.bodyMedium?.copyWith(color: context.c.inkSoft),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('datadesk-search'),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: context.t('datadesk.search'),
              ),
            ),
            const SizedBox(height: 12),
            for (final a in areas)
              if (a.facts.any(hit))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: Material(
                        type: MaterialType.transparency,
                        child: ExpansionTile(
                          key: PageStorageKey('area-${a.key}'),
                          initiallyExpanded: q.isNotEmpty,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            a.title.of(lang),
                            style: context.tx.titleMedium,
                          ),
                          subtitle: Text(
                            context.t('datadesk.facts', {
                              'n': a.facts.where(hit).length,
                            }),
                            style: context.tx.bodySmall,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            12,
                          ),
                          children: [
                            for (final f in a.facts.where(hit))
                              _FactTile(
                                fact: f,
                                source: mag?.sources[f.source],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        );
      }),
    );
  }
}

class _FactTile extends StatelessWidget {
  final Fact fact;
  final MagSource? source;
  const _FactTile({required this.fact, required this.source});
  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final s = source;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fact.value.isNotEmpty)
            Text(
              fact.value,
              style: context.tx.titleLarge?.copyWith(color: _blood),
            ),
          Text(fact.text.of(lang), style: context.tx.bodyMedium),
          if (s != null) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: s.url.isEmpty
                  ? null
                  : () => launchUrl(
                      Uri.parse(s.url),
                      mode: LaunchMode.externalApplication,
                    ),
              child: Text(
                '${context.t('common.source')}: ${s.publisher.isEmpty ? s.title : s.publisher}${fact.year.isEmpty ? '' : ' (${fact.year})'}',
                style: context.tx.labelSmall?.copyWith(
                  color: context.c.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────── Case timeline (full)

class MagTimelineScreen extends ConsumerWidget {
  const MagTimelineScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_allowed(context)) return const NotAvailableScreen();
    final lang = context.lang;
    final c = context.c;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('mag.timeline'))),
      body: _async(context, ref.watch(magazineProvider), (m) {
        final items = _timelineStories(m, context.track);
        return ListView.builder(
          key: const Key('timeline-list'),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final s = items[i];
            final newYear = i == 0 || items[i - 1].year != s.year;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 58,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        newYear ? '${s.year}' : '',
                        style: context.tx.titleMedium?.copyWith(color: _blood),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 2,
                        height: 18,
                        color: i == 0 ? Colors.transparent : c.outline,
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: newYear ? _blood : c.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: _blood, width: 2),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2,
                          color: i == items.length - 1
                              ? Colors.transparent
                              : c.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () => context.push('/magazine/story/${s.slug}'),
                        semanticLabel: '${s.year}: ${s.title.of(lang)}',
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title.of(lang),
                              style: context.tx.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.dek.of(lang),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.tx.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

// ───────────────────────────── All sources

class MagSourcesScreen extends ConsumerStatefulWidget {
  const MagSourcesScreen({super.key});
  @override
  ConsumerState<MagSourcesScreen> createState() => _MagSourcesScreenState();
}

class _MagSourcesScreenState extends ConsumerState<MagSourcesScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    if (!_allowed(context)) return const NotAvailableScreen();
    return Scaffold(
      appBar: AppBar(title: Text(context.t('mag.allSources'))),
      body: _async(context, ref.watch(magazineProvider), (m) {
        final all = m.sources.entries.toList()
          ..sort(
            (a, b) => a.value.title.toLowerCase().compareTo(
              b.value.title.toLowerCase(),
            ),
          );
        final q = _q.trim().toLowerCase();
        final shown = q.isEmpty
            ? all
            : [
                for (final e in all)
                  if ('${e.value.title} ${e.value.publisher} ${e.value.year}'
                      .toLowerCase()
                      .contains(q))
                    e,
              ];
        return ListView.builder(
          key: const Key('sources-list'),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          itemCount: shown.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t('mag.allSources.sub', {'n': all.length}),
                      style: context.tx.bodyMedium?.copyWith(
                        color: context.c.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      key: const Key('sources-search'),
                      onChanged: (v) => setState(() => _q = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: context.t('mag.allSources.search'),
                      ),
                    ),
                  ],
                ),
              );
            }
            final e = shown[i - 1];
            return _SourceRow(n: i, id: e.key, source: e.value);
          },
        );
      }),
    );
  }
}
