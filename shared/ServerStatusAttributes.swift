import ActivityKit

struct ServerStatusAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        
        // 币种价格信息（服务端负责滚动内容）
        var ticker: String // e.g. "BTC $68000 ↑3.2%"
        
        var latestAlert: String
        
        // 所有服务状态汇总滚动文本
        var serviceStatusSummary: String
        
        // 灵动岛压缩显示时单独使用字段
        var compactIslandMessageLeft: String
        var compactIslandMessage: String
        
        var realtimeMessages: [String]           // 服务端推送的多行实时信息
        
        
        // 更新时间
        var lastUpdated: String
        
    }
    
    
}
