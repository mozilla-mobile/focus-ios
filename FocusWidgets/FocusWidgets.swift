// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct FocusWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        SearchWidgetView()
    }
}

@main
struct FocusWidgets: Widget {
    let kind: String = "FocusWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FocusWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Quick Actions")
        .description("Add a Focus shortcut to your Home screen. After adding the widget, touch and hold to edit it and select a different shortcut.")
        .supportedFamilies([.systemSmall])
    }
}

struct FocusWidgets_Previews: PreviewProvider {
    static var previews: some View {
        FocusWidgetsEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
