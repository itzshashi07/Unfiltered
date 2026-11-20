import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n.dart';
import 'core/theme.dart';
import 'data/search.dart';
import 'data/store.dart';
import 'features/home/shell.dart';
import 'features/labs/body_lab.dart';
import 'features/labs/games.dart';
import 'features/labs/myth_buster.dart';
import 'features/labs/period_lab.dart';
import 'features/labs/protection_lab.dart';
import 'features/labs/poster_wall.dart';
import 'features/labs/puberty_lab.dart';
import 'features/labs/scenarios.dart';
import 'features/lessons/domain_screen.dart';
import 'features/lessons/lesson_screen.dart';
import 'features/library/library.dart';
import 'features/magazine/magazine_screens.dart';
import 'features/onboarding/onboarding.dart';
import 'features/onboarding/splash.dart';
import 'features/quiz/quiz_screens.dart';
import 'features/safety/safety_center.dart';
import 'features/settings/legal.dart';
import 'features/settings/settings.dart';
import 'features/teacher/parents.dart';
import 'features/teacher/teacher.dart';

/// Offline FAQ search index, built once on first use.
final searchProvider = Provider<SearchEngine>((ref) {
  final c = ref.watch(contentProvider);
  return SearchEngine(faqs: c.faqs, myths: c.myths, glossary: c.glossary);
});

/// Where each lab key (also used by `Lesson.interactive`) lives.
String labRoute(String key) => switch (key) {
  'consent_sim' => '/scenarios/consent',
  'relationship_radar' => '/scenarios/relationship',
  'digital_safety' => '/scenarios/digital',
  'communication' => '/scenarios/communication',
  'ask' => '/home?tab=3',
  'magazine' => '/magazine',
  'data_desk' => '/datadesk',
  _ => '/lab/$key',
};

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final s = ref.read(settingsProvider);
      final loc = state.matchedLocation;
      final ready = s.onboarded && s.track != null;
      if (!ready &&
          loc != '/' &&
          loc != '/onboarding' &&
          !loc.startsWith('/legal')) {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(
        path: '/home',
        builder: (_, s) => ShellScreen(
          initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/domain/:id',
        builder: (_, s) => DomainScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, s) => LessonScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/lab/:key',
        builder: (_, s) => switch (s.pathParameters['key']) {
          'body_lab' => const BodyLabScreen(),
          'puberty_lab' => const PubertyLabScreen(),
          'period_lab' => const PeriodLabScreen(),
          'myth_buster' => MythBusterScreen(
            domain: s.uri.queryParameters['domain'],
          ),
          'protection_lab' => const ProtectionLabScreen(),
          'sti_match' => const StiMatchScreen(),
          'support_circle' => const SupportCircleScreen(),
          'signals' => const SignalsScreen(),
          'digital_challenge' => const DigitalChallengeScreen(),
          'poster_wall' => const PosterWallScreen(),
          _ => const NotAvailableScreen(),
        },
      ),
      GoRoute(
        path: '/scenarios/:module',
        builder: (_, s) => ScenarioListScreen(s.pathParameters['module']!),
      ),
      GoRoute(
        path: '/scenario/:id',
        builder: (_, s) => ScenarioScreen(s.pathParameters['id']!),
      ),
      GoRoute(path: '/magazine', builder: (_, _) => const MagazineScreen()),
      GoRoute(
        path: '/magazine/section/:key',
        builder: (_, s) => MagSectionScreen(s.pathParameters['key']!),
      ),
      GoRoute(
        path: '/magazine/story/:slug',
        builder: (_, s) => StoryScreen(s.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/magazine/timeline',
        builder: (_, _) => const MagTimelineScreen(),
      ),
      GoRoute(
        path: '/magazine/sources',
        builder: (_, _) => const MagSourcesScreen(),
      ),
      GoRoute(path: '/datadesk', builder: (_, _) => const DataDeskScreen()),
      GoRoute(path: '/quiz', builder: (_, _) => const QuizHubScreen()),
      GoRoute(
        path: '/quiz/:kind/:id',
        builder: (_, s) => QuizScreen(
          kind: s.pathParameters['kind']!,
          id: s.pathParameters['id']!,
        ),
      ),
      GoRoute(path: '/glossary', builder: (_, _) => const GlossaryScreen()),
      GoRoute(
        path: '/achievements',
        builder: (_, _) => const AchievementsScreen(),
      ),
      GoRoute(path: '/notes', builder: (_, _) => const NotesScreen()),
      GoRoute(path: '/bookmarks', builder: (_, _) => const BookmarksScreen()),
      GoRoute(path: '/references', builder: (_, _) => const ReferencesScreen()),
      GoRoute(path: '/safety', builder: (_, _) => const SafetyScreen()),
      GoRoute(path: '/teacher', builder: (_, _) => const TeacherScreen()),
      GoRoute(
        path: '/teacher/lesson/:id',
        builder: (_, s) => TeacherLessonScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/teacher/present/:id',
        builder: (_, s) => PresentScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/teacher/quiz/:track/:domain',
        builder: (_, s) => GroupQuizScreen(
          track: TrackX.parse(s.pathParameters['track']) ?? Track.c,
          domain: s.pathParameters['domain']!,
        ),
      ),
      GoRoute(path: '/parents', builder: (_, _) => const ParentsScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: '/legal/:doc',
        builder: (_, s) => LegalScreen(s.pathParameters['doc']!),
      ),
    ],
    errorBuilder: (_, _) => const NotAvailableScreen(),
  );
});

class UnfilteredApp extends ConsumerWidget {
  const UnfilteredApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'UNFILTERED',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(
        dark: false,
        highContrast: s.highContrast,
        lang: s.lang,
      ),
      darkTheme: buildTheme(
        dark: true,
        highContrast: s.highContrast,
        lang: s.lang,
      ),
      themeMode: s.theme,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // App text size multiplies the system setting; capped so layouts hold.
        final system = mq.textScaler.scale(100) / 100;
        final scale = (system * s.textScale).clamp(0.8, 2.0);
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Theme.of(context).colorScheme.surface,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(scale)),
            child: AppScope(
              lang: s.lang,
              track: s.track ?? Track.c,
              reducedMotion: s.reducedMotion,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

/// Shown when a route does not exist or content is not part of this track.
class NotAvailableScreen extends StatelessWidget {
  const NotAvailableScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 56,
              color: context.c.inkSoft,
            ),
            const SizedBox(height: 16),
            Text(
              context.t('restricted.title'),
              style: context.tx.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.t('restricted.body'),
              style: context.tx.bodyMedium?.copyWith(color: context.c.inkSoft),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: Text(context.t('common.home')),
            ),
          ],
        ),
      ),
    ),
  );
}
