// The app's GIF-like motion: scenes that breathe, step diagrams that light up
// in turn, the myth stamp and quiz reactions. Other tests run with motion off;
// these run with it on and play each screen for a few seconds.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/features/lessons/lesson_visual.dart';
import 'package:unfiltered/ui/illustrations.dart';

import 'helpers.dart';

Future<TestApp> pumpMoving(WidgetTester tester, {Track track = Track.d}) async {
  final settings = onboarded(track: track).copyWith(reducedMotion: false);
  final app = await pumpApp(tester, settings: settings);
  // Turn the phone's own "remove animations" setting back off.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures();
  await tester.pump();
  return app;
}

/// Plays looping animations for [seconds] (pumpAndSettle would never return).
Future<void> play(WidgetTester tester, [int seconds = 3]) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late ContentRepository c;
  setUpAll(() async {
    await loadFonts();
    // Real file reads must happen here, outside the widget tests' fake clock.
    c = await loadContent();
  });

  testWidgets('lesson scene and at-a-glance diagram animate without errors', (
    tester,
  ) async {
    final app = await pumpMoving(tester);
    final l = c
        .lessonsFor(Track.d)
        .firstWhere(
          (l) => c.visualFor(l.id) != null && c.imageForLesson(l, Track.d) == null,
          orElse: () => c.lessonsFor(Track.d).first,
        );
    app.push('/lesson/${l.id}');
    await play(tester);
    expect(find.byType(SceneArt), findsWidgets);
    if (c.visualFor(l.id) != null) {
      for (var i = 0; i < 12 && find.byType(LessonVisualCard).evaluate().isEmpty; i++) {
        await tester.drag(pageScroll, const Offset(0, -300));
        await play(tester, 1);
      }
      expect(find.byType(LessonVisualCard), findsOneWidget);
      await play(tester, 4);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('an open FAQ answer shows a moving picture of its topic', (
    tester,
  ) async {
    await pumpMoving(tester);
    await tester.tap(find.byKey(const Key('nav-3')));
    await play(tester, 1);
    final first = find.byWidgetPredicate(
      (w) => w.key is ValueKey<String> && '${(w.key as ValueKey).value}'.startsWith('faq-'),
    );
    await tester.tap(find.descendant(of: first.first, matching: find.byType(Text)).first);
    await play(tester);
    expect(
      find.byKey(const Key('topic-banner')).evaluate().isNotEmpty ||
          find.byWidgetPredicate((w) => w.key is ValueKey && '${(w.key as ValueKey).value}'.startsWith('picture-')).evaluate().isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dark Myths: scene on the card, stamp on the answer', (
    tester,
  ) async {
    final app = await pumpMoving(tester);
    app.push('/lab/myth_buster');
    await play(tester, 2);
    expect(find.byType(SceneArt), findsWidgets);
    await tester.ensureVisible(find.byKey(const Key('myth-say-myth')));
    await tester.tap(find.byKey(const Key('myth-say-myth')));
    await play(tester, 2);
    expect(find.byKey(const Key('verdict-stamp')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quiz questions show their topic and react to answers', (
    tester,
  ) async {
    final app = await pumpMoving(tester);
    app.push('/quiz/final/all');
    await play(tester, 2);
    expect(find.byKey(const Key('topic-banner')), findsWidgets);
    await tester.ensureVisible(find.byKey(const Key('quiz-opt-0')));
    await tester.tap(find.byKey(const Key('quiz-opt-0')));
    await play(tester, 2);
    expect(find.byKey(const Key('quiz-explain')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('labs without a photo show an animated scene instead', (
    tester,
  ) async {
    final app = await pumpMoving(tester);
    app.push('/safety');
    await play(tester, 2);
    expect(find.byKey(const Key('scene-banner-stop')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion keeps every scene still', (tester) async {
    final app = await pumpApp(tester, settings: onboarded(track: Track.d));
    app.push('/lab/myth_buster');
    // pumpAndSettle returns only when nothing is animating.
    await tester.pumpAndSettle();
    expect(find.byType(SceneArt), findsWidgets);
  });
}
