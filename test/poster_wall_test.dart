import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unfiltered/core/l10n.dart';
import 'package:unfiltered/core/strings.dart';
import 'package:unfiltered/data/store.dart';

import 'helpers.dart';

String en(String key) => Strings.get(key, Lang.en);

void main() {
  setUpAll(() async {
    await loadFonts();
    await loadContent();
  });

  final posters =
      jsonDecode(File('assets/content/extras/posters.json').readAsStringSync())
          as List;

  test('every poster has an image in English and Hinglish, none in Hindi', () {
    expect(posters, isNotEmpty);
    for (final p in posters) {
      expect(File('assets/images/posters/${p['id']}_hi.webp').existsSync(), isFalse);
      for (final l in ['en', 'hg']) {
        final f = File('assets/images/posters/${p['id']}_$l.webp');
        expect(f.existsSync(), isTrue, reason: f.path);
        expect(
          f.lengthSync(),
          lessThan(250000),
          reason: '${f.path} is too large',
        );
      }
      for (final k in ['kicker', 'title']) {
        for (final l in ['en', 'hg']) {
          expect((p[k] as Map)[l], isNotEmpty, reason: '${p['id']}.$k.$l');
        }
      }
    }
  });

  testWidgets('poster wall: 16+ learners can swipe through the posters', (
    tester,
  ) async {
    final app = await pumpApp(tester, settings: onboarded(track: Track.d));
    final content = app.container.read(contentProvider);
    expect(content.labsFor(Track.d), contains('poster_wall'));
    expect(content.labsFor(Track.e), contains('poster_wall'));
    for (final t in [Track.a, Track.b, Track.c]) {
      expect(
        content.labsFor(t),
        isNot(contains('poster_wall')),
        reason: 'track $t',
      );
    }
    app.push('/lab/poster_wall');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('poster-pages')), findsOneWidget);
    expect(find.text('1 / ${posters.length}'), findsOneWidget);
    await tester.tap(find.byTooltip(en('common.next')));
    await tester.pumpAndSettle();
    expect(find.text('2 / ${posters.length}'), findsOneWidget);
  });

  testWidgets('poster wall is closed to younger tracks even by direct link', (
    tester,
  ) async {
    final app = await pumpApp(tester, settings: onboarded(track: Track.b));
    app.push('/lab/poster_wall');
    await tester.pumpAndSettle();
    expect(find.text(en('restricted.title')), findsOneWidget);
    expect(find.byKey(const Key('poster-pages')), findsNothing);
  });
}
