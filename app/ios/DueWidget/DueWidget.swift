// Frames 1n and 1o: the home screen widgets. The app computes everything in
// Dart (lib/features/home_widget/widget_snapshot.dart) and writes it to the
// App Group; this file only lays it out. Keep it in step with
// catalog/lib/frames/home_widget_preview.dart.

import SwiftUI
import WidgetKit

private let appGroup = "group.dev.avi.due"
private let timelineKey = "timeline"

struct WidgetItem: Decodable, Hashable {
  let name: String
  let amount: String
  let when: String
  let late: Bool
}

struct Snapshot: Decodable {
  let needsYou: String
  let nextLabel: String
  let nextName: String
  let nextLine: String
  let nextLate: Bool
  let monthLine: String
  let items: [WidgetItem]
  let bar: [String]

  /// Shown before the app has run once, and in the widget gallery.
  static let placeholder = Snapshot(
    needsYou: "73,680",
    nextLabel: "OVERDUE",
    nextName: "Society maintenance",
    nextLine: "Sat 10 · ₹7,500",
    nextLate: true,
    monthLine: "October · 19 days left",
    items: [
      WidgetItem(name: "Society maintenance", amount: "₹7,500", when: "2 DAYS LATE", late: true),
      WidgetItem(name: "School fees", amount: "₹42,000", when: "THU 15", late: false),
      WidgetItem(name: "LIC premium", amount: "₹24,180", when: "THU 22", late: false),
    ],
    bar: (1...31).map { [10, 15, 22].contains($0) ? "needsYou" : ($0 < 12 ? "past" : "future") }
  )

}

/// One day of the timeline the app writes: what to show from that date on.
struct WidgetDay: Decodable {
  let date: String
  let snapshot: Snapshot

  private static let format: DateFormatter = {
    let f = DateFormatter()
    f.calendar = Calendar(identifier: .gregorian)
    f.locale = Locale(identifier: "en_US_POSIX")
    f.dateFormat = "yyyy-MM-dd"
    return f
  }()

  /// Local midnight at the start of [date].
  var start: Date? { Self.format.date(from: date) }

  /// The days from today on. When the app has not run for longer than the
  /// timeline covers, the last day is all there is.
  static func load(from now: Date = .now) -> [Entry] {
    guard
      let json = UserDefaults(suiteName: appGroup)?.string(forKey: timelineKey),
      let data = json.data(using: .utf8),
      let days = try? JSONDecoder().decode([WidgetDay].self, from: data),
      let last = days.last
    else { return [Entry(date: now, snapshot: .placeholder)] }
    let today = Calendar.current.startOfDay(for: now)
    let ahead = days.compactMap { day -> Entry? in
      guard let start = day.start, start >= today else { return nil }
      return Entry(date: max(start, now), snapshot: day.snapshot)
    }
    return ahead.isEmpty ? [Entry(date: now, snapshot: last.snapshot)] : ahead
  }
}

struct Entry: TimelineEntry {
  let date: Date
  let snapshot: Snapshot
}

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> Entry { Entry(date: .now, snapshot: .placeholder) }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
    completion(context.isPreview ? placeholder(in: context) : WidgetDay.load()[0])
  }

  /// One entry per day the app wrote ahead, so the widget moves on at
  /// midnight without the app. The app reloads it on every change.
  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    let entries = WidgetDay.load()
    let tomorrow = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
    completion(Timeline(entries: entries, policy: entries.count > 1 ? .atEnd : .after(tomorrow)))
  }
}

/// PostScript names of the fonts bundled from packages/due_kit/assets/fonts.
private extension Font {
  static func display(_ size: CGFloat, _ weight: Int = 700) -> Font {
    let name = [500: "Medium", 600: "SemiBold"][weight] ?? "Bold"
    return .custom("BricolageGrotesque-48pt\(name)", size: size)
  }

  static func body(_ size: CGFloat, _ weight: Int = 400) -> Font {
    .custom(weight >= 600 ? "HankenGrotesk-SemiBold" : "HankenGrotesk-Regular", size: size)
  }

  static func mono(_ size: CGFloat, _ weight: Int = 400) -> Font {
    .custom(weight >= 600 ? "JetBrainsMono-SemiBold" : "JetBrainsMonoRoman-Regular", size: size)
  }
}

private struct NeedsYou: View {
  let amount: String

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("NEEDS YOU").font(.mono(10, 600)).tracking(1.2).foregroundStyle(DueColor.accent)
      (Text("₹").font(.display(19, 500)).foregroundColor(DueColor.muted)
        + Text(amount).font(.display(32)).foregroundColor(DueColor.ink))
        .monospacedDigit()
        .tracking(-1.28)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
  }
}

struct SmallView: View {
  let s: Snapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        NeedsYou(amount: s.needsYou)
        Spacer()
        RoundedRectangle(cornerRadius: 2).fill(DueColor.accent).frame(width: 6, height: 6)
      }
      Spacer()
      Text(s.nextLabel).font(.mono(10)).tracking(0.8)
        .foregroundStyle(s.nextLate ? DueColor.critical : DueColor.muted)
      Text(s.nextName).font(.body(14, 600)).foregroundStyle(DueColor.ink).lineLimit(1).padding(.top, 2)
      Text(s.nextLine).font(.body(12)).foregroundStyle(DueColor.muted).monospacedDigit()
    }
  }
}

struct MediumView: View {
  let s: Snapshot

  private func cell(_ state: String) -> Color {
    switch state {
    case "needsYou": DueColor.accent
    case "settled": DueColor.ink
    case "past": DueColor.ruleStrong
    default: DueColor.rule
    }
  }

  var body: some View {
    HStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 0) {
        NeedsYou(amount: s.needsYou)
        Spacer()
        Text(s.monthLine).font(.body(12)).foregroundStyle(DueColor.muted)
        HStack(spacing: 2) {
          ForEach(Array(s.bar.enumerated()), id: \.offset) { _, state in
            RoundedRectangle(cornerRadius: 1).fill(cell(state)).frame(height: 14)
          }
        }
        .padding(.top, 6)
      }
      .frame(width: 132)

      VStack(alignment: .leading, spacing: 8) {
        if s.items.isEmpty {
          Text("Nothing left this month").font(.body(13)).foregroundStyle(DueColor.muted)
        }
        ForEach(s.items, id: \.self) { item in
          HStack(spacing: 8) {
            Circle().fill(DueColor.accent).frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 0) {
              Text(item.name).font(.body(13, 600)).foregroundStyle(DueColor.ink).lineLimit(1)
              Text(item.when).font(.mono(10)).foregroundStyle(item.late ? DueColor.critical : DueColor.muted)
            }
            Spacer(minLength: 4)
            Text(item.amount).font(.display(13, 600)).foregroundStyle(DueColor.ink).monospacedDigit()
          }
        }
      }
      .padding(.leading, 14)
      .overlay(alignment: .leading) { Rectangle().fill(DueColor.rule).frame(width: 1) }
      .frame(maxHeight: .infinity)
    }
  }
}

struct DueWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: Entry

  var body: some View {
    Group {
      if family == .systemMedium { MediumView(s: entry.snapshot) } else { SmallView(s: entry.snapshot) }
    }
    .containerBackground(DueColor.surface, for: .widget)
    .widgetURL(URL(string: "due:///"))
  }
}

@main
struct DueWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "DueWidget", provider: Provider()) { entry in
      DueWidgetView(entry: entry)
    }
    .configurationDisplayName("Needs you")
    .description("What still needs you this month, and what is next.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
