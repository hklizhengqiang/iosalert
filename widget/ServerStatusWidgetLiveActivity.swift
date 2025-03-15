import ActivityKit
import WidgetKit
import SwiftUI

struct ServerStatusWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ServerStatusWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ServerStatusWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ServerStatusWidgetAttributes {
    fileprivate static var preview: ServerStatusWidgetAttributes {
        ServerStatusWidgetAttributes(name: "World")
    }
}

extension ServerStatusWidgetAttributes.ContentState {
    fileprivate static var smiley: ServerStatusWidgetAttributes.ContentState {
        ServerStatusWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ServerStatusWidgetAttributes.ContentState {
         ServerStatusWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ServerStatusWidgetAttributes.preview) {
   ServerStatusWidgetLiveActivity()
} contentStates: {
    ServerStatusWidgetAttributes.ContentState.smiley
    ServerStatusWidgetAttributes.ContentState.starEyes
}
