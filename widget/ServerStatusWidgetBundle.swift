import WidgetKit
import SwiftUI

@main
struct ServerStatusWidgetBundle: WidgetBundle {
    var body: some Widget {
        ServerStatusWidget()
        ServerStatusWidgetControl()
        ServerStatusWidgetLiveActivity()
    }
}
