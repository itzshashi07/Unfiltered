// End-to-end test on a real device or emulator:
//   flutter test integration_test -d <device-id>
//
// Covers: first run, finishing a lesson, a quiz, save/restore across a
// restart, switching learning tracks, restricted content and data deletion.
// It uses the real bundled curriculum and the device's real local storage.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfiltered/app.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/data/store.dart';
import 'package:unfiltered/features/home/shell.dart';
import 'package:unfiltered/features/onboarding/onboarding.dart';

String en(String k) => Strings.get(k, Lang.en);

Future<ProviderContainer> launch(
  WidgetTester tester,
  ContentRepository content,
) async {
  final store = await AppStore.open();
  final container = ProviderContainer(
    overrides: [
      storeProvider.overrideWithValue(store),
      contentProvider.overrideWithValue(content),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      key: UniqueKey(),
      container: container,
      child: const UnfilteredApp(),
    ),
  );
  // Splash animation + hand-over. Looping mascot animations mean we pump for
  // fixed durations until reduced motion is switched on.
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 1));
  return container;
}

Future<void> step(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Finder get page => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

Future<void> scrollTap(WidgetTester tester, Finder f) async {
  for (var i = 0; i < 60 && f.evaluate().isEmpty; i++) {
    await tester.drag(page, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first run -> lesson -> quiz -> restart -> tracks -> delete', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Offline-first: the whole curriculum comes from the app bundle.
    final content = await ContentRepository.fromBundle(rootBundle);
    expect(content.loadIssues, isEmpty);
    expect(content.lessons.length, greaterThanOrEqualTo(96));

    // ── Complete first-run flow
    var c = await launch(tester, content);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('onb-next')));
    await step(tester);
    await tester.tap(find.byKey(const Key('onb-next')));
    await step(tester);
    await tester.tap(find.byKey(const Key('track-c')));
    await step(tester);
    await tester.tap(find.byKey(const Key('onb-next')));
    await step(tester);
    await tester.tap(find.byKey(const Key('lang-en')));
    await step(tester);
    await tester.tap(find.byKey(const Key('onb-next')));
    await step(tester);
    await tester.tap(find.byType(Switch).first); // reduce motion
    await step(tester);
    expect(c.read(settingsProvider).reducedMotion, isTrue);
    await tester.tap(find.byKey(const Key('onb-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onb-next')));
    await tester.pumpAndSettle();
    expect(find.byType(ShellScreen), findsOneWidget);
    expect(c.read(settingsProvider).track, Track.c);

    // ── Finish a lesson
    final lesson = content.recommended(Track.c, {}).first;
    await tester.tap(find.byKey(const Key('continue-card')));
    await tester.pumpAndSettle();
    expect(find.text(lesson.title.en), findsOneWidget);
    await scrollTap(tester, find.byKey(const Key('lesson-complete')));
    expect(find.byKey(const Key('lesson-done-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('lesson-done-close')));
    await tester.pumpAndSettle();
    expect(c.read(progressProvider).completed.containsKey(lesson.id), isTrue);

    // ── Complete a quiz
    c.read(routerProvider).push('/quiz/lesson/${lesson.id}');
    await tester.pumpAndSettle();
    for (final q in lesson.quiz) {
      await tester.tap(find.byKey(Key('quiz-opt-${q.answer}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quiz-explain')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('quiz-next')));
    }
    expect(find.byKey(const Key('quiz-score')), findsOneWidget);
    expect(c.read(progressProvider).quizBest['lesson:${lesson.id}'], 100);

    // ── Restart the app: progress is restored from device storage
    c.dispose();
    c = await launch(tester, content);
    await tester.pumpAndSettle();
    expect(find.byType(ShellScreen), findsOneWidget);
    expect(c.read(progressProvider).completed.containsKey(lesson.id), isTrue);
    expect(c.read(progressProvider).quizBest['lesson:${lesson.id}'], 100);
    expect(c.read(settingsProvider).lang, Lang.en);

    // ── Navigate between learning tracks; restricted content stays hidden
    final adult = content.lessons.firstWhere(
      (l) => l.tracks.length == 1 && l.tracks.first == Track.e,
    );
    c.read(routerProvider).go('/lesson/${adult.id}');
    await tester.pumpAndSettle();
    expect(find.text(en('restricted.title')), findsOneWidget);
    expect(c.read(settingsProvider.notifier).setTrack(Track.a), isTrue);
    c.read(routerProvider).go('/lab/protection_lab');
    await tester.pumpAndSettle();
    expect(find.text(en('restricted.title')), findsOneWidget);
    expect(c.read(settingsProvider.notifier).setTrack(Track.e), isTrue);
    c.read(routerProvider).go('/lesson/${adult.id}');
    await tester.pumpAndSettle();
    expect(find.text(adult.title.en), findsOneWidget);

    // ── Delete locally stored data
    c.read(routerProvider).go('/settings');
    await tester.pumpAndSettle();
    await scrollTap(tester, find.byKey(const Key('set-delete')));
    await tester.tap(find.byKey(const Key('set-delete-confirm')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(prefs.getKeys().where((k) => k.startsWith('uf.')), isEmpty);
    expect(c.read(progressProvider).isEmpty, isTrue);
    c.dispose();
  });
}
