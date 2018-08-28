import UIKit

public extension DataViewable where Self: UICollectionView {
	public var hasData: Bool {

		// Get the item count
		let itemCount = (0..<numberOfSections).reduce(0) {
			$0 + numberOfItems(inSection: $1)
		}

		return itemCount > 0
	}
}

