import WidgetKit
import SwiftUI
import ActivityKit

struct ServerStatusWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ServerStatusAttributes.self) { context in
            // 锁屏界面
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading) {
                     
                        Text(context.state.ticker)
                            .font(.caption).bold()
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                
                        Text(context.state.serviceStatusSummary)
                            .font(.caption).bold()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("最新: " + context.state.latestAlert)
                            .font(.caption).bold()
                        // 显示实时推送的多行消息
                        ForEach(context.state.realtimeMessages, id: \.self) { message in
                            HStack(alignment: .top, spacing: 4) {
                                
                                Text(message)
                                    .font(.caption).bold()
                            }
                        }
                        Text("更新: " + context.state.lastUpdated)
                            .font(.caption).bold()
                    }
                }
            } compactLeading: {
                Text(context.state.compactIslandMessageLeft)
                    .font(.caption2).foregroundColor(.secondary)
            } compactTrailing: {
                Text(context.state.compactIslandMessage)
                    .font(.caption2).foregroundColor(.secondary)
            } minimal: {
                Image(systemName: "chart.line.uptrend.xyaxis").foregroundColor(.green)
            }
        }
    }
    
    // 锁屏界面UI
    private func lockScreenView(context: ActivityViewContext<ServerStatusAttributes>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(context.state.latestAlert)
                .font(.subheadline).bold()
            
            Divider()
            
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis").foregroundColor(.green)
                Text(context.state.ticker)
                    .font(.subheadline).bold()
            }
            
            HStack {
        
                Text(context.state.serviceStatusSummary)
                    .font(.subheadline).bold()
            }
            
            // 显示实时推送的多行消息
            ForEach(context.state.realtimeMessages, id: \.self) { message in
                HStack{
                    Text(message)
                        .font(.subheadline).bold()
                }
            }
            
            Divider()
            
            Text("更新：" + context.state.lastUpdated)
                .font(.subheadline).bold()
        }
        .padding()
    }
}
