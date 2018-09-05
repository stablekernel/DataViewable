import UIKit

public protocol DataViewSource {
	/// Overrides `hasData` for a given `DataViewable`.
	/// Called on `reloadEmptyDataSet()`
	///
	/// - Parameter dataView: some `DataViewable`
	/// - Returns: whether or not the dataView has data
	func dataViewHasData(_ dataView: DataViewable) -> Bool?

	/// Overrides `isLoading` for a given `DataViewable`.
	/// Called on `reloadEmptyDataSet()`
	///
	/// - Parameter dataView: some `DataViewable`
	/// - Returns: whether or not the dataView is loading
	func dataViewIsLoading(_ dataView: DataViewable) -> Bool?

	/// Overrides `containerView` for a given `DataViewable`.
	///
	/// - Parameter dataView: some `DataViewable`
	/// - Returns: a custom view where the `contentView` will be added
	func containerViewForDataView(_ dataView: DataViewable) -> UIView?

	/// The view to display when no data is present. Defaults to `nil`.
	///
	/// - Parameter dataView: some `DataViewable`
	/// - Returns: a view for the empty state
	func emptyViewForDataView(_ dataView: DataViewable) -> UIView?

	/// The loading indicator to display when no data is present.
	/// If this view conforms to `Refreshable`, `startAnimating()` and `stopAnimating()`
	/// will be called automatically. Defaults to an intance of `UIActivityIndicatorView`.
	///
	/// - Parameter dataView: some `DataViewable`
	/// - Returns: a loading view for the loading and updating states
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
