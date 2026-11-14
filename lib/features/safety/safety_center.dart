import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

const _helpIcons = <String, IconData>{
  'emergency': Icons.sos_rounded,
  'child': Icons.child_care_rounded,
  'women': Icons.woman_rounded,
  'cyber': Icons.security_rounded,
  'mind': Icons.psychology_rounded,
  'hiv': Icons.bloodtype_rounded,
};

/// Calm, always-reachable help. Calls only ever start from an explicit tap
/// followed by a confirmation.
class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key});

  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final track = context.track;
    final c = context.c;
    final lines = [
      for (final h in Helpline.all)
        if (!track.isChild || h.forKids) h,
    ];
    final guides = content.visible(content.safetyGuidance, track);
    return Scaffold(
      appBar: AppBar(title: Text(context.t('safety.title'))),
      body: PageBody(
        children: [
          const ScreenPicture(screen: 'safety', scene: 'stop', domain: 'd14'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF12855F), Color(0xFF2BAE9E)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('safety.hero.title'),
                        style: context.tx.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.t('safety.hero.body'),
                        style: context.tx.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Mascot(size: 76, mood: Mood.calm),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InfoBanner(
            icon: Icons.emergency_rounded,
            color: c.danger,
            text: context.t('safety.emergency'),
          ),
          const SizedBox(height: 20),
          Text(context.t('safety.lines'), style: context.tx.headlineSmall),
          const SizedBox(height: 12),
          for (final h in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                key: Key('help-${h.id}'),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (h.id == 'emergency' ? c.danger : c.primary)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _helpIcons[h.id],
                            color: h.id == 'emergency' ? c.danger : c.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.t('help.${h.id}.name'),
                                style: context.tx.titleMedium,
                              ),
                              Text(
                                context.t('help.${h.id}.desc'),
                                style: context.tx.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            key: Key('call-${h.id}'),
                            label: '${context.t('call.verb')} ${h.number}',
                            icon: Icons.call_rounded,
                            color: h.id == 'emergency' ? c.danger : c.primary,
                            foreground: h.id == 'emergency'
                                ? Colors.white
                                : null,
                            onPressed: () => confirmCall(
                              context,
                              h.number,
                              context.t('help.${h.id}.name'),
                            ),
                          ),
                        ),
                        if (h.url != null) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: SoftButton(
                              label: context.t('safety.website'),
                              icon: Icons.open_in_new_rounded,
                              onPressed: () => openUrl(context, h.url!),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (content.ref(h.ref) != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () =>
                              showRefSheet(context, content.ref(h.ref)!),
                          child: Text(
                            '${context.t('common.source')}: ${content.ref(h.ref)!.publisher}',
                            style: context.tx.bodySmall,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(context.t('safety.verify'), style: context.tx.bodySmall),
          if (guides.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(context.t('safety.guides'), style: context.tx.headlineSmall),
            const SizedBox(height: 12),
            for (final g in guides)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  key: Key('guide-${g.id}'),
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tap(
                        onTap: () =>
                            setState(() => _open = _open == g.id ? null : g.id),
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
                              for (var i = 0; i < g.steps.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: c.primarySoft,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${i + 1}',
                                          textScaler: TextScaler.noScaling,
                                          style: context.tx.labelMedium,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          context.lx(g.steps[i]),
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
          ],
          const SizedBox(height: 14),
          InfoBanner(
            icon: Icons.info_outline_rounded,
            color: c.warning,
            title: context.t('safety.confidential.title'),
            text: context.t(
              track.isMinor
                  ? 'safety.confidential.minor'
                  : 'safety.confidential.adult',
            ),
          ),
          const SizedBox(height: 14),
          SoftButton(
            label: context.t('lab.support_circle.title'),
            icon: Icons.groups_rounded,
            onPressed: () => context.push('/lab/support_circle'),
          ),
        ],
      ),
    );
  }
}
