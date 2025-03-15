import ActivityKit
import UIKit
import os.log

extension Notification.Name {
    static let liveActivityTokenReceived = Notification.Name("liveActivityTokenReceived")
}

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var activity: Activity<ServerStatusAttributes>?
    
    // 启动 Live Activity
    func startActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            os_log("Live Activities are not enabled on this device.", type: .error)
            return
        }
        
        let attributes = ServerStatusAttributes()
        let contentState = ServerStatusAttributes.ContentState(
            ticker: "BTC ¥428,200 ▲2.34%",
            latestAlert: "暂无警报",
            serviceStatusSummary: "数据库正常，API服务正常，延迟<30ms",
            compactIslandMessageLeft: "服务正常a",
            compactIslandMessage: "服务正常",
            realtimeMessages:["line1","line2","line3"],
            lastUpdated: "now()"
            
        )
        let activityContent = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            activity = try Activity.request(attributes: attributes,  content: activityContent,
                                            pushType: .token)
            print("启动Activity成功: \(String(describing: activity?.id))")
            
            guard let activity = activity else {
                print("启动Activity失败: 返回值为 nil")
                return
            }
            Task {
                for await tokenData in activity.pushTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    print("Push Token: \(token)")
                    
                    // 发送通知以便界面展示
                    NotificationCenter.default.post(
                        name: .liveActivityTokenReceived,
                        object: nil,
                        userInfo: ["token": token]
                    )
                }
            }
            
            print("启动成功，Activity ID: \(activity.id)")
        } catch {
            os_log("启动Activity失败: %{public}@", type: .error, error.localizedDescription)
        }
        
        
    }
    
    
    
}
