enum BlocklistName: String {
    case advertising = "disconnect-advertising"
    case analytics = "disconnect-analytics"
    case content = "disconnect-content"
    case social = "disconnect-social"
    
    var filename: String { return self.rawValue }
    
    static var all: [BlocklistName] { return [.advertising, .analytics, .content, .social] }
    static var basic: [BlocklistName] { return [.advertising, .analytics, .social] }
    static var strict: [BlocklistName] { return [.content] }
    
    static func forStrictMode(isOn: Bool) -> [BlocklistName] {
        return BlocklistName.basic + (isOn ? BlocklistName.strict : [])
    }
}
