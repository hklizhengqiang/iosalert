import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 请求用户通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            print("Critical Alerts权限授予: \(granted)")
        }
        
        // 示例：启动Activity
        LiveActivityManager.shared.startActivity()
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token:", token)
        
        // 发出通知到ViewController
        NotificationCenter.default.post(name: Notification.Name("DeviceTokenReceived"),
                                        object: nil,
                                        userInfo: ["DeviceToken": token])
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("获取Device Token失败:", error.localizedDescription)
    }
}
