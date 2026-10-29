import 'dart:async';

import 'package:due_kit/due_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/calendar.dart';
import '../../domain/month_brief.dart';
import 'month_view_model.dart';

/// A message along the bottom, optionally with Undo for a payment.
final class Snack {
  const Snack(this.text, {this.undo, this.delta});

  final String text;

  /// The payment Undo reverts.
  final PaymentKey? undo;

  /// Rupees the payment took off the total, shown as a chip by the hero.
  final int? delta;
}

/// Month screen state that is not stored: which month, which day, and the
/// brief feedback after a tap.
final class MonthUi {
  const MonthUi({this.offset = 0, this.scrub, this.flash, this.snack});

  /// Months from the current one, from [MonthController.minOffset] to
  /// [MonthController.maxOffset].
  final int offset;
  final int? scrub;
  final PaymentKey? flash;
  final Snack? snack;

  MonthUi copyWith({int? offset, int? Function()? scrub, PaymentKey? Function()? flash, Snack? Function()? snack}) =>
      MonthUi(
        offset: offset ?? this.offset,
        scrub: scrub == null ? this.scrub : scrub(),
        flash: flash == null ? this.flash : flash(),
        snack: snack == null ? this.snack : snack(),
      );
}

final monthControllerProvider = NotifierProvider<MonthController, MonthUi>(MonthController.new);

class MonthController extends Notifier<MonthUi> {
  static const minOffset = -3;
  static const maxOffset = 6;

  Timer? _flashTimer;
  Timer? _snackTimer;

  @override
  MonthUi build() {
    ref.onDispose(() {
      _flashTimer?.cancel();
      _snackTimer?.cancel();
    });
    return const MonthUi();
  }

  bool get canGoBack => state.offset > minOffset;
  bool get canGoForward => state.offset < maxOffset;

  void previousMonth() => _goTo(state.offset - 1);
  void nextMonth() => _goTo(state.offset + 1);

  void _goTo(int offset) {
    if (offset < minOffset || offset > maxOffset) return;
    state = state.copyWith(offset: offset, scrub: () => null);
  }

  void select(int? day) => state = state.copyWith(scrub: () => day);

  /// Marks a manual item paid, or unpaid if it already was. Autopay items
  /// and history are not the household's to mark.
  Future<void> toggle(DueItem item) async {
    if (!item.toggleable) return;
    final repo = ref.read(repositoryProvider);
    if (item.state == DueState.paid) {
      // Tapping the row just marked paid is the same as Undo.
      if (state.snack?.undo == item.key) return undo();
      await repo.setPaid(item.key, paid: false);
      return;
    }
    await repo.setPaid(item.key, paid: true);
    _flashTimer?.cancel();
    state = state.copyWith(flash: () => item.key);
    _flashTimer = Timer(DueMotion.flash, () => state = state.copyWith(flash: () => null));
    show(Snack('${item.commitment.name} marked paid', undo: item.key, delta: item.amount));
  }

  Future<void> undo() async {
    final key = state.snack?.undo;
    if (key == null) return;
    _snackTimer?.cancel();
    _flashTimer?.cancel();
    state = state.copyWith(snack: () => null, flash: () => null);
    await ref.read(repositoryProvider).setPaid(key, paid: false);
  }

  void show(Snack snack) {
    _snackTimer?.cancel();
    state = state.copyWith(snack: () => snack);
    _snackTimer = Timer(DueMotion.snack, dismiss);
  }

  void dismiss() => state = state.copyWith(snack: () => null);

  void reset() => state = const MonthUi();
}

/// The month on screen, built from the stored household and [MonthUi].
final monthViewProvider = Provider<AsyncValue<MonthView>>((ref) {
  final ui = ref.watch(monthControllerProvider);
  final today = ref.watch(todayProvider);
  return ref
      .watch(householdProvider)
      .whenData(
        (h) => MonthView.of(
          MonthBrief.build(
            month: YearMonth.of(today).plus(ui.offset),
            today: today,
            commitments: h.commitments,
            paid: h.paid,
          ),
          scrub: ui.scrub,
          flash: ui.flash,
          delta: ui.snack?.delta,
        ),
      );
});
