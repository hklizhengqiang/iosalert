import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate,URLSessionWebSocketDelegate {
    
    let tokenLabel = UITextView()
    let statusLabel = UITextView()
    let liveActivityTokenLabel = UITextView()
    
    var webSocket: URLSessionWebSocketTask?
    var runningStatus: [String: String] = [:]
    var seen: [String: Date] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WebSocket状态"
        view.backgroundColor = .white
        
        
        setupTokenLabel()
        setupLiveActivityTokenLabel()
        setupStatusLabel()
        connectWebSocket()
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateStatusLabel), userInfo: nil, repeats: true)
        
        UNUserNotificationCenter.current().delegate = self
              requestNotificationPermission()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedDeviceToken(_:)),
            name: NSNotification.Name("DeviceTokenReceived"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(liveActivityTokenReceived(_:)),
            name: .liveActivityTokenReceived,
            object: nil
        )
        
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("权限授予: \(granted)")
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func connectWebSocket() {
        let url = URL(string: "wss://google.com/自己替换成自己的WebSocket服务器")!
        webSocket = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue()).webSocketTask(with: url)
        webSocket?.resume()
        
        receiveWebSocketMessage()
    }
    
    func receiveWebSocketMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case let .string(text) = message, let data = text.data(using: .utf8) {
                    self?.handleMessage(data: data)
                }
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
            self?.receiveWebSocketMessage()
        }
    }
    
    func handleMessage(data: Data) {
        guard let message = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let k = message["k"] as? String else { return }
        
        var body = message

        let key = "\(k)"
        seen[key] = Date()
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: body,options: .sortedKeys),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            runningStatus[key] = jsonString
        }
    }
    
    func sendWebSocketToken(key: String, token: String) {
        let message: [String: String] = [
            "k": key,
            "v": token
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: message, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            webSocket?.send(.string(jsonString)) { error in
                if let error = error {
                    print("WebSocket send error: \(error)")
                }
            }
        }
    }
    
    
    
    func setupTokenLabel() {
        tokenLabel.frame = CGRect(x: 10, y: 50, width: view.bounds.width - 20, height: 80)
        tokenLabel.text = "正在获取Device Token..."
        tokenLabel.font = UIFont.systemFont(ofSize: 14)
        tokenLabel.isEditable = false
        view.addSubview(tokenLabel)
    }
    
    func setupLiveActivityTokenLabel() {
        liveActivityTokenLabel.frame = CGRect(x: 10, y: 140, width: view.bounds.width - 20, height: 80)
        liveActivityTokenLabel.text = "正在获取Live Activity Token..."
        liveActivityTokenLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        liveActivityTokenLabel.isEditable = false
        liveActivityTokenLabel.layer.cornerRadius = 8
        liveActivityTokenLabel.backgroundColor = UIColor.systemGray6
        view.addSubview(liveActivityTokenLabel)
        

    }
    
    func setupStatusLabel() {
        
        
        statusLabel.frame = CGRect(x: 10, y: 230, width: view.bounds.width - 20, height: view.bounds.height - 230)
        statusLabel.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        statusLabel.isEditable = false
        statusLabel.layer.cornerRadius = 8
        statusLabel.backgroundColor = UIColor.systemGray6
        view.addSubview(statusLabel)
    }
    
    
    
    
    @objc func receivedDeviceToken(_ notification: Notification) {
        if let token = notification.userInfo?["DeviceToken"] as? String {
            tokenLabel.text = "Device Token:\n\(token)"
            sendWebSocketToken(key: "devicetoken", token: token)
        }
    }
    
    @objc func liveActivityTokenReceived(_ notification: Notification) {
        if let token = notification.userInfo?["token"] as? String {
            DispatchQueue.main.async {
                self.liveActivityTokenLabel.text = "Live Activity Token:\n\(token)"
                self.sendWebSocketToken(key: "livetoken", token: token)
            }
        }
    }
    
    
    @objc func updateStatusLabel() {
        var displayText = "---running---\n"
        let now = Date()
        for key in runningStatus.keys.sorted() {
            if let lastSeen = seen[key], now.timeIntervalSince(lastSeen) > 900 {
                displayText += "\(key): 已超时 (最后更新:\(lastSeen))\n"
                continue
            }
            displayText += "\(key):\(runningStatus[key] ?? "")\n"
        }
        statusLabel.text = displayText
    }
    
    
}
