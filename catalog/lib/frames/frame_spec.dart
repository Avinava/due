import 'package:due/domain/calendar.dart';
import 'package:due/domain/month_brief.dart';
import 'package:due/features/edit/edit_form.dart';
import 'package:due/features/month/month_controller.dart';
import 'package:flutter/widgets.dart';

/// "Today" in every frame.
final frameToday = DateTime.utc(2026, 10, 12);

enum FrameKind {
  phone(Size(390, 844)),
  wide(Size(1280, 800)),
  widgetSmall(Size(170, 170)),
  widgetMedium(Size(364, 170));

  const FrameKind(this.size);

  final Size size;
}

/// The design sections frames are grouped under.
enum FrameSection {
  month('The month'),
  editSettings('Edit, settings, accessibility'),
  dark('Dark'),
  wide('Wide, macOS and desktop web'),
  widgets('iOS widgets');

  const FrameSection(this.title);

  final String title;
}

PaymentKey _paid(String id, int day) => PaymentKey(id, DateTime.utc(2026, 10, day));

final _school = _paid('school', 15);

/// The state a frame opens in.
final class FramePreset {
  const FramePreset({this.extraPaid = const {}, this.ui = const MonthUi(), this.location = '/', this.sheet});

  static const standard = FramePreset();

  static final scrubbed = FramePreset(ui: const MonthUi(scrub: 15));

  static final justPaid = FramePreset(
    extraPaid: {_school},
    ui: MonthUi(
      flash: _school,
      snack: Snack('School fees marked paid', undo: _school, delta: 42000),
    ),
  );

  static final allPaid = FramePreset(extraPaid: {_school, _paid('society', 10), _paid('lic', 22)});

  static const settings = FramePreset(location: '/settings');

  /// The edit sheet as in frame 1e: a credit card bill on the 31st.
  static const edit = FramePreset(
    sheet: EditForm(name: 'Credit card bill', amount: 12000, day: 31, start: YearMonth(2026, 12)),
  );

  final Set<PaymentKey> extraPaid;
  final MonthUi ui;
  final String location;
  final EditForm? sheet;
}

/// One design frame (1a to 1o), as listed in design/README.md.
final class FrameSpec {
  const FrameSpec({
    required this.id,
    required this.title,
    required this.section,
    required this.kind,
    required this.preset,
    this.caption,
    this.brightness = Brightness.light,
    this.textScale = 1,
  });

  /// "1a" to "1o".
  final String id;
  final String title;
  final String? caption;
  final FrameSection section;
  final FrameKind kind;
  final FramePreset preset;
  final Brightness brightness;
  final double textScale;

  bool get dark => brightness == Brightness.dark;

  /// "1a_month_light": the golden and screenshot file name.
  String get fileName =>
      '${id}_${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '')}'
      '_${dark ? 'dark' : 'light'}';
}

final frames = <FrameSpec>[
  FrameSpec(
    id: '1a',
    title: 'Month',
    caption: 'Needs you leads. Autopay is counted, never chased.',
    section: FrameSection.month,
    kind: FrameKind.phone,
    preset: FramePreset.standard,
  ),
  FrameSpec(
    id: '1b',
    title: 'Day scrubbed',
    caption: 'Drag the ring. The list follows the handle.',
    section: FrameSection.month,
    kind: FrameKind.phone,
    preset: FramePreset.scrubbed,
  ),
  FrameSpec(
    id: '1c',
    title: 'Marked paid',
    caption: 'Total counts down, tick fills, undo waits.',
    section: FrameSection.month,
    kind: FrameKind.phone,
    preset: FramePreset.justPaid,
  ),
  FrameSpec(
    id: '1d',
    title: 'Nothing left',
    caption: 'A finished state, not a prompt.',
    section: FrameSection.month,
    kind: FrameKind.phone,
    preset: FramePreset.allPaid,
  ),
  const FrameSpec(
    id: '1e',
    title: 'Edit sheet',
    caption: 'Next 3 dates show the Feb clamp before you save.',
    section: FrameSection.editSettings,
    kind: FrameKind.phone,
    preset: FramePreset.edit,
  ),
  const FrameSpec(
    id: '1f',
    title: 'Settings',
    caption: 'Reminders, appearance, your data.',
    section: FrameSection.editSettings,
    kind: FrameKind.phone,
    preset: FramePreset.settings,
  ),
  const FrameSpec(
    id: '1g',
    title: '200% text',
    caption: 'Rows stack, the dial steps down.',
    section: FrameSection.editSettings,
    kind: FrameKind.phone,
    preset: FramePreset.standard,
    textScale: 2,
  ),
  const FrameSpec(
    id: '1h',
    title: 'Month',
    section: FrameSection.dark,
    kind: FrameKind.phone,
    preset: FramePreset.standard,
    brightness: Brightness.dark,
  ),
  FrameSpec(
    id: '1i',
    title: 'Marked paid',
    section: FrameSection.dark,
    kind: FrameKind.phone,
    preset: FramePreset.justPaid,
    brightness: Brightness.dark,
  ),
  const FrameSpec(
    id: '1j',
    title: 'Edit sheet',
    section: FrameSection.dark,
    kind: FrameKind.phone,
    preset: FramePreset.edit,
    brightness: Brightness.dark,
  ),
  const FrameSpec(
    id: '1k',
    title: 'Settings',
    section: FrameSection.dark,
    kind: FrameKind.phone,
    preset: FramePreset.settings,
    brightness: Brightness.dark,
  ),
  const FrameSpec(
    id: '1l',
    title: 'Wide',
    caption: 'Dial left, list right, from 720px up.',
    section: FrameSection.wide,
    kind: FrameKind.wide,
    preset: FramePreset.standard,
  ),
  const FrameSpec(
    id: '1m',
    title: 'Wide',
    section: FrameSection.wide,
    kind: FrameKind.wide,
    preset: FramePreset.standard,
    brightness: Brightness.dark,
  ),
  const FrameSpec(
    id: '1n',
    title: 'Small widget',
    caption: 'Small and medium widgets on the home screen.',
    section: FrameSection.widgets,
    kind: FrameKind.widgetSmall,
    preset: FramePreset.standard,
  ),
  const FrameSpec(
    id: '1n',
    title: 'Medium widget',
    section: FrameSection.widgets,
    kind: FrameKind.widgetMedium,
    preset: FramePreset.standard,
  ),
  const FrameSpec(
    id: '1o',
    title: 'Small widget',
    section: FrameSection.widgets,
    kind: FrameKind.widgetSmall,
    preset: FramePreset.standard,
    brightness: Brightness.dark,
  ),
  const FrameSpec(
    id: '1o',
    title: 'Medium widget',
    section: FrameSection.widgets,
    kind: FrameKind.widgetMedium,
    preset: FramePreset.standard,
    brightness: Brightness.dark,
  ),
];
