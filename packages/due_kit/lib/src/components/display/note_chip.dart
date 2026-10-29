import 'package:flutter/widgets.dart';

import '../../foundation/tokens.g.dart';
import '../../foundation/type.dart';

/// A small mono chip, e.g. "Clamped from 31st".
class NoteChip extends StatelessWidget {
  const NoteChip(this.text, {super.key, required this.background, required this.foreground});

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(DueRadius.chip)),
    child: Text(
      text,
      style: DueType.mono(11, weight: FontWeight.w600, color: foreground),
    ),
  );
}
