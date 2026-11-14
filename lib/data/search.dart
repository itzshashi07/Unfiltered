import 'dart:math' as math;

import 'models.dart';

/// Offline, rule-based retrieval over the curated FAQ knowledge base.
///
/// This is deliberately NOT generative: it can only return answers that exist
/// in the bundled, reviewable content. Queries are never stored or uploaded.
class SearchEngine {
  final List<Faq> faqs;
  final List<MythCard> myths;
  final List<GlossarySet> glossary;

  final List<Map<String, double>> _weights = [];
  final List<Set<String>> _phrases = [];
  final Map<String, int> _df = {};

  SearchEngine({
    required this.faqs,
    this.myths = const [],
    this.glossary = const [],
  }) {
    for (final f in faqs) {
      final w = <String, double>{};
      void add(String text, double weight) {
        for (final t in tokens(text)) {
          if ((w[t] ?? 0) < weight) w[t] = weight;
        }
      }

      for (final s in f.a.all) {
        add(s, 1);
      }
      for (final s in f.q.all) {
        add(s, 3);
      }
      final phrases = <String>{};
      for (final k in f.keywords) {
        add(k, 4);
        final p = tokens(k).join(' ');
        if (p.contains(' ')) phrases.add(p);
      }
      _weights.add(w);
      _phrases.add(phrases);
      for (final t in w.keys) {
        _df[t] = (_df[t] ?? 0) + 1;
      }
    }
  }

  static final _clean = RegExp(r'[^a-z0-9ऀ-ॿ]+');

  // Multi-word phrases folded into one canonical token before tokenizing.
  static const _phraseMap = <String, String>{
    'wet dream': 'wetdream',
    'wet dreams': 'wetdream',
    'night fall': 'wetdream',
    'nightfall': 'wetdream',
    'swapn dosh': 'wetdream',
    'swapna dosh': 'wetdream',
    'morning after': 'emergencypill',
    'i pill': 'emergencypill',
    'ipill': 'emergencypill',
    'emergency pill': 'emergencypill',
    'emergency contraception': 'emergencypill',
    'safe days': 'safedays',
    'safe day': 'safedays',
    'safe period': 'safedays',
    'good touch': 'safetouch',
    'bad touch': 'unsafetouch',
    'pet se': 'pregnant',
    'white discharge': 'discharge',
    'safed pani': 'discharge',
    'dhat rog': 'dhat',
  };

  // Everyday / Hinglish / Hindi words mapped to one canonical search token.
  static const _syn = <String, String>{
    'periods': 'period',
    'mc': 'period',
    'mahina': 'period',
    'mahine': 'period',
    'mahwari': 'period',
    'mahavari': 'period',
    'masik': 'period',
    'menses': 'period',
    'menstruation': 'period',
    'menstrual': 'period',
    'माहवारी': 'period',
    'पीरियड': 'period',
    'पीरियड्स': 'period',
    'मासिक': 'period',
    'महीना': 'period',
    'masturbate': 'masturbation',
    'masturbating': 'masturbation',
    'hastmaithun': 'masturbation',
    'hasthmaithun': 'masturbation',
    'muth': 'masturbation',
    'hilana': 'masturbation',
    'हस्तमैथुन': 'masturbation',
    'swapndosh': 'wetdream',
    'swapnadosh': 'wetdream',
    'स्वप्नदोष': 'wetdream',
    'ling': 'penis',
    'लिंग': 'penis',
    'yoni': 'vagina',
    'योनि': 'vagina',
    'pregnant': 'pregnancy',
    'garbh': 'pregnancy',
    'garbhvati': 'pregnancy',
    'गर्भ': 'pregnancy',
    'गर्भवती': 'pregnancy',
    'प्रेग्नेंट': 'pregnancy',
    'प्रेगनेंसी': 'pregnancy',
    'condoms': 'condom',
    'nirodh': 'condom',
    'कंडोम': 'condom',
    'kamzori': 'weakness',
    'kamjori': 'weakness',
    'weak': 'weakness',
    'कमज़ोरी': 'weakness',
    'कमजोरी': 'weakness',
    'dard': 'pain',
    'painful': 'pain',
    'cramps': 'pain',
    'cramp': 'pain',
    'दर्द': 'pain',
    'khoon': 'bleeding',
    'blood': 'bleeding',
    'bleed': 'bleeding',
    'खून': 'bleeding',
    'virya': 'semen',
    'sperm': 'semen',
    'वीर्य': 'semen',
    'sahmati': 'consent',
    'permission': 'consent',
    'सहमति': 'consent',
    'kanoon': 'law',
    'kanun': 'law',
    'legal': 'law',
    'laws': 'law',
    'क़ानून': 'law',
    'कानून': 'law',
    'bachcha': 'baby',
    'baccha': 'baby',
    'bachha': 'baby',
    'बच्चा': 'baby',
    'shaadi': 'marriage',
    'shadi': 'marriage',
    'married': 'marriage',
    'शादी': 'marriage',
    'pyaar': 'love',
    'pyar': 'love',
    'प्यार': 'love',
    'darr': 'fear',
    'dar': 'fear',
    'scared': 'fear',
    'afraid': 'fear',
    'डर': 'fear',
    'sharam': 'shame',
    'ashamed': 'shame',
    'embarrassed': 'shame',
    'शर्म': 'shame',
    'muhase': 'acne',
    'pimple': 'acne',
    'pimples': 'acne',
    'मुहांसे': 'acne',
    'baal': 'hair',
    'बाल': 'hair',
    'photos': 'photo',
    'pic': 'photo',
    'pics': 'photo',
    'nudes': 'photo',
    'nude': 'photo',
    'tasveer': 'photo',
    'फोटो': 'photo',
    'dhamki': 'threat',
    'threaten': 'threat',
    'threatening': 'threat',
    'blackmail': 'threat',
    'धमकी': 'threat',
    'ब्लैकमेल': 'threat',
    'doctor': 'doctor',
    'daktar': 'doctor',
    'डॉक्टर': 'doctor',
    'hiv': 'hiv',
    'aids': 'hiv',
    'एड्स': 'hiv',
    'एचआईवी': 'hiv',
    'sti': 'sti',
    'std': 'sti',
    'stis': 'sti',
    'stds': 'sti',
    'infection': 'sti',
    'porn': 'pornography',
    'पोर्न': 'pornography',
    'gay': 'gay',
    'lesbian': 'gay',
    'samlaingik': 'gay',
    'समलैंगिक': 'gay',
    'ladka': 'boy',
    'ladke': 'boy',
    'boys': 'boy',
    'लड़का': 'boy',
    'लड़के': 'boy',
    'ladki': 'girl',
    'ladkiyan': 'girl',
    'girls': 'girl',
    'लड़की': 'girl',
  };

  static const _stop = <String>{
    'the',
    'a',
    'an',
    'is',
    'are',
    'am',
    'i',
    'my',
    'me',
    'to',
    'of',
    'in',
    'on',
    'for',
    'and',
    'or',
    'do',
    'does',
    'did',
    'can',
    'it',
    'what',
    'why',
    'how',
    'when',
    'if',
    'be',
    'have',
    'has',
    'with',
    'from',
    'this',
    'that',
    'will',
    'should',
    'you',
    'your',
    'at',
    'as',
    'so',
    'there',
    'get',
    'about',
    'someone',
    'any',
    'kya',
    'hai',
    'hain',
    'ka',
    'ki',
    'ke',
    'ko',
    'se',
    'mein',
    'par',
    'aur',
    'ya',
    'toh',
    'kaise',
    'kyu',
    'kyun',
    'kyon',
    'kab',
    'hota',
    'hoti',
    'hote',
    'nahi',
    'nahin',
    'na',
    'mera',
    'meri',
    'mere',
    'mujhe',
    'main',
    'hum',
    'kar',
    'karna',
    'kare',
    'karu',
    'raha',
    'rahi',
    'rahe',
    'ho',
    'hu',
    'hoon',
    'tha',
    'thi',
    'bhi',
    'hi',
    'ek',
    'koi',
    'agar',
    'jab',
    'aati',
    'aata',
    'jata',
    'jati',
    'sakta',
    'sakti',
    'sakte',
    'chahiye',
    'क्या',
    'है',
    'हैं',
    'का',
    'की',
    'के',
    'को',
    'से',
    'में',
    'पर',
    'और',
    'या',
    'तो',
    'कैसे',
    'क्यों',
    'कब',
    'होता',
    'होती',
    'होते',
    'नहीं',
    'मेरा',
    'मेरी',
    'मेरे',
    'मुझे',
    'मैं',
    'हम',
    'कर',
    'करना',
    'रहा',
    'रही',
    'हो',
    'हूँ',
    'भी',
    'ही',
    'एक',
    'कोई',
    'अगर',
    'जब',
    'सकता',
    'सकती',
    'सकते',
    'चाहिए',
  };

  static String normalize(String s) {
    var t = s.toLowerCase().replaceAll('़', '').replaceAll(_clean, ' ').trim();
    t = ' $t ';
    _phraseMap.forEach((k, v) => t = t.replaceAll(' $k ', ' $v '));
    return t.trim();
  }

  /// Canonical, de-duplicated search tokens for a piece of text.
  static List<String> tokens(String s) {
    final out = <String>[];
    for (var w in normalize(s).split(' ')) {
      if (w.isEmpty || _stop.contains(w)) continue;
      w = _syn[w] ?? _stem(w);
      w = _syn[w] ?? w;
      if (w.length < 2 || _stop.contains(w)) continue;
      if (!out.contains(w)) out.add(w);
    }
    return out;
  }

  static String _stem(String w) {
    if (w.codeUnitAt(0) > 127) return w;
    if (w.length > 5 && w.endsWith('ing')) return w.substring(0, w.length - 3);
    if (w.length > 3 && w.endsWith('s') && !w.endsWith('ss')) {
      return w.substring(0, w.length - 1);
    }
    return w;
  }

  static final _urgent = RegExp(
    r'rape|raped|molest|assault|abus|forced|forcing|force me|zabardasti|jabardasti|balatkar|'
    r'suicid|kill myself|end my life|want to die|marna chah|mar jau|mar jaun|jaan de|self harm|'
    r'cut myself|blackmail|sextort|threat|dhamki|viral kar|hit me|beats me|maarta hai|marta hai|'
    r'touched me|touch kiya|chhua|not safe|overdose|behosh|faint|heavy bleeding|bahut khoon|'
    r'बलात्कार|ज़बरदस्ती|जबरदस्ती|आत्महत्या|मरना चाह|धमकी|ब्लैकमेल|छेड़|मारता|बेहोश',
  );

  /// True when the question suggests someone may be unsafe right now.
  static bool isUrgent(String query) => _urgent.hasMatch(query.toLowerCase());

  double _idf(String t) => math.log(1 + faqs.length / ((_df[t] ?? 0) + 1));

  /// Returns the best-matching curated FAQs, strongest first. Empty when
  /// nothing in the knowledge base genuinely matches.
  List<Faq> search(String query, {int limit = 6, bool Function(Faq)? where}) {
    final q = tokens(query);
    if (q.isEmpty) return const [];
    final canon = ' ${q.join(' ')} ';
    final scored = <(double, Faq)>[];
    for (var i = 0; i < faqs.length; i++) {
      final f = faqs[i];
      if (where != null && !where(f)) continue;
      final w = _weights[i];
      var score = 0.0;
      var matched = 0;
      var strong = false;
      for (final t in q) {
        final wt = w[t];
        if (wt == null) continue;
        matched++;
        if (wt >= 3) strong = true;
        score += wt * _idf(t);
      }
      if (matched == 0 || !strong) continue;
      if (matched / q.length < 0.5) continue;
      for (final p in _phrases[i]) {
        if (canon.contains(' $p ')) score += 6;
      }
      scored.add((score * (0.6 + 0.4 * matched / q.length), f));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    if (scored.isEmpty) return const [];
    final top = scored.first.$1;
    return [
      for (final s in scored.take(limit))
        if (s.$1 >= top * 0.35) s.$2,
    ];
  }

  /// Myth cards whose claim shares meaningful words with the query.
  List<MythCard> searchMyths(
    String query, {
    int limit = 3,
    bool Function(MythCard)? where,
  }) {
    final q = tokens(query).toSet();
    if (q.isEmpty) return const [];
    final scored = <(int, MythCard)>[];
    for (final m in myths) {
      if (where != null && !where(m)) continue;
      final t = {for (final s in m.claim.all) ...tokens(s)};
      final hit = q.intersection(t).length;
      if (hit >= math.max(1, (q.length / 2).ceil())) scored.add((hit, m));
    }
    scored.sort((a, b) => b.$1.compareTo(a.$1));
    return [for (final s in scored.take(limit)) s.$2];
  }

  /// Glossary terms matching the query text directly.
  List<GlossaryTerm> searchTerms(
    String query, {
    int limit = 4,
    bool Function(GlossarySet)? where,
  }) {
    final n = normalize(query);
    if (n.length < 2) return const [];
    final out = <GlossaryTerm>[];
    for (final g in glossary) {
      if (where != null && !where(g)) continue;
      for (final t in g.terms) {
        if (t.term.all.any((s) {
          final ns = normalize(s);
          return ns.isNotEmpty &&
              (n.contains(ns) || (n.length >= 3 && ns.contains(n)));
        })) {
          out.add(t);
          if (out.length >= limit) return out;
        }
      }
    }
    return out;
  }
}
