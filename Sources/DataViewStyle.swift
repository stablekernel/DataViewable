import UIKit

public enum DataViewPosition {
    case center
    case top
}

public protocol DataViewStyle {
    var contentViewBackgroundColor: UIColor { get }
    var position: DataViewPosition { get }
    var shouldAutomaticallyAnimateLoadingView: Bool { get }
}

extension UIColor {
    public static var emptyGray: UIColor {
        return UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
}

extension DataViewStyle {
    public var contentViewBackgroundColor: UIColor {
        return .emptyGray
    }

    public var position: DataViewPosition {
        return .center
    }

    public var shouldAutomaticallyAnimateLoadingView: Bool {
        return true
    }
}

public struct DataViewDefaultStyle: DataViewStyle {

}
