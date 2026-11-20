// "Topics I want to explore": gender and body-topic filters.
// Focus: combined filters, resetting, and that a filter can never unlock
// content outside the learner's age track.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/content.dart';
import 'package:unfiltered/data/models.dart';
import 'package:unfiltered/data/store.dart';
import 'package:unfiltered/features/home/cards.dart';
import 'package:unfiltered/features/lessons/lesson_visual.dart';
import 'package:unfiltered/features/quiz/quiz_screens.dart';

import 'helpers.dart';

class _Item with Topical {
  @override
  final List<Audience> audience;
  @override
  final List<BodyTopic> body;
  _Item(this.audience, [this.body = const []]);
}

String en(String key, [Map<String, Object>? a]) => Strings.get(key, Lang.en, a);

/// Every single chip, plus combinations across and within the two groups.
List<TopicFilter> get _filters => [
  for (final a in Audience.values) TopicFilter(audience: {a}),
  for (final b in BodyTopic.values) TopicFilter(body: {b}),
  const TopicFilter(audience: {Audience.men, Audience.women}),
  const TopicFilter(audience: {Audience.transNb, Audience.intersex, Audience.everyone}),
  const TopicFilter(body: {BodyTopic.menstrual, BodyTopic.pregnancyRepro}),
  const TopicFilter(audience: {Audience.men}, body: {BodyTopic.penisTesticular}),
  const TopicFilter(audience: {Audience.women}, body: {BodyTopic.menstrual, BodyTopic.vulvaVaginal}),
  const TopicFilter(audience: {Audience.men}, body: {BodyTopic.menstrual}),
  TopicFilter(audience: Audience.values.toSet(), body: BodyTopic.values.toSet()),
];

void main() {
  late ContentRepository c;
  setUpAll(() async {
    await loadFonts();
    c = await loadContent();
  });

  group('filter logic', () {
    final menPenis = _Item([Audience.men], [BodyTopic.penisTesticular]);
    final womenPeriod = _Item([Audience.women], [BodyTopic.menstrual]);
    final everyoneConsent = _Item([Audience.everyone]);
    final both = _Item([Audience.men, Audience.women], [BodyTopic.hormonesChanges]);

    test('show all matches everything and is the default', () {
      expect(TopicFilter.all.isActive, isFalse);
      expect(const AppSettings().topics, TopicFilter.all);
      for (final i in [menPenis, womenPeriod, everyoneConsent, both]) {
        expect(TopicFilter.all.matches(i), isTrue);
      }
    });

    test('chips in one group are OR-ed', () {
      const f = TopicFilter(audience: {Audience.men, Audience.women});
      expect(f.matches(menPenis), isTrue);
      expect(f.matches(womenPeriod), isTrue);
      expect(f.matches(both), isTrue);
      expect(f.matches(everyoneConsent), isFalse);
      const b = TopicFilter(body: {BodyTopic.menstrual, BodyTopic.penisTesticular});
      expect(b.matches(menPenis), isTrue);
      expect(b.matches(womenPeriod), isTrue);
      expect(b.matches(both), isFalse);
      expect(b.matches(everyoneConsent), isFalse);
    });

    test('the two groups are AND-ed when combined', () {
      const f = TopicFilter(audience: {Audience.men}, body: {BodyTopic.penisTesticular});
      expect(f.matches(menPenis), isTrue);
      expect(f.matches(womenPeriod), isFalse);
      expect(f.matches(both), isFalse, reason: 'right audience, wrong body topic');
      const g = TopicFilter(audience: {Audience.men}, body: {BodyTopic.menstrual});
      expect(g.matches(menPenis), isFalse);
      expect(g.matches(womenPeriod), isFalse, reason: 'right body topic, wrong audience');
    });

    test('toggling switches chips freely and resets to show all', () {
      var f = TopicFilter.all.toggleAudience(Audience.men).toggleBody(BodyTopic.menstrual);
      expect(f.count, 2);
      expect(f.isActive, isTrue);
      f = f.toggleAudience(Audience.women);
      expect(f.audience, {Audience.men, Audience.women});
      f = f.toggleAudience(Audience.men).toggleAudience(Audience.women).toggleBody(BodyTopic.menstrual);
      expect(f, TopicFilter.all);
      expect(f.isActive, isFalse);
    });

    test('untagged content counts as being for everyone', () {
      final f = Faq.fromJson({'id': 'x', 'domain': 'd01', 'tracks': ['C']});
      expect(f.audience, [Audience.everyone]);
      expect(f.body, isEmpty);
      final l = Lesson.fromJson({
        'id': 'y',
        'domain': 'd01',
        'tracks': ['C'],
        'audience': ['men', 'trans_nb', 'nonsense'],
        'body': ['penis_testicular', 'nope'],
        'quiz': [
          {'id': 'y-q1', 'type': 'tf', 'options': [{}, {}], 'answer': 0},
        ],
      });
      expect(l.audience, [Audience.men, Audience.transNb], reason: 'unknown values are ignored');
      expect(l.body, [BodyTopic.penisTesticular]);
      expect(l.quiz.single.audience, l.audience, reason: 'lesson quiz inherits the lesson tags');
      expect(l.quiz.single.body, l.body);
    });
  });

  group('filters never unlock age-gated content', () {
    test('every filtered result is inside the unfiltered age-track result', () {
      for (final t in Track.values) {
        final lessons = c.lessonsFor(t).map((l) => l.id).toSet();
        final faqs = c.faqsFor(t).map((f) => f.id).toSet();
        final myths = c.mythsFor(t).map((m) => m.id).toSet();
        final quiz = c.quizFor(t).map((q) => q.id).toSet();
        for (final f in _filters) {
          final fl = c.lessonsFor(t, filter: f);
          final ff = c.faqsFor(t, filter: f);
          final fm = c.mythsFor(t, filter: f);
          final fq = c.quizFor(t, filter: f);
          expect(fl.every((l) => lessons.contains(l.id) && l.visibleTo(t) && f.matches(l)), isTrue);
          expect(ff.every((x) => faqs.contains(x.id) && x.visibleTo(t) && f.matches(x)), isTrue);
          expect(fm.every((x) => myths.contains(x.id) && x.visibleTo(t) && f.matches(x)), isTrue);
          expect(fq.every((x) => quiz.contains(x.id) && x.visibleTo(t)), isTrue);
          expect(fl.length, lessThanOrEqualTo(lessons.length));
          // Learning path and final challenge follow the same rule.
          final path = c.recommended(t, {}, filter: f);
          expect(path.every((l) => l.visibleTo(t) && f.matches(l)), isTrue);
          final fin = buildQuiz(c, t, kind: 'final', id: 'all', filter: f);
          expect(fin.every((q) => q.visibleTo(t)), isTrue);
        }
      }
    });

    test('children never reach adult domains whatever is selected', () {
      for (final t in [Track.a, Track.b]) {
        for (final f in _filters) {
          for (final d in ['d07', 'd08', 'd09']) {
            expect(c.lessonsFor(t, domain: d, filter: f), isEmpty, reason: '${t.code} $d');
            expect(c.faqsFor(t, domain: d, filter: f), isEmpty);
            expect(c.mythsFor(t, domain: d, filter: f), isEmpty);
          }
        }
      }
      final adultOnly = c.lessons.where((l) => l.tracks.length == 1 && l.tracks.first == Track.e).map((l) => l.id).toSet();
      for (final f in _filters) {
        for (final t in [Track.a, Track.b, Track.c, Track.d]) {
          expect(c.lessonsFor(t, filter: f).where((l) => adultOnly.contains(l.id)), isEmpty);
        }
      }
    });

    test('younger tracks see a neutral title for the media domain', () {
      final media = c.domain('d12')!;
      expect(media.titleFor(Track.c).en, contains('Pornography'));
      for (final d in c.domains) {
        for (final t in [Track.a, Track.b]) {
          final title = d.titleFor(t);
          for (final s in [title.en, title.hg]) {
            expect(s.toLowerCase(), isNot(contains('porn')), reason: '${d.id} ${t.code}');
          }
        }
      }
    });

    test('show all returns exactly the age-track content', () {
      for (final t in Track.values) {
        expect(c.lessonsFor(t, filter: TopicFilter.all).length, c.lessonsFor(t).length);
        expect(c.faqsFor(t, filter: TopicFilter.all).length, c.faqsFor(t).length);
        expect(c.mythsFor(t, filter: TopicFilter.all).length, c.mythsFor(t).length);
        expect(c.quizFor(t, filter: TopicFilter.all).length, c.quizFor(t).length);
      }
    });

    test('consent, safety, relationships and communication stay discoverable', () {
      for (final t in Track.values) {
        final e = c.essentialDomainsFor(t).map((d) => d.id).toSet();
        expect(e, isNotEmpty, reason: t.code);
        expect(e.every(kEssentialDomains.contains), isTrue);
        // Consent and personal safety exist for every age.
        expect(e, containsAll(['d05', 'd14']));
        expect(c.essentialDomainsFor(t).every((d) => c.lessonsFor(t, domain: d.id).isNotEmpty), isTrue);
      }
    });
  });

  group('topic metadata', () {
    test('every lesson, FAQ, myth card and quiz question is tagged in the content files', () {
      for (final kind in ['lessons', 'faqs', 'myths', 'quiz']) {
        for (final d in kDomainIds) {
          final items = jsonDecode(File('assets/content/$kind/$d.json').readAsStringSync()) as List;
          for (final it in items.cast<Map>()) {
            final a = it['audience'], b = it['body'];
            expect(a, isA<List>(), reason: '${it['id']} has no audience tag');
            expect((a as List), isNotEmpty, reason: '${it['id']}');
            expect(a.every((x) => AudienceX.parse('$x') != null), isTrue, reason: '${it['id']} audience $a');
            expect(b, isA<List>(), reason: '${it['id']} has no body tag');
            expect((b as List).every((x) => BodyTopicX.parse('$x') != null), isTrue, reason: '${it['id']} body $b');
            if ((it['tracks'] as List).contains('A')) {
              expect(a, ['everyone'], reason: '${it['id']}: track A items are for everyone');
              expect(b, isEmpty, reason: '${it['id']}');
            }
          }
        }
      }
    });

    test('every chip leads somewhere for the tracks old enough to use it', () {
      for (final t in [Track.c, Track.d, Track.e]) {
        for (final a in Audience.values) {
          expect(c.lessonsFor(t, filter: TopicFilter(audience: {a})), isNotEmpty, reason: '${t.code} ${a.key}');
        }
        for (final b in BodyTopic.values) {
          expect(c.lessonsFor(t, filter: TopicFilter(body: {b})), isNotEmpty, reason: '${t.code} ${b.key}');
        }
      }
      // Most of the curriculum is for everyone; gender chips narrow it down.
      final all = c.lessonsFor(Track.e).length;
      expect(c.lessonsFor(Track.e, filter: const TopicFilter(audience: {Audience.everyone})).length, greaterThan(all ~/ 3));
      expect(c.lessonsFor(Track.e, filter: const TopicFilter(audience: {Audience.men})).length, lessThan(all));
    });

    test('the python validator accepts the tags (--require-topics)', () async {
      final r = await Process.run('python3', ['tools/validate_content.py', '--require-topics']);
      expect(r.exitCode, 0, reason: '${r.stdout}'.split('\n').take(12).join('\n'));
    });

    test('a count of one reads in the singular', () {
      expect(Strings.get('explore.lessons', Lang.en, {'n': 1}), '1 lesson');
      expect(Strings.get('explore.lessons', Lang.en, {'n': 2}), '2 lessons');
      expect(en('filter.results.myths', {'n': 1}), '1 myth card matches your topics');
      expect(Strings.get('domain.quiz', Lang.hg, {'n': 1}), 'Quiz · 1 question');
    });

    test('filter labels exist in all three languages', () {
      for (final a in Audience.values) {
        expect(Strings.has(a.labelKey), isTrue, reason: a.key);
      }
      for (final b in BodyTopic.values) {
        expect(Strings.has(b.labelKey), isTrue, reason: b.key);
      }
      for (final k in ['title', 'sub', 'all', 'clear', 'note', 'empty.title', 'empty.body', 'essentials.title', 'essentials.add']) {
        expect(Strings.has('filter.$k'), isTrue, reason: k);
      }
      for (final n in ['lessons', 'faqs', 'myths', 'quiz']) {
        expect(Strings.has('filter.results.$n'), isTrue);
      }
      expect(Strings.get('filter.title', Lang.en), 'Topics I want to explore');
    });
  });

  group('selections are optional, local and resettable', () {
    test('saved on the device, restored after restart, cleared by reset and by delete-all', () async {
      SharedPreferences.setMockInitialValues({});
      final store = AppStore(await SharedPreferences.getInstance());
      final c1 = ProviderContainer(overrides: [storeProvider.overrideWithValue(store)]);
      addTearDown(c1.dispose);
      final n = c1.read(settingsProvider.notifier);
      expect(c1.read(settingsProvider).topics.isActive, isFalse, reason: 'default is show all');
      n
        ..toggleAudience(Audience.women)
        ..toggleAudience(Audience.transNb)
        ..toggleBodyTopic(BodyTopic.menstrual);

      final c2 = ProviderContainer(overrides: [storeProvider.overrideWithValue(AppStore(await SharedPreferences.getInstance()))]);
      addTearDown(c2.dispose);
      expect(
        c2.read(settingsProvider).topics,
        const TopicFilter(audience: {Audience.women, Audience.transNb}, body: {BodyTopic.menstrual}),
      );
      // Nothing but the app's own local keys exists, and the export shows the choice plainly.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().every((k) => k.startsWith('uf.')), isTrue);
      expect(store.exportJson(), contains('topicAudience'));

      c2.read(settingsProvider.notifier).clearTopics();
      expect(c2.read(settingsProvider).topics, TopicFilter.all);
      c2.read(settingsProvider.notifier).toggleAudience(Audience.men);
      await store.deleteAll();
      expect(store.readSettings().topics, TopicFilter.all);
    });

    test('the educator lock and allowed tracks are untouched by filters', () async {
      SharedPreferences.setMockInitialValues({});
      final store = AppStore(await SharedPreferences.getInstance());
      final pc = ProviderContainer(overrides: [storeProvider.overrideWithValue(store)]);
      addTearDown(pc.dispose);
      final n = pc.read(settingsProvider.notifier)
        ..setTrack(Track.b)
        ..lock('1357', [Track.b]);
      n
        ..toggleAudience(Audience.everyone)
        ..toggleBodyTopic(BodyTopic.pregnancyRepro);
      final s = pc.read(settingsProvider);
      expect(s.locked, isTrue);
      expect(s.selectableTracks, [Track.b]);
      expect(s.track, Track.b);
      expect(n.setTrack(Track.e), isFalse, reason: 'a filter does not open another track');
      expect(c.lessonsFor(s.track!, filter: s.topics).every((l) => l.tracks.contains(Track.b)), isTrue);
    });
  });

  group('filter chips in the app', () {
    Future<void> openBar(WidgetTester tester) async {
      await scrollTap(tester, find.byKey(const Key('filter-toggle')).first);
    }

    /// Scrolls the page back up until [finder] is built.
    Future<void> scrollUpTo(WidgetTester tester, Finder finder) async {
      for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
        await tester.drag(pageScroll, const Offset(0, 350));
        await tester.pumpAndSettle();
      }
      expect(finder, findsOneWidget);
    }

    testWidgets('Explore: combined filters, matching count, empty state and reset', (tester) async {
      final app = await pumpApp(tester, settings: onboarded(track: Track.e));
      await tester.tap(find.byKey(const Key('nav-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('topic-filter')), findsOneWidget);
      expect(find.text(en('filter.title')), findsOneWidget);
      expect(find.byKey(const Key('explore-d01')), findsOneWidget, reason: 'show all is the default');

      await openBar(tester);
      expect(find.text(en('filter.sub')), findsOneWidget);
      await scrollTap(tester, find.byKey(const Key('filter-aud-men')));
      expect(app.settings.topics, const TopicFilter(audience: {Audience.men}));
      final men = c.lessonsFor(Track.e, filter: app.settings.topics);
      if (men.isEmpty) {
        await scrollTo(tester, find.byKey(const Key('filter-empty')));
      } else {
        await scrollTo(tester, find.byKey(const Key('filter-count')));
        expect(find.text(en('filter.results.lessons', {'n': men.length})), findsOneWidget);
        await scrollTo(tester, find.byKey(Key('lesson-${men.first.id}')));
      }
      expect(find.byKey(const Key('explore-d01')), findsNothing);

      // Back to the top: the bar is still open the way the learner left it.
      await scrollUpTo(tester, find.byKey(const Key('filter-aud-women')));
      // Add a second audience chip (OR) and a body chip (AND).
      await scrollTap(tester, find.byKey(const Key('filter-aud-women')));
      await scrollTap(tester, find.byKey(const Key('filter-body-menstrual')));
      const combined = TopicFilter(audience: {Audience.men, Audience.women}, body: {BodyTopic.menstrual});
      expect(app.settings.topics, combined);
      final both = c.lessonsFor(Track.e, filter: combined);
      if (both.isNotEmpty) {
        await scrollTo(tester, find.byKey(const Key('filter-count')));
        expect(find.text(en('filter.results.lessons', {'n': both.length})), findsOneWidget);
      }
      // Essentials stay one tap away while a gender filter is on.
      await scrollTo(tester, find.byKey(const Key('essentials-strip')));
      expect(find.text(en('filter.essentials.title')), findsOneWidget);

      // A combination with no content shows the helpful empty state.
      app.container.read(settingsProvider.notifier).setTopics(
        const TopicFilter(audience: {Audience.intersex}, body: {BodyTopic.pregnancyRepro, BodyTopic.menstrual}),
      );
      await tester.pumpAndSettle();
      if (c.lessonsFor(Track.e, filter: app.settings.topics).isEmpty) {
        await scrollTap(tester, find.byKey(const Key('filter-empty-clear')));
        expect(app.settings.topics, TopicFilter.all);
      } else {
        await scrollUpTo(tester, find.byKey(const Key('filter-all')));
        await scrollTap(tester, find.byKey(const Key('filter-all')));
      }
      expect(app.settings.topics.isActive, isFalse);
      await tester.pumpAndSettle();
      await scrollUpTo(tester, find.byKey(const Key('explore-d01')));
      expect(find.byKey(const Key('explore-d01')), findsOneWidget, reason: 'reset brings back every topic');
    });

    testWidgets('Explore on a child track: every chip on, nothing from another track appears', (tester) async {
      final app = await pumpApp(tester, settings: onboarded(track: Track.a));
      app.container.read(settingsProvider.notifier).setTopics(
        TopicFilter(audience: Audience.values.toSet()),
      );
      await tester.tap(find.byKey(const Key('nav-1')));
      await tester.pumpAndSettle();
      final allowed = c.lessonsFor(Track.a).map((l) => l.id).toSet();
      final shown = c.lessonsFor(Track.a, filter: app.settings.topics);
      expect(shown.every((l) => allowed.contains(l.id)), isTrue);
      for (final l in c.lessons.where((l) => !l.visibleTo(Track.a)).take(40)) {
        expect(find.byKey(Key('lesson-${l.id}')), findsNothing);
        expect(find.text(l.title.en), findsNothing);
      }
      for (final w in tester.widgetList<LessonRow>(find.byType(LessonRow))) {
        expect(w.lesson.tracks, contains(Track.a));
      }
      // A filtered-out adult lesson still cannot be opened by route.
      final adult = c.lessons.firstWhere((l) => l.tracks.length == 1 && l.tracks.first == Track.e);
      app.go('/lesson/${adult.id}');
      await tester.pumpAndSettle();
      expect(find.text(en('restricted.title')), findsOneWidget);
    });

    testWidgets('FAQ library and Dark Myths use the same chips and counts', (tester) async {
      final app = await pumpApp(tester, settings: onboarded(track: Track.d));
      await tester.tap(find.byKey(const Key('nav-3')));
      await tester.pumpAndSettle();
      expect(find.text(en('ask.library')), findsOneWidget);
      expect(find.byKey(const Key('topic-filter')), findsOneWidget);
      await openBar(tester);
      await scrollTap(tester, find.byKey(const Key('filter-aud-women')));
      final faqs = c.faqsFor(Track.d, filter: app.settings.topics);
      if (faqs.isEmpty) {
        await scrollTo(tester, find.byKey(const Key('filter-empty')));
      } else {
        await scrollTo(tester, find.byKey(const Key('filter-count')));
        expect(find.text(en('filter.results.faqs', {'n': faqs.length})), findsOneWidget);
      }

      // The same selection is already active in Dark Myths.
      app.push('/lab/myth_buster');
      await tester.pumpAndSettle();
      expect(find.text(en('myth.dark')), findsOneWidget);
      final myths = c.mythsFor(Track.d, filter: app.settings.topics);
      if (myths.isEmpty) {
        expect(find.byKey(const Key('filter-empty')), findsOneWidget);
      } else {
        expect(find.text(en('filter.results.myths', {'n': myths.length})), findsOneWidget);
        expect(find.byKey(const Key('myth-front')), findsOneWidget);
      }
      // Clearing from here resets everywhere.
      await scrollTap(tester, find.byKey(const Key('filter-clear')).first);
      expect(app.settings.topics, TopicFilter.all);
      expect(find.byKey(const Key('myth-front')), findsOneWidget);
    });

    testWidgets('filter survives restart, shows on Home, and delete-all clears it', (tester) async {
      var app = await pumpApp(tester, settings: onboarded());
      app.container.read(settingsProvider.notifier)
        ..toggleAudience(Audience.everyone)
        ..toggleBodyTopic(BodyTopic.hormonesChanges);
      await tester.pumpAndSettle();
      app = await pumpApp(tester, keepPrefs: true);
      expect(
        app.settings.topics,
        const TopicFilter(audience: {Audience.everyone}, body: {BodyTopic.hormonesChanges}),
      );
      await scrollTo(tester, find.byKey(const Key('home-filter-note')));
      expect(find.text(en('filter.path.note')), findsOneWidget);
      await deleteAllFor(app);
      await tester.pumpAndSettle();
      expect(app.settings.topics, TopicFilter.all);
    });
  });

  group('at-a-glance visuals and pictures', () {
    test('the icon vocabulary file matches the icons the app can draw', () {
      final j = jsonDecode(File('assets/content/extras/visual_icons.json').readAsStringSync()) as Map;
      expect((j['icons'] as List).toSet(), kVisualIcons.keys.toSet());
      expect((j['objects'] as List).toSet(), kVisualObjects);
      expect(kVisualIcons.keys.toSet().intersection(kVisualObjects), isEmpty);
    });

    test('every visual belongs to a lesson, uses known icons and is translated', () {
      c.visuals.forEach((id, v) {
        expect(c.lesson(id), isNotNull, reason: id);
        expect(v.isValid, isTrue, reason: id);
        expect(v.title.isComplete, isTrue, reason: id);
        for (final i in v.items) {
          expect(isVisualIcon(i.icon), isTrue, reason: '$id icon ${i.icon}');
          expect(i.label.isComplete && i.text.isComplete, isTrue, reason: id);
        }
        for (final s in [v.left, v.right].whereType<VisualSide>()) {
          expect(isVisualIcon(s.icon), isTrue, reason: id);
          expect(s.points.every((p) => p.isComplete), isTrue, reason: id);
        }
      });
    });

    test('pictures exist on disk, are captioned in three languages and respect tracks', () {
      for (final i in c.images) {
        expect(File(i.asset).existsSync(), isTrue, reason: i.asset);
        expect(i.caption.isComplete && i.alt.isComplete, isTrue, reason: i.id);
        expect(i.tracks, isNotEmpty, reason: i.id);
      }
      for (final t in Track.values) {
        for (final l in c.lessonsFor(t)) {
          final img = c.imageForLesson(l, t);
          if (img != null) expect(img.tracks, contains(t), reason: '${l.id} shows ${img.id} to ${t.code}');
        }
      }
    });
  });
}

/// Wipes local data the same way Settings does.
Future<void> deleteAllFor(TestApp app) async {
  await app.container.read(storeProvider).deleteAll();
  app.container.read(settingsProvider.notifier).reset();
  app.container.read(progressProvider.notifier).reset();
}
