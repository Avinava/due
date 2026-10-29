import 'package:flutter/widgets.dart';

/// True when the system text size is large enough that the design switches
/// to its large layout (frame 1g): rows become cards and the dial steps down.
bool isLargeText(BuildContext context) => MediaQuery.textScalerOf(context).scale(10) / 10 > 1.4;
