enum TrackingProtectionStatus: Equatable {
    case on(TPPageStats)
    case off
    
    static func == (lhs: TrackingProtectionStatus, rhs: TrackingProtectionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.on, .on), (.off, .off):
            return true
        default:
            return false
        }
    }
}
