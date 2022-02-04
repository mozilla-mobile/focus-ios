public enum TrackingProtectionStatus: Equatable {
    case on(TPPageStats)
    case off
    case connectionNotSecure
}

public struct TPPageStats: Equatable {
    let adCount: Int
    let analyticCount: Int
    let contentCount: Int
    let socialCount: Int
    
    var total: Int { return adCount + socialCount + analyticCount + contentCount }
    
    public init() {
        adCount = 0
        analyticCount = 0
        contentCount = 0
        socialCount = 0
    }
    
    private init(adCount: Int, analyticCount: Int, contentCount: Int, socialCount: Int) {
        self.adCount = adCount
        self.analyticCount = analyticCount
        self.contentCount = contentCount
        self.socialCount = socialCount
    }
    
    func create(byAddingListItem listItem: BlocklistName) -> TPPageStats {
        switch listItem {
        case .advertising: return TPPageStats(adCount: adCount + 1, analyticCount: analyticCount, contentCount: contentCount, socialCount: socialCount)
        case .analytics: return TPPageStats(adCount: adCount, analyticCount: analyticCount + 1, contentCount: contentCount, socialCount: socialCount)
        case .content: return TPPageStats(adCount: adCount, analyticCount: analyticCount, contentCount: contentCount + 1, socialCount: socialCount)
        case .social: return TPPageStats(adCount: adCount, analyticCount: analyticCount, contentCount: contentCount, socialCount: socialCount + 1)
        }
    }
}

extension TPPageStats {
    static let empty = TPPageStats()
}
