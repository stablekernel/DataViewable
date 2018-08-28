import UIKit

public extension DataViewable where Self: UIImageView {
	public var hasData: Bool {
		return image != nil
	}
}

