import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/data/store.dart';
import 'package:unfiltered/features/home/ask_tab.dart';
import 'package:unfiltered/features/home/shell.dart';
import 'package:unfiltered/features/onboarding/onboarding.dart';
import 'package:unfiltered/features/labs/visual_explainers.dart';
import 'package:unfiltered/features/quiz/quiz_runner.dart';
import 'package:unfiltered/ui/illustrations.dart';

import 'helpers.dart';

String en(String key, [Map<String, Object>? a]) => Strings.get(key, Lang.en, a);

void main() {
  late ContentRepository content;
  setUpAll(() async {
    await loadFonts();
    content = await loadContent();
  });

  testWidgets(
    'onboarding: first run asks for track and language, then opens home',
    (tester) async {
      final app = await pumpApp(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(
        find.text(Strings.get('onb.welcome.title', Lang.hg)),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('onb-next'))); // -> privacy
      await tester.pumpAndSettle();
      expect(
        find.text(Strings.get('onb.privacy.title', Lang.hg)),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('onb-next'))); // -> track
      await tester.pumpAndSettle();

      // No track yet: cannot continue.
      await tester.tap(find.byKey(const Key('onb-next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('track-c')), findsOneWidget);
      await tester.tap(find.byKey(const Key('track-c')));
      await tester.pumpAndSettle();
      expect(app.settings.track, Track.c);
      await tester.tap(find.byKey(const Key('onb-next'))); // -> language
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('lang-en')));
      await tester.pumpAndSettle();
      expect(find.text(en('onb.lang.title')), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb-next'))); // -> accessibility
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).first); // reduce motion
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onb-next'))); // -> interests
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onb-next'))); // start
      await tester.pumpAndSettle();

      expect(find.byType(ShellScreen), findsOneWidget);
      expect(app.settings.onboarded, isTrue);
      expect(app.settings.lang, Lang.en);
      expect(app.settings.reducedMotion, isTrue);
      expect(app.prefs.getString('uf.settings'), contains('"onboarded":true'));
    },
  );

  testWidgets(
    'home dashboard shows learning, topics, myth and safety entry points',
    (tester) async {
      await pumpApp(tester, settings: onboarded());
      expect(find.text(en('home.hero')), findsOneWidget);
      expect(find.text(en('home.start')), findsOneWidget);
      expect(find.byKey(const Key('continue-card')), findsOneWidget);
      expect(find.byKey(const Key('home-safety')), findsOneWidget);
      await scrollTo(tester, find.byKey(const Key('home-myth')));
      expect(find.text(en('home.topics')), findsWidgets);
      await scrollTo(tester, find.text(en('home.safety.title')));
      expect(find.text(en('home.safety.title')), findsOneWidget);
    },
  );

  testWidgets('topic navigation: explore -> topic -> lesson', (tester) async {
    await pumpApp(tester, settings: onboarded());
    await tester.tap(find.byKey(const Key('nav-1')));
    await tester.pumpAndSettle();
    expect(find.text(en('explore.title')), findsWidgets);
    final domain = content.domainsFor(Track.c).first;
    await tester.tap(find.byKey(Key('explore-${domain.id}')));
    await tester.pumpAndSettle();
    final lesson = content.lessonsFor(Track.c, domain: domain.id).first;
    expect(find.text(lesson.title.en), findsOneWidget);
    await tester.tap(find.byKey(Key('lesson-${lesson.id}')));
    await tester.pumpAndSettle();
    expect(find.text(lesson.hook.en), findsOneWidget);
    expect(
      find.byType(SceneArt),
      findsOneWidget,
      reason: 'every lesson opens with an illustrated scene',
    );
    await scrollTo(tester, find.text(lesson.sections.first.h.en));

    // Filters narrow the lesson list.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('filter-d1')));
    await tester.pumpAndSettle();
    final starter = content
        .lessonsFor(Track.c)
        .firstWhere((l) => l.difficulty == 1);
    expect(find.byKey(Key('lesson-${starter.id}')), findsOneWidget);
  });

  testWidgets('lesson completion is saved and restored after a restart', (
    tester,
  ) async {
    final lesson = content.lessonsFor(Track.c).firstWhere((l) => !l.sensitive);
    var app = await pumpApp(tester, settings: onboarded());
    app.push('/lesson/${lesson.id}');
    await tester.pumpAndSettle();
    expect(app.progress.lastLesson, lesson.id);

    await scrollTap(tester, find.byKey(const Key('lesson-complete')));
    expect(find.byKey(const Key('lesson-done-title')), findsOneWidget);
    expect(find.text(en('lesson.done.title')), findsOneWidget);
    expect(app.progress.completed.containsKey(lesson.id), isTrue);
    await tester.tap(find.byKey(const Key('lesson-done-close')));
    await tester.pumpAndSettle();

    // Restart with the same stored data.
    app = await pumpApp(tester, keepPrefs: true);
    expect(find.byType(ShellScreen), findsOneWidget);
    expect(app.progress.completed.containsKey(lesson.id), isTrue);
    final total = content.lessonsFor(Track.c).length;
    expect(
      find.text(en('home.progress', {'done': 1, 'total': total})),
      findsOneWidget,
    );
    expect(find.text(en('home.continue')), findsOneWidget);
  });

  testWidgets('sensitive lessons finish calmly, without celebration', (
    tester,
  ) async {
    final lesson = content.lessonsFor(Track.c).firstWhere((l) => l.sensitive);
    final app = await pumpApp(tester, settings: onboarded());
    app.push('/lesson/${lesson.id}');
    await tester.pumpAndSettle();
    await scrollTap(tester, find.byKey(const Key('lesson-complete')));
    expect(find.text(en('lesson.done.calm.title')), findsOneWidget);
    expect(find.text(en('lesson.done.title')), findsNothing);
  });

  testWidgets(
    'restricted content: an adult lesson never renders on a child track',
    (tester) async {
      final adult = content.lessons.firstWhere(
        (l) => l.tracks.length == 1 && l.tracks.first == Track.e,
      );
      final app = await pumpApp(tester, settings: onboarded(track: Track.a));
      app.push('/lesson/${adult.id}');
      await tester.pumpAndSettle();
      expect(find.text(en('restricted.title')), findsOneWidget);
      expect(find.text(adult.title.en), findsNothing);
      expect(app.progress.lastLesson, isNull);

      for (final route in [
        '/lab/protection_lab',
        '/lab/sti_match',
        '/lab/period_lab',
        '/domain/d07',
        '/teacher/lesson/nope',
      ]) {
        app.go(route);
        await tester.pumpAndSettle();
        expect(
          find.text(en('restricted.title')),
          findsOneWidget,
          reason: route,
        );
      }

      // Switching tracks changes what is available.
      app.container.read(settingsProvider.notifier).setTrack(Track.e);
      app.go('/lesson/${adult.id}');
      await tester.pumpAndSettle();
      expect(find.text(adult.title.en), findsOneWidget);
    },
  );

  testWidgets('myth cards flip to the verdict, science and source', (
    tester,
  ) async {
    final app = await pumpApp(tester, settings: onboarded());
    app.push('/lab/myth_buster');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('myth-front')), findsOneWidget);
    await tester.tap(find.byKey(const Key('myth-say-myth')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('myth-back')), findsOneWidget);
    expect(find.byKey(const Key('myth-verdict')), findsOneWidget);
    expect(find.text(en('myth.science')), findsOneWidget);
    expect(find.text(en('myth.why')), findsOneWidget);
    expect(app.progress.mythsSeen.length, 1);
    await scrollTap(tester, find.byKey(const Key('myth-next')));
    expect(find.byKey(const Key('myth-front')), findsOneWidget);
  });

  testWidgets(
    'quiz interactions: explanation after each answer, score, retry',
    (tester) async {
      final qs = content.lessonsFor(Track.c).first.quiz;
      final app = await pumpApp(tester, settings: onboarded());
      app.push('/quiz/lesson/${content.lessonsFor(Track.c).first.id}');
      await tester.pumpAndSettle();
      expect(find.byType(QuizRunner), findsOneWidget);
      expect(find.text(qs[0].q.en), findsOneWidget);
      expect(find.byKey(const Key('quiz-explain')), findsNothing);

      await tester.tap(find.byKey(Key('quiz-opt-${qs[0].answer}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quiz-explain')), findsOneWidget);
      expect(find.text(en('quiz.correct')), findsOneWidget);
      expect(find.text(qs[0].explain.en), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('quiz-next')));

      final wrong = (qs[1].answer + 1) % qs[1].options.length;
      await tester.tap(find.byKey(Key('quiz-opt-$wrong')));
      await tester.pumpAndSettle();
      expect(find.text(en('quiz.notQuite')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('quiz-next')));

      expect(find.byKey(const Key('quiz-score')), findsOneWidget);
      expect(find.text('1/2'), findsOneWidget);
      expect(app.progress.quizBest.values.single, 50);
      await tester.tap(find.byKey(const Key('quiz-retry')));
      await tester.pumpAndSettle();
      expect(find.text(qs[0].q.en), findsOneWidget);
    },
  );

  testWidgets('language switching updates interface and content', (
    tester,
  ) async {
    final app = await pumpApp(tester, settings: onboarded());
    app.push('/settings');
    await tester.pumpAndSettle();
    expect(find.text(en('me.settings.title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-lang-hi')));
    await tester.pumpAndSettle();
    expect(
      find.text(Strings.get('me.settings.title', Lang.hi)),
      findsOneWidget,
    );
    expect(app.settings.lang, Lang.hi);
    await tester.tap(find.byKey(const Key('set-lang-hg')));
    await tester.pumpAndSettle();
    expect(
      find.text(Strings.get('settings.language', Lang.hg)),
      findsOneWidget,
    );

    final lesson = content.lessonsFor(Track.c).first;
    app.go('/lesson/${lesson.id}');
    await tester.pumpAndSettle();
    expect(find.text(lesson.title.hg), findsOneWidget);
    app.container.read(settingsProvider.notifier).setLang(Lang.hi);
    await tester.pumpAndSettle();
    expect(find.text(lesson.title.hi), findsOneWidget);
  });

  testWidgets('settings: delete all local data returns to a clean first run', (
    tester,
  ) async {
    final app = await pumpApp(
      tester,
      settings: onboarded(),
      progress: const Progress(
        completed: {'d01-l03': '2026-11-14'},
        notes: [Note('1', 'private', '2026-11-14')],
      ),
    );
    expect(app.progress.notes, isNotEmpty);
    app.push('/settings');
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('set-version')),
      findsNothing,
    ); // below the fold
    await scrollTap(tester, find.byKey(const Key('set-delete')));
    expect(find.text(en('settings.delete.body')), findsOneWidget);
    await tester.tap(find.byKey(const Key('set-delete-confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(app.prefs.getKeys().where((k) => k.startsWith('uf.')), isEmpty);
    expect(app.progress.isEmpty, isTrue);
    expect(app.settings.onboarded, isFalse);
  });

  testWidgets(
    'safety center lists helplines and never dials without confirmation',
    (tester) async {
      final app = await pumpApp(tester, settings: onboarded());
      await tester.tap(find.byKey(const Key('home-safety')));
      await tester.pumpAndSettle();
      expect(find.text(en('safety.hero.title')), findsOneWidget);
      expect(find.byKey(const Key('call-emergency')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('call-emergency')));
      expect(find.text(en('call.title', {'number': '112'})), findsOneWidget);
      await tester.tap(find.text(en('common.cancel')));
      await tester.pumpAndSettle();
      expect(find.text(en('call.title', {'number': '112'})), findsNothing);
      await scrollTo(tester, find.byKey(const Key('call-child')));
      expect(find.textContaining('1098'), findsWidgets);

      // Young children see only the helplines meant for them.
      app.container.read(settingsProvider.notifier).setTrack(Track.a);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('call-hiv')), findsNothing);
    },
  );

  testWidgets('ask: curated answers, a no-match state and urgent help', (
    tester,
  ) async {
    await pumpApp(tester, settings: onboarded(track: Track.d));
    await tester.tap(find.byKey(const Key('nav-3')));
    await tester.pumpAndSettle();
    expect(find.text(en('ask.title')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('ask-field')),
      'how does hiv spread',
    );
    await tester.tap(find.byKey(const Key('ask-go')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ask-none')), findsNothing);
    expect(find.byType(FaqCard), findsWidgets);

    await tester.enterText(
      find.byKey(const Key('ask-field')),
      'xyzzy plugh quux',
    );
    await tester.tap(find.byKey(const Key('ask-go')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ask-none')), findsOneWidget);
    expect(find.text(en('ask.none.title')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('ask-field')),
      'someone is blackmailing me',
    );
    await tester.tap(find.byKey(const Key('ask-go')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ask-urgent')), findsOneWidget);
  });

  testWidgets('labs: body lab, period lab and decision paths work', (
    tester,
  ) async {
    final app = await pumpApp(tester, settings: onboarded());

    app.push('/lab/body_lab');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('spot-uterus')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('body-part-card')), findsOneWidget);
    await scrollTap(tester, find.byKey(const Key('body-find')));
    expect(find.byKey(const Key('body-find-banner')), findsOneWidget);

    app.go('/lab/period_lab');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('period-disclaimer')), findsOneWidget);
    expect(find.text(en('period.day', {'n': 1})), findsWidgets);

    final s = content.scenariosFor(Track.c).first;
    app.go('/scenario/${s.id}');
    await tester.pumpAndSettle();
    await scrollTap(tester, find.byKey(const Key('scenario-start')));
    var guard = 0;
    while (find.byKey(const Key('scenario-debrief')).evaluate().isEmpty &&
        guard++ < 8) {
      await scrollTap(tester, find.byKey(const Key('choice-0')));
      expect(find.byKey(const Key('scenario-feedback')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('scenario-continue')));
    }
    expect(find.byKey(const Key('scenario-debrief')), findsOneWidget);
    expect(app.progress.scenariosDone, {s.id});
  });

  testWidgets(
    'protection lab compares methods; teacher mode shows curriculum only',
    (tester) async {
      final app = await pumpApp(tester, settings: onboarded());
      app.push('/lab/protection_lab');
      await tester.pumpAndSettle();
      expect(
        find.text(en('prot.minor')),
        findsOneWidget,
        reason: 'minors see the legal context',
      );
      await scrollTo(tester, find.byKey(const Key('method-pill')));
      await tester.tap(find.byKey(const Key('method-pill')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(en('prot.sti.no'), findRichText: true),
        findsOneWidget,
      );

      app.go('/teacher');
      await tester.pumpAndSettle();
      expect(find.text(en('teacher.privacy.title')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('teacher-tab-coverage')));
      expect(find.text(en('teacher.coverage.title')), findsOneWidget);
    },
  );

  testWidgets(
    'visual explainers: pregnancy animation, period products, body location, object art',
    (tester) async {
      final app = await pumpApp(tester, settings: onboarded());
      app.push(
        '/lesson/${kFertilizationLessons.firstWhere((id) => content.canOpenLesson(id, Track.c))}',
      );
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const Key('fert-caption')));
      expect(find.text(en('fert.1')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('fert-step-2')));
      expect(find.text(en('fert.3')), findsOneWidget);

      app.go('/lab/body_lab');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const Key('body-location')));
      expect(find.text(en('body.where.inside')), findsOneWidget);

      app.go('/lab/protection_lab');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byKey(const Key('method-pill')));
      expect(find.byType(ObjectArt), findsWidgets);

      // Period products are shown to the 9-12 track; the pregnancy animation is not.
      app.container.read(settingsProvider.notifier).setTrack(Track.b);
      final products = kPeriodProductLessons.firstWhere(
        (id) => content.canOpenLesson(id, Track.b),
      );
      app.go('/lesson/$products');
      await tester.pumpAndSettle();
      await scrollTo(tester, find.byType(PeriodProducts));
      expect(find.text(en('visual.cup')), findsOneWidget);
      expect(find.byType(FertilizationJourney), findsNothing);
      for (final id in kFertilizationLessons) {
        expect(content.canOpenLesson(id, Track.b), isFalse, reason: id);
        expect(content.canOpenLesson(id, Track.a), isFalse, reason: id);
      }
    },
  );

  testWidgets(
    'layout holds with large text, Hindi and dark mode on a small phone',
    (tester) async {
      final app = await pumpApp(
        tester,
        settings: const AppSettings(
          lang: Lang.hi,
          track: Track.d,
          onboarded: true,
          reducedMotion: true,
          textScale: 1.6,
          theme: ThemeMode.dark,
          highContrast: true,
        ),
        size: const Size(320, 640),
      );
      expect(find.byType(ShellScreen), findsOneWidget);
      for (var i = 1; i <= 4; i++) {
        await tester.tap(find.byKey(Key('nav-$i')));
        await tester.pumpAndSettle();
      }
      final lesson = content.lessonsFor(Track.d).first;
      for (final route in [
        '/lesson/${lesson.id}',
        '/domain/${lesson.domain}',
        '/lab/body_lab',
        '/lab/puberty_lab',
        '/lab/period_lab',
        '/lab/protection_lab',
        '/lab/support_circle',
        '/lab/signals',
        '/lab/digital_challenge',
        '/lab/sti_match',
        '/quiz',
        '/safety',
        '/teacher',
        '/parents',
        '/references',
        '/settings',
        '/glossary',
        '/achievements',
        '/notes',
        '/legal/privacy',
      ]) {
        app.go(route);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route);
      }
      // Landscape rotation.
      tester.view.physicalSize = const Size(1280, 640);
      await tester.pumpAndSettle();
      app.go('/home');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
