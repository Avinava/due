import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';

import '../frames/frame_scene.dart';
import '../frames/frame_spec.dart';

/// Frames 1a to 1o, live and interactive, grouped by design section.
List<WidgetbookNode> frameNodes() => [
  for (final section in FrameSection.values)
    WidgetbookFolder(
      name: section.title,
      children: [
        for (final spec in frames.where((f) => f.section == section))
          WidgetbookComponent(
            name: '${spec.id} ${spec.title}',
            useCases: [
              WidgetbookUseCase(
                name: spec.dark ? 'Dark' : 'Light',
                builder: (c) => Center(
                  child: FittedBox(child: FrameScene(spec, key: ValueKey(spec.fileName))),
                ),
              ),
            ],
          ),
      ],
    ),
];
