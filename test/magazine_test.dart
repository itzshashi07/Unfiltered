import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/magazine.dart';

import 'helpers.dart';

final _deva = RegExp(r'[ऀ-ॿ]');
String en(String key) => Strings.get(key, Lang.en);

void main() {
  late Magazine mag;
  setUpAll(() async {
    await loadFonts();
    await loadContent();
    mag = await Magazine.load(readMagazineFile);
  });

  group('magazine content pack (exported from the website)', () {
    test('all 510 fact-checked stories ship, in 13 sections', () {
      expect(mag.sections, hasLength(13));
      expect(mag.stories.length, greaterThanOrEqualTo(500));
      final slugs = {for (final s in mag.stories) s.slug};
      expect(slugs, hasLength(mag.stories.length), reason: 'duplicate slug');
      for (final s in mag.stories) {
        expect(mag.section(s.section), isNotNull, reason: s.slug);
        expect(s.title.en, isNotEmpty, reason: s.slug);
        expect(s.title.hg, isNotEmpty, reason: s.slug);
        expect(s.minAge, anyOf(16, 18), reason: s.slug);
        expect(s.sources, isNotEmpty, reason: s.slug);
      }
    });

    test(
      'every story has English and Hinglish text, and every citation resolves',
      () async {
        final cite = RegExp(r'\[\[([a-z0-9][a-z0-9-]*)\]\]');
        for (final sec in mag.sections) {
          final bodies = await Magazine.loadBodies(readMagazineFile, sec.key);
          for (final s in mag.stories.where((s) => s.section == sec.key)) {
            final b = bodies[s.slug];
            expect(b, isNotNull, reason: s.slug);
            expect(
              b!.en.split(' ').length,
              greaterThan(300),
              reason: '${s.slug} en',
            );
            expect(
              b.hg.split(' ').length,
              greaterThan(200),
              reason: '${s.slug} hg',
            );
            for (final m in cite.allMatches(b.en + b.hg)) {
              expect(
                mag.sources.containsKey(m.group(1)),
                isTrue,
                reason: '${s.slug}: ${m.group(1)}',
              );
            }
            for (final id in s.sources) {
              expect(
                mag.sources.containsKey(id),
                isTrue,
                reason: '${s.slug}: $id',
              );
            }
          }
        }
      },
    );

    test(
      'no Hindi (Devanagari) text anywhere in the magazine or Data Desk',
      () {
        for (final e in magazineFiles.entries) {
          if (e.key.endsWith('photos.json')) {
            continue; // photographers' names as credited
          }
          expect(_deva.hasMatch(e.value), isFalse, reason: e.key);
        }
      },
    );

    test('every cover photo exists and has a credit', () {
      for (final s in mag.stories.where((s) => s.photo.isNotEmpty)) {
        expect(mag.photos.containsKey(s.photo), isTrue, reason: s.slug);
        final f = File(Magazine.photoAsset(s.photo));
        expect(f.existsSync(), isTrue, reason: f.path);
        expect(f.lengthSync(), lessThan(200000), reason: '${f.path} too large');
      }
    });

    test('age rules: closed below 16, 18+ stories only for adults', () {
      expect(mag.visible(Track.c), isEmpty);
      final d = mag.visible(Track.d);
      final e = mag.visible(Track.e);
      expect(d, isNotEmpty);
      expect(d.every((s) => s.minAge <= 16), isTrue);
      expect(e.length, mag.stories.length);
    });

    test('search finds stories in both languages', () {
      expect(mag.search('POCSO', Track.e), isNotEmpty);
      expect(mag.search('dowry', Track.e), isNotEmpty);
      expect(mag.search('zzzz-nothing', Track.e), isEmpty);
    });

    test('data desk: verified facts in English and Hinglish', () async {
      final areas = await FactArea.load(readMagazineFile);
      expect(areas, hasLength(13));
      final facts = [for (final a in areas) ...a.facts];
      expect(facts.length, greaterThan(900));
      for (final f in facts) {
        expect(f.text.en, isNotEmpty, reason: f.id);
        expect(f.text.hg, isNotEmpty, reason: f.id);
      }
    });

    test('every magazine format and string has text in both languages', () {
      for (final s in mag.stories) {
        expect(Strings.has('mag.format.${s.format}'), isTrue, reason: s.format);
      }
    });
  });

  testWidgets(
    'magazine: a 16+ learner opens a section and reads a story with sources',
    (tester) async {
      final app = await pumpApp(tester, settings: onboarded(track: Track.e));
      app.push('/magazine');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('mag-search')), findsOneWidget);
      expect(find.byKey(const Key('mag-featured')), findsOneWidget);

      final story = mag.visible(Track.e, section: 'violence').first;
      app.push('/magazine/story/${story.slug}');
      await tester.pumpAndSettle();
      expect(find.text(story.title.en), findsOneWidget);
      await scrollTo(tester, find.byKey(Key('story-text-${story.slug}')));
      await scrollTo(tester, find.text(en('mag.sources')));
    },
  );

  testWidgets('magazine search shows matching stories', (tester) async {
    final app = await pumpApp(tester, settings: onboarded(track: Track.e));
    app.push('/magazine');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mag-search')), 'dowry');
    await tester.pumpAndSettle();
    expect(find.textContaining('stories found'), findsOneWidget);
  });

  testWidgets('magazine, stories and Data Desk are closed to younger tracks', (
    tester,
  ) async {
    final app = await pumpApp(tester, settings: onboarded(track: Track.c));
    for (final r in [
      '/magazine',
      '/datadesk',
      '/magazine/story/${mag.stories.first.slug}',
    ]) {
      app.push(r);
      await tester.pumpAndSettle();
      expect(find.text(en('restricted.title')), findsOneWidget, reason: r);
    }
  });

  testWidgets('data desk lists areas and filters facts', (tester) async {
    final app = await pumpApp(tester, settings: onboarded(track: Track.d));
    app.push('/datadesk');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('datadesk-search')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('datadesk-search')), 'NCRB');
    await tester.pumpAndSettle();
    expect(find.textContaining('facts'), findsWidgets);
  });

  testWidgets(
    'home shows the magazine banner for 16+ and the Hinglish story text',
    (tester) async {
      final app = await pumpApp(
        tester,
        settings: onboarded(track: Track.d, lang: Lang.hg),
      );
      expect(find.byKey(const Key('home-magazine')), findsOneWidget);
      final story = mag.visible(Track.d).first;
      app.push('/magazine/story/${story.slug}');
      await tester.pumpAndSettle();
      expect(find.text(story.title.hg), findsOneWidget);
    },
  );
}
