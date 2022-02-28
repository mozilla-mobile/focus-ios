import UIKit

struct SectionItem: Hashable {
    
    let id = UUID()
    
    let configureCell: (UITableView, IndexPath) -> UITableViewCell
    let action: (() -> Void)?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(configureCell: @escaping (UITableView, IndexPath) -> UITableViewCell, action: (() -> Void)? = nil) {
        self.configureCell = configureCell
        self.action = action
    }
}
