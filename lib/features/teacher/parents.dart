import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/illustrations.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

class ParentsScreen extends ConsumerStatefulWidget {
  const ParentsScreen({super.key});

  @override
  ConsumerState<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends ConsumerState<ParentsScreen> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final c = context.c;
    final guide = content.parentGuide;
    _open ??= guide.isEmpty ? null : guide.first.id;
    return Scaffold(
      appBar: AppBar(title: Text(context.t('me.parents.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(screen: 'parents'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2BAE9E), Color(0xFF3D8BFF)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SceneArt(kind: 'family', seed: 7, height: 120),
                const SizedBox(height: 10),
                Text(
                  context.t('parents.hero'),
                  style: context.tx.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.t('parents.hero.body'),
                  style: context.tx.bodyMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final g in guide)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                key: Key('parent-${g.id}'),
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tap(
                      onTap: () =>
                          setState(() => _open = _open == g.id ? '' : g.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.lx(g.title),
                                style: context.tx.titleMedium,
                              ),
                            ),
                            Icon(
                              _open == g.id
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: c.inkSoft,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_open == g.id)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            for (final p in g.points)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 20,
                                      color: c.success,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        context.lx(p),
                                        style: context.tx.bodyLarge,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          AppCard(
            onTap: () => context.push('/settings'),
            child: Row(
              children: [
                Icon(Icons.lock_rounded, color: c.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('parents.lock'),
                        style: context.tx.titleMedium,
                      ),
                      Text(
                        context.t('parents.lock.body'),
                        style: context.tx.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.inkSoft),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SoftButton(
            label: context.t('safety.title'),
            icon: Icons.health_and_safety_rounded,
            onPressed: () => context.push('/safety'),
          ),
          const SizedBox(height: 12),
          const ReviewNote(),
        ],
      ),
    );
  }
}
