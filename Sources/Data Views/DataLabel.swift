import UIKit

open class DataLabel: UILabel, DataViewable {

	open override var text: String? {
		didSet {
			reloadEmptyDataSet()
		}
	}
}

