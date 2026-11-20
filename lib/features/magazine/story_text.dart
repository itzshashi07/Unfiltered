import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';

/// Renders a magazine story's Markdown: headings, paragraphs, lists, quotes,
/// tables, rules, **bold**, *italic*, links and `[[source-id]]` citations,
/// which become numbered superscripts (tap one to see the source).
class StoryText extends StatelessWidget {
  final String markdown;
  final int Function(String id) citeNumber;
  final void Function(String id) onCite;
  const StoryText({
    super.key,
    required this.markdown,
    required this.citeNumber,
    required this.onCite,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = _parse(markdown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final b in blocks) _block(context, b)],
    );
  }

  Widget _block(BuildContext context, _Block b) {
    final c = context.c;
    final body = context.tx.bodyLarge!.copyWith(height: 1.6, fontSize: 16.5);
    switch (b.kind) {
      case _Kind.h2:
        return Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 8),
          child: Semantics(
            header: true,
            child: Text.rich(
              _inline(context, b.lines.first, context.tx.headlineSmall!),
            ),
          ),
        );
      case _Kind.h3:
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Semantics(
            header: true,
            child: Text.rich(
              _inline(context, b.lines.first, context.tx.titleLarge!),
            ),
          ),
        );
      case _Kind.hr:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Divider(color: c.outline),
        );
      case _Kind.quote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: c.coral, width: 4)),
            color: c.surfaceAlt,
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
          child: Text.rich(
            _inline(
              context,
              b.lines.join(' '),
              body.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        );
      case _Kind.ul:
      case _Kind.ol:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < b.lines.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text(
                          b.kind == _Kind.ol ? '${i + 1}.' : '•',
                          style: body.copyWith(
                            color: c.coral,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text.rich(_inline(context, b.lines[i], body)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      case _Kind.table:
        return _table(context, b.lines);
      case _Kind.p:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text.rich(_inline(context, b.lines.join(' '), body)),
        );
    }
  }

  Widget _table(BuildContext context, List<String> rows) {
    final c = context.c;
    List<String> cells(String r) {
      var s = r.trim();
      if (s.startsWith('|')) s = s.substring(1);
      if (s.endsWith('|')) s = s.substring(0, s.length - 1);
      return [for (final x in s.split('|')) x.trim()];
    }

    final parsed = [
      for (final r in rows)
        if (!RegExp(r'^\s*\|?\s*:?-{2,}').hasMatch(r)) cells(r),
    ];
    if (parsed.isEmpty) return const SizedBox.shrink();
    final n = parsed.map((r) => r.length).reduce((a, b) => a > b ? a : b);
    final style = context.tx.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.sizeOf(context).width - 40,
          ),
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder(horizontalInside: BorderSide(color: c.outline)),
            children: [
              for (var i = 0; i < parsed.length; i++)
                TableRow(
                  decoration: i == 0
                      ? BoxDecoration(color: c.surfaceAlt)
                      : null,
                  children: [
                    for (var k = 0; k < n; k++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: Text.rich(
                            _inline(
                              context,
                              k < parsed[i].length ? parsed[i][k] : '',
                              i == 0
                                  ? style.copyWith(fontWeight: FontWeight.w800)
                                  : style,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static final _token = RegExp(
    r'\*\*(.+?)\*\*|\*(?!\s)(.+?)\*|_(?!\s)(.+?)_(?![a-zA-Z0-9])|`([^`]+)`|\[\[([a-z0-9][a-z0-9-]*)\]\]|\[([^\]]+)\]\(([^)\s]+)\)',
  );

  InlineSpan _inline(BuildContext context, String text, TextStyle base) {
    final c = context.c;
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _token.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      if (m.group(1) != null) {
        spans.add(
          _inline(
            context,
            m.group(1)!,
            base.copyWith(fontWeight: FontWeight.w800),
          ),
        );
      } else if (m.group(2) != null || m.group(3) != null) {
        spans.add(
          _inline(
            context,
            (m.group(2) ?? m.group(3))!,
            base.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (m.group(4) != null) {
        spans.add(
          TextSpan(
            text: m.group(4),
            style: base.copyWith(fontFamily: 'monospace'),
          ),
        );
      } else if (m.group(5) != null) {
        final id = m.group(5)!;
        final n = citeNumber(id);
        // "claim [[id]]." reads "claim¹."
        if (spans.isNotEmpty && spans.last is TextSpan) {
          final t = (spans.last as TextSpan).text ?? '';
          if (t.endsWith(' ')) {
            spans[spans.length - 1] = TextSpan(text: t.trimRight());
          }
        }
        if (n > 0) {
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.top,
              child: Semantics(
                button: true,
                label: 'source $n',
                child: InkWell(
                  onTap: () => onCite(id),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '$n',
                      style: base.copyWith(
                        fontSize: (base.fontSize ?? 16) * 0.68,
                        color: c.coral,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } else if (m.group(6) != null) {
        final url = m.group(7)!;
        spans.add(
          TextSpan(
            text: m.group(6),
            style: base.copyWith(
              color: c.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
          ),
        );
      }
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return TextSpan(style: base, children: spans);
  }
}

enum _Kind { h2, h3, p, ul, ol, quote, table, hr }

class _Block {
  final _Kind kind;
  final List<String> lines;
  _Block(this.kind, this.lines);
}

List<_Block> _parse(String md) {
  final out = <_Block>[];
  _Block? cur;
  void close() {
    if (cur != null) out.add(cur!);
    cur = null;
  }

  for (final raw in md.split('\n')) {
    final line = raw.trimRight();
    final t = line.trimLeft();
    if (t.isEmpty) {
      close();
      continue;
    }
    if (t.startsWith('### ')) {
      close();
      out.add(_Block(_Kind.h3, [t.substring(4)]));
    } else if (t.startsWith('## ') || t.startsWith('# ')) {
      close();
      out.add(_Block(_Kind.h2, [t.replaceFirst(RegExp(r'^#+\s'), '')]));
    } else if (RegExp(r'^(-{3,}|\*{3,})$').hasMatch(t)) {
      close();
      out.add(_Block(_Kind.hr, const []));
    } else if (t.startsWith('|')) {
      if (cur?.kind != _Kind.table) {
        close();
        cur = _Block(_Kind.table, []);
      }
      cur!.lines.add(t);
    } else if (t.startsWith('> ') || t == '>') {
      if (cur?.kind != _Kind.quote) {
        close();
        cur = _Block(_Kind.quote, []);
      }
      cur!.lines.add(t.replaceFirst(RegExp(r'^>\s?'), ''));
    } else if (RegExp(r'^[-*+]\s').hasMatch(t)) {
      if (cur?.kind != _Kind.ul) {
        close();
        cur = _Block(_Kind.ul, []);
      }
      cur!.lines.add(t.substring(2));
    } else if (RegExp(r'^\d+[.)]\s').hasMatch(t)) {
      if (cur?.kind != _Kind.ol) {
        close();
        cur = _Block(_Kind.ol, []);
      }
      cur!.lines.add(t.replaceFirst(RegExp(r'^\d+[.)]\s'), ''));
    } else if ((cur?.kind == _Kind.ul || cur?.kind == _Kind.ol) &&
        raw.startsWith('  ')) {
      cur!.lines[cur!.lines.length - 1] += ' $t'; // continuation of a list item
    } else {
      if (cur?.kind != _Kind.p) {
        close();
        cur = _Block(_Kind.p, []);
      }
      cur!.lines.add(t);
    }
  }
  close();
  return out;
}
