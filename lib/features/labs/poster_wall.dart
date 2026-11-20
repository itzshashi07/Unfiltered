import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';

/// Poster Wall: hard facts as newsprint posters, for learners aged 16 and over.
class PosterWallScreen extends ConsumerStatefulWidget {
  const PosterWallScreen({super.key});

  @override
  ConsumerState<PosterWallScreen> createState() => _PosterWallScreenState();
}

class _PosterWallScreenState extends ConsumerState<PosterWallScreen> {
  final _page = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(progressProvider.notifier).visitLab('poster_wall'),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _go(int i, int n) {
    if (i < 0 || i >= n) return;
    // animateToPage needs a non-zero duration; jump when animations are off.
    if (MediaQuery.of(context).disableAnimations) {
      _page.jumpToPage(i);
    } else {
      _page.animateToPage(
        i,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // The posters report sexual violence data: older tracks only.
    if (context.track.index < Track.d.index) return const NotAvailableScreen();
    final posters = ref.watch(contentProvider).posters;
    if (posters.isEmpty) return const NotAvailableScreen();
    final lang = context.lang;
    final c = context.c;
    final p = posters[_index.clamp(0, posters.length - 1)];
    return Scaffold(
      appBar: AppBar(title: Text(context.t('lab.poster_wall.title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Text(
              context.t('posters.intro'),
              style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
            ),
          ),
          Expanded(
            child: PageView.builder(
              key: const Key('poster-pages'),
              controller: _page,
              itemCount: posters.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final q = posters[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1080 / 1350,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: InteractiveViewer(
                          maxScale: 4,
                          child: Image.asset(
                            q.asset(lang),
                            fit: BoxFit.contain,
                            semanticLabel:
                                '${q.kicker.of(lang)}: ${q.title.of(lang)}',
                            errorBuilder: (_, _, _) => ColoredBox(
                              color: c.surfaceAlt,
                              child: Center(
                                child: Text(
                                  q.title.of(lang),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                IconButton(
                  tooltip: context.t('common.back'),
                  onPressed: _index > 0
                      ? () => _go(_index - 1, posters.length)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        p.title.of(lang),
                        style: context.tx.titleMedium,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_index + 1} / ${posters.length}',
                        style: context.tx.bodySmall?.copyWith(color: c.inkSoft),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.t('common.next'),
                  onPressed: _index < posters.length - 1
                      ? () => _go(_index + 1, posters.length)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Text(
              '${context.t('common.source')}: ${p.source}\n${context.t('posters.note')}',
              style: context.tx.bodySmall?.copyWith(color: c.inkSoft),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
