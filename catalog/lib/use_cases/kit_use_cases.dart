import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

/// Every kit component and state, grouped as in packages/due_kit/lib/src.
List<WidgetbookNode> kitNodes() => [
  WidgetbookFolder(
    name: 'Month',
    children: [
      WidgetbookComponent(
        name: 'DueDial',
        useCases: [
          WidgetbookUseCase(
            name: 'Current month',
            builder: (c) => _Dial(model: _dial()),
          ),
          WidgetbookUseCase(
            name: 'Scrubbed',
            builder: (c) => _Dial(model: _dial(selected: 15)),
          ),
          WidgetbookUseCase(
            name: 'All paid',
            builder: (c) => _Dial(model: _dial(allPaid: true)),
          ),
          WidgetbookUseCase(
            name: 'Future month',
            builder: (c) => _Dial(
              model: const DialModel(
                days: 30,
                marks: [
                  DialMark(day: 1, state: MarkState.due, label: '1 November, Rent, ₹28,000, unpaid'),
                  DialMark(day: 5, state: MarkState.due, label: '5 November, Maid, ₹6,000, unpaid'),
                  DialMark(day: 18, state: MarkState.auto, label: '18 November, Netflix, ₹649, autopay'),
                ],
                line1: 'NOVEMBER',
                line2: '6 charges',
                line3: '₹49,547 committed',
              ),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'CommitmentRow',
        useCases: [
          for (final layout in RowLayout.values)
            WidgetbookUseCase(
              name: layout.name,
              builder: (c) {
                final state = c.knobs.object.dropdown(
                  label: 'State',
                  options: MarkState.values,
                  labelBuilder: (s) => s.name,
                );
                return _Pad(
                  width: layout == RowLayout.wide ? 720 : 390,
                  child: CommitmentRow(
                    _row(state, flashing: c.knobs.boolean(label: 'Flashing')),
                    layout: layout,
                    onTap: () {},
                  ),
                );
              },
            ),
        ],
      ),
      WidgetbookComponent(
        name: 'HeroTotal',
        useCases: [
          for (final size in HeroSize.values)
            WidgetbookUseCase(
              name: size.name,
              builder: (c) => _Pad(
                child: HeroTotal(
                  label: 'NEEDS YOU',
                  amount: c.knobs.int.input(label: 'Amount', initialValue: 73680),
                  format: (v) => v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d\d)*\d{3}$)'), (m) => '${m[1]},'),
                  subLine: '₹1,23,227 committed · ₹15,547 on autopay',
                  delta: c.knobs.boolean(label: 'Just paid') ? '−₹42,000' : null,
                  done: c.knobs.boolean(label: 'Settled'),
                  size: size,
                ),
              ),
            ),
        ],
      ),
      WidgetbookComponent(
        name: 'DayGroupHeader',
        useCases: [
          WidgetbookUseCase(
            name: 'Day',
            builder: (c) => const _Pad(child: DayGroupHeader('SAT 10')),
          ),
          WidgetbookUseCase(
            name: 'Today',
            builder: (c) => const _Pad(child: DayGroupHeader('TODAY · MON 12', isToday: true)),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Inputs',
    children: [
      WidgetbookComponent(
        name: 'DueSwitch',
        useCases: [WidgetbookUseCase(name: 'Default', builder: (c) => const _SwitchDemo())],
      ),
      WidgetbookComponent(
        name: 'DueStepper',
        useCases: [WidgetbookUseCase(name: 'Default', builder: (c) => const _StepperDemo())],
      ),
      WidgetbookComponent(
        name: 'SegmentedChoice',
        useCases: [
          WidgetbookUseCase(
            name: 'Tiles',
            builder: (c) => const _SegmentDemo(style: SegmentedStyle.tiles),
          ),
          WidgetbookUseCase(
            name: 'Tabs',
            builder: (c) => const _SegmentDemo(style: SegmentedStyle.tabs),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Buttons',
    children: [
      WidgetbookComponent(
        name: 'DueButton',
        useCases: [
          for (final kind in DueButtonKind.values)
            WidgetbookUseCase(
              name: kind.name,
              builder: (c) => Center(
                child: DueButton(
                  label: c.knobs.string(
                    label: 'Label',
                    initialValue: kind == DueButtonKind.accent ? 'Add' : 'Settings',
                  ),
                  leading: kind == DueButtonKind.accent ? '+' : null,
                  kind: kind,
                  height: kind == DueButtonKind.accent ? 56 : null,
                  onPressed: () {},
                ),
              ),
            ),
        ],
      ),
      WidgetbookComponent(
        name: 'ArrowButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Bare',
            builder: (c) =>
                _row2([ArrowButton(forward: false, onPressed: () {}), ArrowButton(forward: true, onPressed: () {})]),
          ),
          WidgetbookUseCase(
            name: 'Boxed',
            builder: (c) => _row2([
              ArrowButton(forward: false, boxed: true, onPressed: () {}),
              ArrowButton(forward: true, boxed: true, onPressed: () {}),
            ]),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'MenuButton',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (c) => Center(child: MenuButton(onPressed: () {})),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Display',
    children: [
      WidgetbookComponent(
        name: 'StatusMark',
        useCases: [
          WidgetbookUseCase(
            name: 'All states',
            builder: (c) => _row2([
              for (final s in MarkState.values)
                StatusMark(s, size: c.knobs.double.slider(label: 'Size', initialValue: 26, min: 20, max: 48)),
            ]),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Wordmark',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (c) => Center(
              child: Wordmark(size: c.knobs.double.slider(label: 'Size', initialValue: 28, min: 16, max: 120)),
            ),
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'Chips',
        useCases: [
          WidgetbookUseCase(
            name: 'DeltaChip',
            builder: (c) => const Center(child: DeltaChip('−₹42,000')),
          ),
          WidgetbookUseCase(
            name: 'NoteChip',
            builder: (c) {
              final p = DueTheme.of(c);
              return Center(
                child: NoteChip('Clamped from 31st', background: p.warnTint, foreground: p.warnText),
              );
            },
          ),
          WidgetbookUseCase(
            name: 'LegendDot',
            builder: (c) {
              final p = DueTheme.of(c);
              return _row2([
                LegendDot(label: 'Needs you', color: p.accent),
                LegendDot(label: 'Autopay', color: p.muted, hollow: true),
                LegendDot(label: 'Paid', color: p.ink),
              ]);
            },
          ),
        ],
      ),
      WidgetbookComponent(
        name: 'SectionLabel',
        useCases: [
          WidgetbookUseCase(
            name: 'Default',
            builder: (c) => const _Pad(child: SectionLabel('REMINDERS')),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Feedback',
    children: [
      WidgetbookComponent(
        name: 'DueSnack',
        useCases: [
          WidgetbookUseCase(
            name: 'With undo',
            builder: (c) => _Pad(
              child: DueSnack(text: 'School fees marked paid', onUndo: () {}),
            ),
          ),
          WidgetbookUseCase(
            name: 'Message',
            builder: (c) => const _Pad(child: DueSnack(text: 'Sample household restored')),
          ),
        ],
      ),
    ],
  ),
  WidgetbookFolder(
    name: 'Foundation',
    children: [
      WidgetbookComponent(
        name: 'Palette',
        useCases: [WidgetbookUseCase(name: 'Roles', builder: (c) => const _PaletteSheet())],
      ),
      WidgetbookComponent(
        name: 'Type',
        useCases: [WidgetbookUseCase(name: 'Roles', builder: (c) => const _TypeSheet())],
      ),
    ],
  ),
];

DialModel _dial({int? selected, bool allPaid = false}) {
  MarkState s(MarkState open) => allPaid ? MarkState.paid : open;
  return DialModel(
    days: 31,
    today: 12,
    selected: selected,
    elapsedDays: 11,
    marks: [
      const DialMark(day: 1, state: MarkState.paid, label: '1 October, Rent, ₹28,000, paid'),
      const DialMark(day: 3, state: MarkState.settled, label: '3 October, Jio prepaid, ₹349, paid'),
      const DialMark(day: 5, state: MarkState.paid, label: '5 October, Maid, ₹6,000, paid'),
      const DialMark(day: 7, state: MarkState.settled, label: '7 October, Car EMI, ₹14,200, paid'),
      DialMark(day: 10, state: s(MarkState.late), label: '10 October, Society maintenance, ₹7,500'),
      DialMark(day: 15, state: s(MarkState.due), label: '15 October, School fees, ₹42,000'),
      const DialMark(day: 18, state: MarkState.auto, label: '18 October, Netflix, ₹649, autopay'),
      DialMark(day: 22, state: s(MarkState.due), label: '22 October, LIC premium, ₹24,180'),
      const DialMark(day: 31, state: MarkState.auto, label: '31 October, Jio prepaid, ₹349, autopay'),
    ],
    line1: selected == null ? 'MON 12 OCT' : 'THU 15 OCT',
    line2: allPaid ? 'All clear' : (selected == null ? '19 days left' : '₹42,000'),
    line3: allPaid
        ? '2 autopays still to run'
        : (selected == null ? 'Next: Society maintenance, Sat 10' : 'School fees · needs you'),
  );
}

RowModel _row(MarkState state, {bool flashing = false}) => RowModel(
  id: 'school',
  name: 'School fees',
  schedule: state.isAutopay ? 'Monthly · autopay' : 'Term 2 of 3',
  amount: '₹42,000',
  status: switch (state) {
    MarkState.due => 'Due Thu 15',
    MarkState.late => '2 days late',
    MarkState.paid => 'Paid',
    MarkState.auto => 'Autopay Thu 15',
    MarkState.settled => 'Autopay · settled',
  },
  state: state,
  semanticLabel: '15 October, School fees, ₹42,000',
  flashing: flashing,
);

/// Lets the dial be scrubbed in the catalog.
class _Dial extends StatefulWidget {
  const _Dial({required this.model});

  final DialModel model;

  @override
  State<_Dial> createState() => _DialState();
}

class _DialState extends State<_Dial> {
  late int? _selected = widget.model.selected;

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    return Center(
      child: DueDial(
        model: DialModel(
          days: m.days,
          marks: m.marks,
          today: m.today,
          selected: _selected,
          elapsedDays: m.elapsedDays,
          line1: _selected == null ? m.line1 : 'DAY $_selected',
          line2: m.line2,
          line3: m.line3,
        ),
        onSelect: (d) => setState(() => _selected = d),
      ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.child, this.width = 390});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: width,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    ),
  );
}

Widget _row2(List<Widget> children) => Center(
  child: Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: children),
);

class _SwitchDemo extends StatefulWidget {
  const _SwitchDemo();

  @override
  State<_SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<_SwitchDemo> {
  bool _on = true;

  @override
  Widget build(BuildContext context) => Center(
    child: DueSwitch(value: _on, label: 'Reminders', onChanged: (v) => setState(() => _on = v)),
  );
}

class _StepperDemo extends StatefulWidget {
  const _StepperDemo();

  @override
  State<_StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<_StepperDemo> {
  int _n = 3;

  @override
  Widget build(BuildContext context) => _Pad(
    child: DueStepper(
      label: 'Every',
      value: '$_n months',
      onDecrease: () => setState(() => _n = (_n - 1).clamp(2, 24)),
      onIncrease: () => setState(() => _n = (_n + 1).clamp(2, 24)),
    ),
  );
}

class _SegmentDemo extends StatefulWidget {
  const _SegmentDemo({required this.style});

  final SegmentedStyle style;

  @override
  State<_SegmentDemo> createState() => _SegmentDemoState();
}

class _SegmentDemoState extends State<_SegmentDemo> {
  late String _v = widget.style == SegmentedStyle.tabs ? 'System' : 'Monthly';

  @override
  Widget build(BuildContext context) {
    final options = widget.style == SegmentedStyle.tabs
        ? ['Light', 'Dark', 'System']
        : ['Monthly', 'Every N months', 'Weekly', 'Every N days'];
    return _Pad(
      child: SegmentedChoice<String>(
        style: widget.style,
        columns: widget.style == SegmentedStyle.tabs ? 3 : 2,
        choices: [for (final o in options) Choice(o, o)],
        selected: _v,
        onSelect: (v) => setState(() => _v = v),
      ),
    );
  }
}

class _PaletteSheet extends StatelessWidget {
  const _PaletteSheet();

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final roles = <String, Color>{
      'paper': p.paper,
      'surface': p.surface,
      'ink': p.ink,
      'muted': p.muted,
      'soft': p.soft,
      'rule': p.rule,
      'ruleStrong': p.ruleStrong,
      'accent': p.accent,
      'accentText': p.accentText,
      'accentTint': p.accentTint,
      'positive': p.positive,
      'warning': p.warning,
      'critical': p.critical,
      'lateBg': p.lateBg,
      'flashBg': p.flashBg,
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final MapEntry(key: name, value: color) in roles.entries)
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: p.rule),
                      borderRadius: BorderRadius.circular(DueRadius.card),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: DueType.body(13, weight: FontWeight.w600, color: p.ink),
                  ),
                  Text(
                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: DueType.mono(11, color: p.muted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TypeSheet extends StatelessWidget {
  const _TypeSheet();

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('₹73,680', style: DueType.display(DueSize.total, em: -.045, color: p.ink)),
        Text('Display · Bricolage Grotesque · totals and amounts', style: DueType.body(13, color: p.muted)),
        const SizedBox(height: 24),
        Text(
          'Society maintenance',
          style: DueType.body(DueSize.md, weight: FontWeight.w600, color: p.ink),
        ),
        Text('Body · Hanken Grotesk · names and copy', style: DueType.body(13, color: p.muted)),
        const SizedBox(height: 24),
        Text('TODAY · MON 12', style: DueType.mono(DueSize.xs, em: .1, color: p.accentText)),
        Text('Mono · JetBrains Mono · labels and dates', style: DueType.body(13, color: p.muted)),
      ],
    );
  }
}
