import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/store.dart';
import '../../ui/widgets.dart';
import '../lessons/lesson_visual.dart';

/// Pure quiz state: picks and scoring, independent of any UI.
class QuizSession {
  final List<QuizQ> questions;
  final List<int?> picks;
  QuizSession(this.questions)
    : picks = List<int?>.filled(questions.length, null);

  int get total => questions.length;
  int get answered => picks.where((p) => p != null).length;
  bool get finished => total > 0 && answered == total;
  int get correct {
    var n = 0;
    for (var i = 0; i < total; i++) {
      if (picks[i] != null && questions[i].isCorrect(picks[i]!)) n++;
    }
    return n;
  }

  int get percent => quizPercent(correct, total);

  /// Records an answer once; later picks for the same question are ignored.
  bool answer(int index, int pick) {
    if (index < 0 || index >= total || picks[index] != null) return false;
    if (pick < 0 || pick >= questions[index].options.length) return false;
    picks[index] = pick;
    return true;
  }

  void reset() => picks.fillRange(0, picks.length, null);
}

/// One-question-at-a-time quiz with an explanation after every answer.
/// Feedback always combines icon + words + colour (never colour alone).
class QuizRunner extends StatefulWidget {
  final List<QuizQ> questions;
  final void Function(int correct, int total)? onFinished;
  final VoidCallback? onDone;
  final String? doneLabel;
  final bool celebrate;
  final bool compact;
  const QuizRunner({
    super.key,
    required this.questions,
    this.onFinished,
    this.onDone,
    this.doneLabel,
    this.celebrate = true,
    this.compact = false,
  });

  @override
  State<QuizRunner> createState() => _QuizRunnerState();
}

class _QuizRunnerState extends State<QuizRunner> {
  late QuizSession _s = QuizSession(widget.questions);
  int _i = 0;
  bool _showResult = false;

  @override
  void didUpdateWidget(QuizRunner old) {
    super.didUpdateWidget(old);
    if (old.questions != widget.questions) {
      _s = QuizSession(widget.questions);
      _i = 0;
      _showResult = false;
    }
  }

  void _pick(int o) {
    if (!_s.answer(_i, o)) return;
    HapticFeedback.lightImpact();
    setState(() {});
  }

  void _next() {
    if (_i < _s.total - 1) {
      setState(() => _i++);
    } else {
      widget.onFinished?.call(_s.correct, _s.total);
      setState(() => _showResult = true);
    }
  }

  void _retry() => setState(() {
    _s.reset();
    _i = 0;
    _showResult = false;
  });

  @override
  Widget build(BuildContext context) {
    if (_s.total == 0) {
      return EmptyState(
        title: context.t('quiz.empty'),
        body: context.t('quiz.empty.body'),
      );
    }
    if (_showResult) return _result(context);
    final c = context.c;
    final q = _s.questions[_i];
    final picked = _s.picks[_i];
    final answered = picked != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              context.t('quiz.count', {'n': _i + 1, 'total': _s.total}),
              style: context.tx.labelMedium?.copyWith(color: c.inkSoft),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (_i + (answered ? 1 : 0)) / _s.total,
                  minHeight: 6,
                  color: c.primary,
                  backgroundColor: c.primarySoft,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // A picture of the topic for every question (lessons already have one).
        if (!widget.compact && q.domain.isNotEmpty)
          TopicBanner(
            key: ValueKey('banner-${q.id}'),
            domain: q.domain,
            tracks: q.tracks,
            seed: q.id.hashCode,
            height: 100,
          ),
        if (q.type == QuizType.scenario)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Pill(
              context.t('quiz.scenario'),
              icon: Icons.theater_comedy_rounded,
            ),
          ),
        Text(
          context.lx(q.q),
          style: widget.compact
              ? context.tx.titleLarge
              : context.tx.headlineSmall,
        ),
        const SizedBox(height: 14),
        for (var o = 0; o < q.options.length; o++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Option(
              key: Key('quiz-opt-$o'),
              letter: String.fromCharCode(65 + o),
              text: context.lx(q.options[o]),
              state: !answered
                  ? _OptState.idle
                  : (o == q.answer
                        ? _OptState.correct
                        : (o == picked ? _OptState.wrong : _OptState.dim)),
              onTap: answered ? null : () => _pick(o),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: _FeedbackPop(
              key: ValueKey('pop-$_i'),
              correct: q.isCorrect(picked),
              child: InfoBanner(
                key: const Key('quiz-explain'),
                icon: q.isCorrect(picked)
                    ? Icons.check_circle_rounded
                    : Icons.info_rounded,
                color: q.isCorrect(picked) ? c.success : c.warning,
                title: context.t(
                  q.isCorrect(picked) ? 'quiz.correct' : 'quiz.notQuite',
                ),
                text: context.lx(q.explain),
              ),
            ),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            key: const Key('quiz-next'),
            label: context.t(_i < _s.total - 1 ? 'quiz.next' : 'quiz.finish'),
            icon: Icons.arrow_forward_rounded,
            onPressed: _next,
          ),
        ],
      ],
    );
  }

  Widget _result(BuildContext context) {
    final c = context.c;
    final pct = _s.percent;
    final key = pct >= 80
        ? 'quiz.result.high'
        : (pct >= 50 ? 'quiz.result.mid' : 'quiz.result.low');
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ProgressRing(
              value: pct / 100,
              size: 132,
              stroke: 12,
              color: pct >= 50 ? c.success : c.warning,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_s.correct}/${_s.total}',
                    key: const Key('quiz-score'),
                    style: context.tx.displaySmall,
                  ),
                  Text('$pct%', style: context.tx.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.t(key),
              style: context.tx.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              context.t('quiz.result.note'),
              style: context.tx.bodyMedium?.copyWith(color: c.inkSoft),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SoftButton(
              key: const Key('quiz-retry'),
              label: context.t('quiz.retry'),
              icon: Icons.refresh_rounded,
              onPressed: _retry,
            ),
            if (widget.onDone != null) ...[
              const SizedBox(height: 10),
              PrimaryButton(
                key: const Key('quiz-done'),
                label: widget.doneLabel ?? context.t('common.done'),
                onPressed: widget.onDone,
              ),
            ],
          ],
        ),
        if (widget.celebrate && pct >= 80)
          const Positioned.fill(child: Celebration()),
      ],
    );
  }
}

enum _OptState { idle, correct, wrong, dim }

class _Option extends StatelessWidget {
  final String letter;
  final String text;
  final _OptState state;
  final VoidCallback? onTap;
  const _Option({
    super.key,
    required this.letter,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (border, bg, icon, label) = switch (state) {
      _OptState.idle => (c.outline, c.surface, null, null),
      _OptState.correct => (
        c.success,
        c.success.withValues(alpha: 0.12),
        Icons.check_circle_rounded,
        context.t('quiz.a11y.correct'),
      ),
      _OptState.wrong => (
        c.danger,
        c.danger.withValues(alpha: 0.1),
        Icons.cancel_rounded,
        context.t('quiz.a11y.wrong'),
      ),
      _OptState.dim => (c.outline, c.surface, null, null),
    };
    return Tap(
      onTap: onTap,
      semanticLabel: label == null ? null : '$label: $text',
      child: Opacity(
        opacity: state == _OptState.dim ? 0.55 : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: border,
              width: state == _OptState.idle || state == _OptState.dim
                  ? 1.4
                  : 2.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  letter,
                  textScaler: TextScaler.noScaling,
                  style: context.tx.labelLarge,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: context.tx.bodyLarge)),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: border),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The answer feedback arrives with a little bounce when right and a short
/// shake when not, like a reaction GIF. Still when motion is reduced.
class _FeedbackPop extends StatelessWidget {
  final bool correct;
  final Widget child;
  const _FeedbackPop({super.key, required this.correct, required this.child});

  @override
  Widget build(BuildContext context) {
    if (context.reducedMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: correct ? 520 : 460),
      curve: correct ? Curves.elasticOut : Curves.easeOut,
      builder: (_, v, child) => correct
          ? Transform.scale(scale: 0.85 + 0.15 * v, child: child)
          : Transform.translate(
              offset: Offset(math.sin(v * math.pi * 6) * 10 * (1 - v), 0),
              child: child,
            ),
      child: child,
    );
  }
}
