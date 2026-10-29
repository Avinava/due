import 'package:due_kit/due_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/calendar.dart';
import '../../domain/commitment.dart';
import '../../domain/money.dart';
import '../month/month_controller.dart';
import 'edit_form.dart';

/// Opens the add/edit sheet: a bottom sheet on a phone, a centred dialog on
/// a wide window (frames 1e, 1j).
Future<void> showEditSheet(BuildContext context, {EditForm? initial, Commitment? editing}) {
  final wide = MediaQuery.sizeOf(context).width >= DueSize.wideBreakpoint;
  final sheet = EditSheet(initial: initial ?? (editing == null ? null : EditForm.from(editing)));
  // Colours come from the theme (see dueThemeData), not from this context,
  // so the sheet follows a theme that changes while it is open.
  if (wide) {
    return showDialog<void>(
      context: context,
      builder: (context) => Center(
        child: SizedBox(
          width: DueSize.sheetWide,
          child: Material(
            color: DueTheme.of(context).paper,
            borderRadius: BorderRadius.circular(DueRadius.card),
            clipBehavior: Clip.antiAlias,
            child: sheet,
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => sheet,
  );
}

/// The sheet's content. Holds the [EditForm] while it is open.
class EditSheet extends ConsumerStatefulWidget {
  const EditSheet({super.key, this.initial});

  /// Starting values; a blank form for today when null.
  final EditForm? initial;

  @override
  ConsumerState<EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<EditSheet> {
  late EditForm _form = widget.initial ?? EditForm.blank(ref.read(todayProvider));
  late final _name = TextEditingController(text: _form.name);
  late final _amount = TextEditingController(text: _form.amount == 0 ? '' : groupInr(_form.amount));

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  /// Applies [change] to the form as it is now, never to a copy captured by an
  /// older build.
  void _apply(EditForm Function(EditForm) change) => setState(() => _form = change(_form));

  void _onAmount(String text) {
    final amount = _form.withAmountText(text).amount;
    final shown = amount == 0 ? '' : groupInr(amount);
    if (shown != text) {
      _amount.value = TextEditingValue(
        text: shown,
        selection: TextSelection.collapsed(offset: shown.length),
      );
    }
    _apply((f) => f.copyWith(amount: amount));
  }

  Future<void> _save() async {
    if (!_form.isValid) return;
    final today = ref.read(todayProvider);
    final c = _form.toCommitment(newId: 'c${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}', today: today);
    await ref.read(repositoryProvider).save(c);
    final first = _form.preview.firstOrNull?.date;
    ref
        .read(monthControllerProvider.notifier)
        .show(Snack(_form.isNew ? '${c.name} added${first == null ? '' : ' · first due $first'}' : '${c.name} saved'));
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _archive() async {
    final id = _form.id;
    if (id == null) return;
    final repo = ref.read(repositoryProvider);
    final c = (await repo.load()).commitments.firstWhere((c) => c.id == id);
    await repo.save(c.copyWith(archived: true));
    ref.read(monthControllerProvider.notifier).show(Snack('${c.name} archived'));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final f = _form;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    DueButton(label: 'Cancel', kind: DueButtonKind.text, onPressed: () => Navigator.of(context).pop()),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          f.isNew ? 'New commitment' : 'Edit commitment',
                          textAlign: TextAlign.center,
                          style: DueType.display(18, weight: FontWeight.w600, color: p.ink),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: f.isValid ? 1 : .4,
                      child: DueButton(
                        label: 'Save',
                        kind: DueButtonKind.text,
                        color: p.accentText,
                        bold: true,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _NameAndAmount(
                      name: _name,
                      amount: _amount,
                      onName: (v) => _apply((f) => f.copyWith(name: v)),
                      onAmount: _onAmount,
                    ),
                    const SizedBox(height: 18),
                    const SectionLabel('REPEATS', padding: EdgeInsets.only(bottom: 8)),
                    SegmentedChoice<RepeatKind>(
                      choices: [for (final k in RepeatKind.values) Choice(k, k.label)],
                      selected: f.kind,
                      onSelect: (k) => _apply((f) => f.copyWith(kind: k)),
                    ),
                    const SizedBox(height: 18),
                    _RuleCard(form: f, onChange: _apply),
                    const SizedBox(height: 18),
                    const SectionLabel('NEXT 3 DATES', padding: EdgeInsets.only(bottom: 8)),
                    _Preview(form: f),
                    if (!f.isNew) ...[
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: DueButton(
                          label: 'Archive',
                          kind: DueButtonKind.text,
                          color: p.critical,
                          bold: true,
                          onPressed: _archive,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameAndAmount extends StatelessWidget {
  const _NameAndAmount({required this.name, required this.amount, required this.onName, required this.onAmount});

  final TextEditingController name;
  final TextEditingController amount;
  final ValueChanged<String> onName;
  final ValueChanged<String> onAmount;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Container(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: name,
            onChanged: onName,
            textCapitalization: TextCapitalization.sentences,
            style: DueType.body(18, weight: FontWeight.w600, color: p.ink),
            decoration: InputDecoration.collapsed(
              hintText: 'Name, e.g. Rent',
              hintStyle: DueType.body(18, weight: FontWeight.w600, color: p.soft),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: DueType.display(30, weight: FontWeight.w400, color: p.muted),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: amount,
                  onChanged: onAmount,
                  keyboardType: TextInputType.number,
                  style: DueType.display(52, em: -.04, color: p.ink),
                  decoration: InputDecoration.collapsed(
                    hintText: '0',
                    hintStyle: DueType.display(52, em: -.04, color: p.soft),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The steppers for the chosen repeat, the start month and autopay.
class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.form, required this.onChange});

  final EditForm form;

  /// Receives a change to apply to the current form.
  final void Function(EditForm Function(EditForm)) onChange;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    final f = form;
    Widget stepper(String label, String value, EditForm Function(EditForm, int) step) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 8),
      child: DueStepper(
        label: label,
        value: value,
        onDecrease: () => onChange((f) => step(f, -1)),
        onIncrease: () => onChange((f) => step(f, 1)),
      ),
    );

    return GroupedCard(
      margin: EdgeInsets.zero,
      children: [
        if (f.kind == RepeatKind.everyNMonths) stepper('Every', '${f.months} months', (f, d) => f.stepMonths(d)),
        if (f.kind == RepeatKind.everyNDays) stepper('Every', '${f.days} days', (f, d) => f.stepDays(d)),
        if (f.kind == RepeatKind.weekly)
          stepper('On', weekdayNames[f.weekday - 1], (f, d) => f.stepWeekday(d))
        else if (f.kind == RepeatKind.everyNDays)
          stepper('First on', '${f.day} ${monthShort[f.start.month - 1]}', (f, d) => f.stepDay(d))
        else
          stepper('Due on', 'the ${ordinal(f.day)}', (f, d) => f.stepDay(d)),
        stepper('Starts', f.start.label, (f, d) => f.stepStart(d)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Autopay',
                      style: DueType.body(15, weight: FontWeight.w600, color: p.ink),
                    ),
                    const SizedBox(height: 2),
                    Text('Counts as committed, never as needs-you', style: DueType.body(12, color: p.muted)),
                  ],
                ),
              ),
              DueSwitch(
                value: f.autopay,
                label: 'Autopay',
                onChanged: (v) => onChange((f) => f.copyWith(autopay: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.form});

  final EditForm form;

  @override
  Widget build(BuildContext context) {
    final p = DueTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.ruleStrong)),
          ),
          child: Column(
            children: [
              for (final d in form.preview)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: p.rule)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Text(d.weekday, style: DueType.mono(12, color: p.muted)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          d.date,
                          style: DueType.display(18, weight: FontWeight.w600, color: p.ink),
                        ),
                      ),
                      if (d.note case final note?) NoteChip(note, background: p.warnTint, foreground: p.warnText),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(form.previewNote, style: DueType.body(12, color: p.muted)),
      ],
    );
  }
}
