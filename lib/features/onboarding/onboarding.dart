import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../settings/educator.dart';
import 'splash.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pages = 6;
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _to(int p) {
    if (p < 0 || p >= _pages) return;
    if (context.reducedMotion) {
      _ctrl.jumpToPage(p);
    } else {
      _ctrl.animateToPage(
        p,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    ref.read(settingsProvider.notifier).completeOnboarding();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final c = context.c;
    final canNext = _page != 2 || s.track != null;
    final last = _page == _pages - 1;
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _to(_page - 1);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 20, 0),
                child: Row(
                  children: [
                    Opacity(
                      opacity: _page == 0 ? 0 : 1,
                      child: IconButton(
                        tooltip: context.t('common.back'),
                        onPressed: _page == 0 ? null : () => _to(_page - 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Expanded(
                      child: Semantics(
                        label: context.t('onb.step', {
                          'n': _page + 1,
                          'total': _pages,
                        }),
                        child: Row(
                          children: [
                            for (var i = 0; i < _pages; i++)
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: i <= _page
                                        ? c.primary
                                        : c.primarySoft,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _ctrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _page = p),
                  children: const [
                    _Welcome(),
                    _Privacy(),
                    _TrackStep(),
                    _LangStep(),
                    _AccessStep(),
                    _InterestStep(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  key: const Key('onb-next'),
                  label: context.t(
                    last
                        ? 'onb.start'
                        : (_page == 0 ? 'onb.letsgo' : 'common.next'),
                  ),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: canNext
                      ? (last ? _finish : () => _to(_page + 1))
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String title;
  final String? body;
  final List<Widget> children;
  final Widget? art;
  const _Step({
    required this.title,
    this.body,
    required this.children,
    this.art,
  });

  @override
  Widget build(BuildContext context) => PageBody(
    padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
    children: [
      if (art != null) Center(child: art),
      if (art != null) const SizedBox(height: 18),
      Semantics(
        header: true,
        child: Text(title, style: context.tx.displaySmall),
      ),
      if (body != null) ...[
        const SizedBox(height: 10),
        Text(
          body!,
          style: context.tx.bodyLarge?.copyWith(color: context.c.inkSoft),
        ),
      ],
      const SizedBox(height: 20),
      ...children,
    ],
  );
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) => _Step(
    art: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Palette.dark, Color(0xFF2B2466)],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Mascot(size: 120, mood: Mood.happy),
          const SizedBox(height: 10),
          const Wordmark(size: 30, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            context.t('brand.tagline'),
            style: context.tx.labelLarge?.copyWith(color: Palette.mint),
          ),
        ],
      ),
    ),
    title: context.t('onb.welcome.title'),
    body: context.t('onb.welcome.body'),
    children: [
      for (final (icon, key) in const [
        (Icons.science_rounded, 'onb.welcome.p1'),
        (Icons.do_not_disturb_on_rounded, 'onb.welcome.p2'),
        (Icons.wifi_off_rounded, 'onb.welcome.p3'),
      ])
        _Bullet(icon: icon, text: context.t(key)),
      const SizedBox(height: 4),
      Text(context.t('onb.welcome.note'), style: context.tx.bodySmall),
    ],
  );
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Bullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.c.primarySoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            size: 20,
            color: context.isDark ? Colors.white : context.c.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(text, style: context.tx.bodyLarge),
          ),
        ),
      ],
    ),
  );
}

class _Privacy extends StatelessWidget {
  const _Privacy();

  @override
  Widget build(BuildContext context) => _Step(
    art: Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: context.c.mint.withValues(alpha: 0.35),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.lock_person_rounded,
        size: 54,
        color: context.c.success,
      ),
    ),
    title: context.t('onb.privacy.title'),
    body: context.t('onb.privacy.body'),
    children: [
      for (final (icon, key) in const [
        (Icons.person_off_rounded, 'onb.privacy.p1'),
        (Icons.cloud_off_rounded, 'onb.privacy.p2'),
        (Icons.block_rounded, 'onb.privacy.p3'),
        (Icons.delete_forever_rounded, 'onb.privacy.p4'),
      ])
        _Bullet(icon: icon, text: context.t(key)),
      InfoBanner(
        icon: Icons.info_outline_rounded,
        text: context.t('onb.privacy.honest'),
        color: context.c.warning,
      ),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => context.push('/legal/privacy'),
          child: Text(context.t('settings.privacy')),
        ),
      ),
    ],
  );
}

class _TrackStep extends ConsumerWidget {
  const _TrackStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return _Step(
      title: context.t('onb.track.title'),
      body: context.t('onb.track.body'),
      children: [
        for (final t in s.selectableTracks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TrackTile(
              track: t,
              selected: s.track == t,
              onTap: () => changeTrack(context, ref, t),
            ),
          ),
        const SizedBox(height: 4),
        Text(context.t('onb.track.note'), style: context.tx.bodySmall),
      ],
    );
  }
}

class TrackTile extends StatelessWidget {
  final Track track;
  final bool selected;
  final VoidCallback onTap;
  const TrackTile({
    super.key,
    required this.track,
    required this.selected,
    required this.onTap,
  });

  static const _colors = [
    Palette.sun,
    Palette.mint,
    Palette.blue,
    Palette.coral,
    Palette.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Tap(
      key: Key('track-${track.name}'),
      onTap: onTap,
      child: Semantics(
        selected: selected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? c.primarySoft : c.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? c.primary : c.outline,
              width: selected ? 2.2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _colors[track.index],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  track.ages,
                  textScaler: TextScaler.noScaling,
                  style: context.tx.titleSmall?.copyWith(
                    color: track == Track.e ? Colors.white : Palette.dark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(track.nameKey),
                      style: context.tx.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(context.t(track.descKey), style: context.tx.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? c.primary : c.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangStep extends ConsumerWidget {
  const _LangStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final c = context.c;
    const samples = {
      Lang.hg: 'Periods biology hain, sharam ki cheez nahi.',
      Lang.en: 'Periods are biology, not something to be ashamed of.',
    };
    return _Step(
      title: context.t('onb.lang.title'),
      body: context.t('onb.lang.body'),
      children: [
        for (final l in Lang.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Tap(
              key: Key('lang-${l.name}'),
              onTap: () => ref.read(settingsProvider.notifier).setLang(l),
              child: Semantics(
                selected: s.lang == l,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: s.lang == l ? c.primarySoft : c.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: s.lang == l ? c.primary : c.outline,
                      width: s.lang == l ? 2.2 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.label, style: context.tx.titleLarge),
                            const SizedBox(height: 4),
                            Text(
                              samples[l]!,
                              style: context.tx.bodyMedium?.copyWith(
                                color: c.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        s.lang == l
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        color: s.lang == l ? c.primary : c.outline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AccessStep extends ConsumerWidget {
  const _AccessStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) => _Step(
    title: context.t('onb.access.title'),
    body: context.t('onb.access.body'),
    children: const [AccessibilityControls()],
  );
}

/// Text size, motion, contrast and theme. Shared by onboarding and settings.
class AccessibilityControls extends ConsumerWidget {
  const AccessibilityControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.t('settings.textSize'),
                style: context.tx.titleMedium,
              ),
              Row(
                children: [
                  const Text(
                    'A',
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(fontSize: 13),
                  ),
                  Expanded(
                    child: Slider(
                      value: s.textScale,
                      min: 0.85,
                      max: 1.6,
                      divisions: 5,
                      label: '${(s.textScale * 100).round()}%',
                      semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                      onChanged: n.setTextScale,
                    ),
                  ),
                  const Text(
                    'A',
                    textScaler: TextScaler.noScaling,
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              Text(
                context.t('settings.textSample'),
                style: context.tx.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _SwitchTile(
          icon: Icons.motion_photos_off_rounded,
          title: context.t('settings.reducedMotion'),
          subtitle: context.t('settings.reducedMotion.sub'),
          value: s.reducedMotion,
          onChanged: n.setReducedMotion,
        ),
        const SizedBox(height: 10),
        _SwitchTile(
          icon: Icons.contrast_rounded,
          title: context.t('settings.highContrast'),
          subtitle: context.t('settings.highContrast.sub'),
          value: s.highContrast,
          onChanged: n.setHighContrast,
        ),
        const SizedBox(height: 10),
        AppCard(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t('settings.theme'), style: context.tx.titleMedium),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (mode, key, icon) in const [
                    (
                      ThemeMode.system,
                      'settings.theme.system',
                      Icons.phone_android_rounded,
                    ),
                    (
                      ThemeMode.light,
                      'settings.theme.light',
                      Icons.light_mode_rounded,
                    ),
                    (
                      ThemeMode.dark,
                      'settings.theme.dark',
                      Icons.dark_mode_rounded,
                    ),
                  ])
                    ChoicePill(
                      label: context.t(key),
                      icon: icon,
                      selected: s.theme == mode,
                      onTap: () => n.setTheme(mode),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
    child: MergeSemantics(
      child: Row(
        children: [
          Icon(icon, color: context.c.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.tx.titleMedium),
                Text(subtitle, style: context.tx.bodySmall),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    ),
  );
}

class _InterestStep extends ConsumerWidget {
  const _InterestStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final content = ref.watch(contentProvider);
    final domains = content.domainsFor(s.track ?? Track.c);
    return _Step(
      title: context.t('onb.interest.title'),
      body: context.t('onb.interest.body'),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final d in domains)
              ChoicePill(
                label: context.lx(d.titleFor(s.track ?? Track.c)),
                selected: s.interests.contains(d.id),
                onTap: () {
                  final next = [...s.interests];
                  next.contains(d.id) ? next.remove(d.id) : next.add(d.id);
                  ref.read(settingsProvider.notifier).setInterests(next);
                },
              ),
          ],
        ),
        const SizedBox(height: 22),
        AppCard(
          onTap: () => showEducatorLockSheet(context, ref),
          child: Row(
            children: [
              Icon(
                s.locked ? Icons.lock_rounded : Icons.school_rounded,
                color: context.c.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.t(s.locked ? 'lock.isOn' : 'onb.school.title'),
                      style: context.tx.titleMedium,
                    ),
                    Text(
                      context.t('onb.school.body'),
                      style: context.tx.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.c.inkSoft),
            ],
          ),
        ),
      ],
    );
  }
}
