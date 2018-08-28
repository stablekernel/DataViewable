import UIKit

public extension DataViewable where Self: UILabel {
	public var hasData: Bool {
		return text != nil
	}
}

