import UIKit

public extension UIApplication {
    var orientation : UIInterfaceOrientation? {
        UIApplication
            .shared
            .windows
            .first(where: { $0.isKeyWindow })?
            .windowScene?
            .interfaceOrientation
    }
}
