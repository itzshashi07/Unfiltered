import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n.dart';
import 'content.dart';

/// The UNFILTERED Magazine and Data Desk: the website's fact-checked stories,
/// shipped inside the app (assets/content/magazine, built by
/// tools/export_web_content.py). Loaded lazily, the first time it is opened.
const kMagazineRoot = 'magazine';

L _l(dynamic j) => L.from(j);

class MagSection {
  final String key;
  final Color accent;
  final String motif;
  final L title;
  final L tagline;
  const MagSection({
    required this.key,
    required this.accent,
    required this.motif,
    required this.title,
    required this.tagline,
  });

  factory MagSection.fromJson(Map<String, dynamic> j) => MagSection(
    key: j['key'] as String,
    accent: _hex(j['accent'] as String? ?? '#ff3b47'),
    motif: j['motif'] as String? ?? '',
    title: _l(j['title']),
    tagline: _l(j['tagline']),
  );
}

Color _hex(String s) {
  final h = s.replaceFirst('#', '');
  return Color(int.parse(h.length == 6 ? 'ff$h' : h, radix: 16));
}

class KeyNumber {
  final String value;
  final L label;
  final String source;
  const KeyNumber(this.value, this.label, this.source);
}

class MagStory {
  final String slug;
  final String section;
  final String format;
  final DateTime? date;
  final int minutes;
  final int minAge;
  final L title;
  final L dek;
  final List<String> cw;
  final List<String> tags;
  final String motif;
  final String photo;
  final String stat;
  final L statLabel;
  final List<KeyNumber> keyNumbers;
  final L? mythClaim;
  final L? mythTruth;
  final List<L> actions;
  final List<String> sources;
  final List<String> related;
  final bool featured;
  final int? year;

  const MagStory({
    required this.slug,
    required this.section,
    required this.format,
    required this.date,
    required this.minutes,
    required this.minAge,
    required this.title,
    required this.dek,
    required this.cw,
    required this.tags,
    required this.motif,
    required this.photo,
    required this.stat,
    required this.statLabel,
    required this.keyNumbers,
    required this.mythClaim,
    required this.mythTruth,
    required this.actions,
    required this.sources,
    required this.related,
    required this.featured,
    required this.year,
  });

  factory MagStory.fromJson(Map<String, dynamic> j) {
    final cover = (j['cover'] as Map?)?.cast<String, dynamic>() ?? const {};
    final myth = (j['myth'] as Map?)?.cast<String, dynamic>();
    List<String> strs(Object? o) => [
      for (final x in (o as List?) ?? const []) '$x',
    ];
    return MagStory(
      slug: j['slug'] as String,
      section: j['section'] as String,
      format: j['format'] as String? ?? 'explainer',
      date: DateTime.tryParse('${j['date'] ?? ''}'),
      minutes: (j['minutes'] as num?)?.toInt() ?? 5,
      minAge: (j['minAge'] as num?)?.toInt() ?? 16,
      title: _l(j['title']),
      dek: _l(j['dek']),
      cw: strs(j['cw']),
      tags: strs(j['tags']),
      motif: cover['motif'] as String? ?? '',
      photo: cover['photo'] as String? ?? '',
      stat: '${cover['stat'] ?? ''}',
      statLabel: _l(cover['statLabel']),
      keyNumbers: [
        for (final k in (j['keyNumbers'] as List?) ?? const [])
          KeyNumber('${k['value']}', _l(k['label']), '${k['source'] ?? ''}'),
      ],
      mythClaim: myth == null ? null : _l(myth['claim']),
      mythTruth: myth == null ? null : _l(myth['truth']),
      actions: [for (final a in (j['actions'] as List?) ?? const []) _l(a)],
      sources: strs(j['sources']),
      related: strs(j['related']),
      featured: j['featured'] == true,
      year: (j['year'] as num?)?.toInt(),
    );
  }

  /// Who may read it: the magazine is for 16+ tracks; 18+ stories for adults.
  bool visibleTo(Track t) =>
      t.index >= Track.d.index && (minAge <= 16 || t == Track.e);

  /// Citation number shown for a source id (follows the order of [sources]).
  int citeNumber(String id) => sources.indexOf(id) + 1;
}

class MagSource {
  final String title;
  final String publisher;
  final String year;
  final String url;
  const MagSource(this.title, this.publisher, this.year, this.url);
}

class PhotoCredit {
  final String author;
  final String license;
  final String sourceUrl;
  final L alt;
  const PhotoCredit(this.author, this.license, this.sourceUrl, this.alt);
}

class MagStat {
  final String value;
  final L label;
  final String source;
  const MagStat(this.value, this.label, this.source);
}

class Magazine {
  final List<MagSection> sections;
  final List<MagStory> stories;
  final Map<String, MagSource> sources;
  final Map<String, PhotoCredit> photos;
  final List<MagStat> stats;
  final List<L> ticker;

  const Magazine({
    required this.sections,
    required this.stories,
    required this.sources,
    required this.photos,
    required this.stats,
    required this.ticker,
  });

  static const empty = Magazine(
    sections: [],
    stories: [],
    sources: {},
    photos: {},
    stats: [],
    ticker: [],
  );

  MagSection? section(String key) {
    for (final s in sections) {
      if (s.key == key) return s;
    }
    return null;
  }

  MagStory? story(String slug) {
    for (final s in stories) {
      if (s.slug == slug) return s;
    }
    return null;
  }

  List<MagStory> visible(Track t, {String? section}) => [
    for (final s in stories)
      if (s.visibleTo(t) && (section == null || s.section == section)) s,
  ];

  /// Plain-text search over titles, summaries and tags, in both languages.
  List<MagStory> search(String query, Track t) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .toList();
    if (words.isEmpty) return const [];
    final hits = <(int, MagStory)>[];
    for (final s in visible(t)) {
      final title = '${s.title.en} ${s.title.hg}'.toLowerCase();
      final rest = '${s.dek.en} ${s.dek.hg} ${s.tags.join(' ')} ${s.format}'
          .toLowerCase();
      var score = 0;
      for (final w in words) {
        if (title.contains(w)) {
          score += 3;
        } else if (rest.contains(w)) {
          score += 1;
        } else {
          score = -1;
          break;
        }
      }
      if (score > 0) hits.add((score, s));
    }
    hits.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final h in hits) h.$2];
  }

  static String photoAsset(String id) => 'assets/images/photos/$id.webp';

  static Future<Magazine> load(ContentReader read) async {
    Future<dynamic> j(String p) async {
      final s = await read('$kMagazineRoot/$p');
      return s == null ? null : jsonDecode(s);
    }

    final sections = await j('sections.json') as List?;
    final index = await j('index.json') as List?;
    if (sections == null || index == null) return empty;
    final sources = (await j('sources.json') as Map?) ?? const {};
    final photos = (await j('photos.json') as Map?) ?? const {};
    final stats = (await j('stats.json') as Map?) ?? const {};
    return Magazine(
      sections: [
        for (final s in sections)
          MagSection.fromJson((s as Map).cast<String, dynamic>()),
      ],
      stories: [
        for (final s in index)
          MagStory.fromJson((s as Map).cast<String, dynamic>()),
      ],
      sources: {
        for (final e in sources.entries)
          '${e.key}': MagSource(
            '${e.value['title'] ?? e.key}',
            '${e.value['publisher'] ?? ''}',
            e.value['year'] == null ? '' : '${e.value['year']}',
            '${e.value['url'] ?? ''}',
          ),
      },
      photos: {
        for (final e in photos.entries)
          '${e.key}': PhotoCredit(
            '${e.value['author'] ?? ''}',
            '${e.value['license'] ?? ''}',
            '${e.value['sourceUrl'] ?? ''}',
            _l(e.value['alt']),
          ),
      },
      stats: [
        for (final s in (stats['stats'] as List?) ?? const [])
          MagStat('${s['value']}', _l(s['label']), '${s['source'] ?? ''}'),
      ],
      ticker: [
        for (final t in (stats['ticker'] as List?) ?? const []) _l(t['text']),
      ],
    );
  }

  /// Story texts of one section: slug -> Markdown in English and Hinglish.
  static Future<Map<String, L>> loadBodies(
    ContentReader read,
    String section,
  ) async {
    final s = await read('$kMagazineRoot/stories/$section.json');
    if (s == null) return const {};
    final m = jsonDecode(s) as Map;
    return {for (final e in m.entries) '${e.key}': _l(e.value)};
  }
}

class Fact {
  final String id;
  final L text;
  final String value;
  final String year;
  final String source;
  final String caveat;
  const Fact(
    this.id,
    this.text,
    this.value,
    this.year,
    this.source,
    this.caveat,
  );
}

class FactArea {
  final String key;
  final L title;
  final List<Fact> facts;
  const FactArea(this.key, this.title, this.facts);

  static Future<List<FactArea>> load(ContentReader read) async {
    final s = await read('$kMagazineRoot/datadesk.json');
    if (s == null) return const [];
    return [
      for (final a in jsonDecode(s) as List)
        FactArea('${a['key']}', _l(a['title']), [
          for (final f in a['facts'] as List)
            Fact(
              '${f['id']}',
              _l(f['text']),
              '${f['value'] ?? ''}',
              f['year'] == null ? '' : '${f['year']}',
              '${f['source'] ?? ''}',
              '${f['caveat'] ?? ''}',
            ),
        ]),
    ];
  }
}

/// How magazine files are read: the app bundle by default, files in tests.
final magazineReaderProvider = Provider<ContentReader>(
  (ref) => (p) async {
    try {
      return await rootBundle.loadString('$kContentRoot/$p');
    } catch (_) {
      return null;
    }
  },
);

final magazineProvider = FutureProvider<Magazine>(
  (ref) => Magazine.load(ref.watch(magazineReaderProvider)),
);

final storyBodiesProvider = FutureProvider.family<Map<String, L>, String>(
  (ref, section) =>
      Magazine.loadBodies(ref.watch(magazineReaderProvider), section),
);

final dataDeskProvider = FutureProvider<List<FactArea>>(
  (ref) => FactArea.load(ref.watch(magazineReaderProvider)),
);
