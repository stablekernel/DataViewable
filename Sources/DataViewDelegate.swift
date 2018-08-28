import UIKit

public protocol DataViewDelegate: class {
	func dataView(_ dataView: DataViewable, willShowEmptyView emptyView: UIView)
	func dataView(_ dataView: DataViewable, didShowEmptyView emptyView: UIView)
	func dataView(_ dataView: DataViewable, willHideEmptyView emptyView: UIView)
	func dataView(_ dataView: DataViewable, didHideEmptyView emptyView: UIView)
	func dataView(_ dataView: DataViewable, willShowLoadingView loadingView: UIView)
	func dataView(_ dataView: DataViewable, didShowLoadingView loadingView: UIView)
	func dataView(_ dataView: DataViewable, willHideLoadingView loadingView: UIView)
	func dataView(_ dataView: DataViewable, didHideLoadingView loadingView: UIView)
	func emptyStyleForDataView(_ dataView: DataViewable) -> DataViewStyle?
	func loadingStyleForDataView(_ dataView: DataViewable) -> DataViewStyle?
	func shouldShowEmptyView(for state: DataViewState) -> Bool?
	func shouldShowLoadingView(for state: DataViewState) -> Bool?
}

public extension DataViewDelegate {
	func dataView(_ dataView: DataViewable, willShowEmptyView emptyView: UIView) {}
	func dataView(_ dataView: DataViewable, didShowEmptyView emptyView: UIView) {}
	func dataView(_ dataView: DataViewable, willHideEmptyView emptyView: UIView) {}
	func dataView(_ dataView: DataViewable, didHideEmptyView emptyView: UIView) {}
	func dataView(_ dataView: DataViewable, willShowLoadingView loadingView: UIView) {}
	func dataView(_ dataView: DataViewable, didShowLoadingView loadingView: UIView) {}
	func dataView(_ dataView: DataViewable, willHideLoadingView loadingView: UIView) {}
	func dataView(_ dataView: DataViewable, didHideLoadingView loadingView: UIView) {}
	func emptyStyleForDataView(_ dataView: DataViewable) -> DataViewStyle? { return nil }
	func loadingStyleForDataView(_ dataView: DataViewable) -> DataViewStyle? { return nil }
	func shouldShowEmptyView(for state: DataViewState) -> Bool? { return nil }
	func shouldShowLoadingView(for state: DataViewState) -> Bool? { return nil }
}

