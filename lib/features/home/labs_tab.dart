import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../quiz/knowledge_test.dart';
import 'cards.dart';

class LabsTab extends ConsumerWidget {
  const LabsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final labs = content.labsFor(track);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    context.t('labs.title'),
                    style: context.tx.displaySmall,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.t('labs.sub'),
                  style: context.tx.bodyMedium?.copyWith(
                    color: context.c.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220 * textScaleOf(context),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 188 * textScaleOf(context),
            ),
            delegate: SliverChildBuilderDelegate(
              childCount: labs.length,
              (context, i) => LabCard(
                labKey: labs[i],
                onTap: () => context.push(labRoute(labs[i])),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Text(
              context.t('labs.test'),
              style: context.tx.headlineSmall,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: KnowledgeTestCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: LabCard(
              labKey: 'quiz',
              wide: true,
              onTap: () => context.push('/quiz'),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: LabCard(
              labKey: 'final',
              wide: true,
              onTap: () => context.push('/quiz/final/all'),
            ),
          ),
        ),
      ],
    );
  }
}
