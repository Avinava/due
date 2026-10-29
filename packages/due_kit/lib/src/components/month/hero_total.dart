import 'package:flutter/widgets.dart';

import '../../foundation/theme.dart';
import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';
import '../display/delta_chip.dart';

enum HeroSize { phone, large, wide }

/// The answer at the top of the month: what still needs the household.
///
/// [amount] counts to its new value over [DueMotion.counter] with an
/// ease-out cubic, so marking an item paid ticks the total down.
class HeroTotal extends StatelessWidget {
  const HeroTotal({
    super.key,
    required this.label,
    required this.amount,
    required this.format,
    required this.subLine,
    this.delta,
    this.done = false,
    this.size = HeroSize.phone,
  });

  /// "NEEDS YOU", "NEEDS YOU IN NOVEMBER", "SETTLED IN SEPTEMBER".
  final String label;
  final int amount;

  /// Formats the figure without the symbol: 73680 -> "73,680".
  final String Function(int) format;

  /// "₹1,23,227 committed · ₹15,547 on autopay".
  final String subLine;

  /// "−₹42,000" just after a payment.
  final String? delta;

  /// The current month has nothing left: shows "Nothing left this month."
  final bool done;
  final HeroSize size;

  /// Finds the animated figure in tests.
  static const figureKey = ValueKey('hero-total-figure');

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final wide = size == HeroSize.wide;
    final labelSize = wide ? 12.0 : DueSize.xs;
    final total = switch (size) {
      HeroSize.phone => DueSize.total,
      HeroSize.large => DueSize.totalLarge,
      HeroSize.wide => DueSize.totalWide,
    };
    final doneSize = size == HeroSize.large ? DueSize.doneLarge : DueSize.done;

    return Semantics(
      container: true,
      liveRegion: true,
      label: done ? 'All settled. Nothing left this month.' : '$label, rupees ${format(amount)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 22),
              child: Row(
                children: [
                  Text(
                    done ? 'ALL SETTLED' : label,
                    style: DueType.mono(
                      labelSize,
                      weight: FontWeight.w600,
                      em: .12,
                      color: done ? p.positive : p.accent,
                    ),
                  ),
                  if (delta != null && !done) ...[const SizedBox(width: 10), DeltaChip(delta!, size: labelSize)],
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (done)
              Text.rich(
                TextSpan(
                  text: 'Nothing left ',
                  children: [
                    TextSpan(
                      text: 'this month.',
                      style: TextStyle(color: p.accent),
                    ),
                  ],
                ),
                textScaler: TextScaler.noScaling,
                style: DueType.display(doneSize, em: -.035, color: p.ink, height: 1),
              )
            else
              TweenAnimationBuilder<double>(
                tween: Tween(end: amount.toDouble()),
                duration: DueMotion.counter,
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text.rich(
                  key: figureKey,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '₹',
                        style: DueType.display(total * (wide ? .5 : .55), weight: FontWeight.w500, color: p.muted),
                      ),
                      WidgetSpan(child: SizedBox(width: wide ? 6 : 4)),
                      TextSpan(text: format(v.round())),
                    ],
                  ),
                  textScaler: TextScaler.noScaling,
                  style: DueType.display(total, em: -.045, color: p.ink, height: .95),
                ),
              ),
            const SizedBox(height: 6),
            Text(subLine, style: DueType.body(wide ? 15 : DueSize.sm, color: p.muted)),
          ],
        ),
      ),
    );
  }
}
