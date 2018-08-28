import UIKit

public protocol DataViewSource {
	func dataViewHasData(_ dataView: DataViewable) -> Bool?
	func dataViewIsLoading(_ dataView: DataViewable) -> Bool?
	func containerViewForDataView(_ dataView: DataViewable) -> UIView?
	func emptyViewForDataView(_ dataView: DataViewable) -> UIView?
	func loadingViewForDataView(_ dataView: DataViewable) -> UIView?
}

public extension DataViewSource {
	func dataViewHasData(_ dataView: DataViewable) -> Bool? {
		return nil
	}

	func dataViewIsLoading(_ dataView: DataViewable) -> Bool? {
		return nil
	}

	func emptyViewForDataView(_ dataView: DataViewable) -> UIView? {
		return nil
	}

	func loadingViewForDataView(_ dataView: DataViewable) -> UIView? {
		return UIActivityIndicatorView(activityIndicatorStyle: .gray)
	}

	func containerViewForDataView(_ dataView: DataViewable) -> UIView? {
		return nil
	}
}
