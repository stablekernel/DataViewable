import UIKit

private var kDataViewSource = "emptyDataSetSource"
private var kDataViewDelegate = "emptyDataSetDelegate"
private var kEmptyView = "emptyView"
private var kLoadingView = "loadingView"
private var kIsLoading = "isLoading"

public protocol DataViewable: DataViewDelegate {

	/// Life cycle hooks for `DataViewable`
	var emptyDataSetDelegate: DataViewDelegate? { get }

	/// Data source for `DataViewable`
	var emptyDataSetSource: DataViewSource? { get }

	/// The current data state of the data view
	var hasData: Bool { get }

	/// The current loading state of the data view
	var isLoading: Bool { get set }

	/// The view where the content view is added
	var containerView: UIView { get }

	/// Holds a reference to the empty view so it may be easily removed
	var emptyView: UIView? { get set }

	/// Holds a reference to the loading view so it may be easily removed
	var loadingView: UIView? { get set }

	/// Hides or shows `emptyView` or `loadingView` based on `hasData` and `isLoading`
	///
	/// - Returns: Void
	func reloadEmptyDataSet()

	/// Specifies a content containing the empty view
	///
	/// - Parameter emptyView: the empty view from `emptyDataSetSource`
	/// - Returns: a content view for a given empty view
	func contentViewWithEmptyView(_ emptyView: UIView) -> UIView

	/// Specifies a content containing the loading view
	///
	/// - Parameter loadingView: the loading view from `emptyDataSetSource` or the default
	/// - Returns: a content view for a given loading view
	func contentViewWithLoadingView(_ loadingView: UIView) -> UIView

	/// Specifies how the `contentView` is added as a child of the `containerView`
	///
	/// - Parameters:
	///   - contentView: the view containing either the `emptyView` or the `loadingView`
	///   - containerView: the view where the `contentView` is setup
	func addContentView(_ contentView: UIView, to containerView: UIView)
}

public extension DataViewable {

	// MARK: - Delegates

	public var emptyDataSetSource: DataViewSource? {
		get {
			return objc_getAssociatedObject(self, &kDataViewSource) as? DataViewSource
		}
		set {
			objc_setAssociatedObject(self, &kDataViewSource, newValue, .OBJC_ASSOCIATION_ASSIGN)
			reloadEmptyDataSet()
		}
	}

	public var emptyDataSetDelegate: DataViewDelegate? {
		get {
			return objc_getAssociatedObject(self, &kDataViewDelegate) as? DataViewDelegate
		}
		set {
			objc_setAssociatedObject(self, &kDataViewDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
			reloadEmptyDataSet()
		}
	}

	// MARK: - Views

	public var emptyView: UIView? {
		get {
			return objc_getAssociatedObject(self, &kEmptyView) as? UIView
		}
		set {
			objc_setAssociatedObject(self, &kEmptyView, newValue, .OBJC_ASSOCIATION_ASSIGN)
		}
	}

	public var loadingView: UIView? {
		get {
			return objc_getAssociatedObject(self, &kLoadingView) as? UIView
		}
		set {
			objc_setAssociatedObject(self, &kLoadingView, newValue, .OBJC_ASSOCIATION_ASSIGN)
		}
	}

	// MARK: - State
	public var hasData: Bool {
		return true
	}

	public var isLoading: Bool {
		get {
			return objc_getAssociatedObject(self, &kIsLoading) as? Bool ?? false
		}
		set {
			if isLoading != newValue {
				objc_setAssociatedObject(self, &kIsLoading, newValue, .OBJC_ASSOCIATION_RETAIN)
				reloadEmptyDataSet()
			}
		}
	}

	public func reloadEmptyDataSet() {

		// Tear down and reconstruct the empty view every time
		hideEmptyView()
		hideLoadingView()

		// The source will always override default functionality
		let hasData = emptyDataSetSource?.dataViewHasData(self) ?? self.hasData
		let isLoading = emptyDataSetSource?.dataViewIsLoading(self) ?? self.isLoading
		let state = DataViewState(hasData: hasData, isLoading: isLoading)

		let shouldShowEmptyView = emptyDataSetDelegate?.shouldShowEmptyView(for: state)
			?? self.shouldShowEmptyView(for: state)
			?? false

		let shouldShowLoadingView = emptyDataSetDelegate?.shouldShowLoadingView(for: state)
			?? self.shouldShowLoadingView(for: state)
			?? false

		if shouldShowEmptyView {
			showEmptyView()
		}

		if shouldShowLoadingView {
			showLoadingView()
		}
	}

	public func shouldShowEmptyView(for state: DataViewState) -> Bool? {
		return state == .empty
	}

	public func shouldShowLoadingView(for state: DataViewState) -> Bool? {
		return state == .loading || state == .updating
	}

	private func showEmptyView() {
		guard let emptyView = emptyView ?? emptyDataSetSource?.emptyViewForDataView(self),
			!emptyView.isDescendant(of: containerView) else {
				return
		}

		emptyDataSetDelegate?.dataView(self, willShowEmptyView: emptyView)
		dataView(self, willShowEmptyView: emptyView)

		let contentView = contentViewWithEmptyView(emptyView)
		addContentView(contentView, to: containerView)

		dataView(self, didShowEmptyView: emptyView)
		emptyDataSetDelegate?.dataView(self, didShowEmptyView: emptyView)

		self.emptyView = contentView
	}

	private func hideEmptyView() {
		guard let emptyView = emptyView else {
			return
		}
		emptyDataSetDelegate?.dataView(self, willHideEmptyView: emptyView)
		dataView(self, willHideEmptyView: emptyView)

		emptyView.removeFromSuperview()

		dataView(self, didHideEmptyView: emptyView)
		emptyDataSetDelegate?.dataView(self, didHideEmptyView: emptyView)

		self.emptyView = nil
	}

	private func showLoadingView() {

		guard let loadingView = loadingView ?? emptyDataSetSource?.loadingViewForDataView(self),
			!loadingView.isDescendant(of: containerView) else {
				return
		}

		dataView(self, willShowLoadingView: loadingView)
		emptyDataSetDelegate?.dataView(self, willShowLoadingView: loadingView)

		let contentView = contentViewWithLoadingView(loadingView)
		addContentView(contentView, to: containerView)

		if let refreshable = loadingView as? Refreshable {
			refreshable.startRefreshing()
		}

		dataView(self, didShowLoadingView: loadingView)
		emptyDataSetDelegate?.dataView(self, didShowLoadingView: loadingView)

		self.loadingView = contentView
	}

	private func hideLoadingView() {
		guard let loadingView = loadingView else {
			return
		}

		emptyDataSetDelegate?.dataView(self, willHideLoadingView: loadingView)
		dataView(self, willHideLoadingView: loadingView)

		loadingView.removeFromSuperview()

		// If the loading view is refreshable end refreshing
		if let refreshable = loadingView as? Refreshable {
			refreshable.stopRefreshing()
		}

		dataView(self, didHideLoadingView: loadingView)
		emptyDataSetDelegate?.dataView(self, didHideLoadingView: loadingView)

		self.loadingView = nil
	}

	// MARK: - View setup hooks

	func contentViewWithEmptyView(_ emptyView: UIView) -> UIView {
		return emptyView
	}

	func contentViewWithLoadingView(_ loadingView: UIView) -> UIView {
		loadingView.translatesAutoresizingMaskIntoConstraints = false
		let stackView = UIStackView(arrangedSubviews: [loadingView])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}

	func addContentView(_ contentView: UIView, to containerView: UIView) {
		contentView.translatesAutoresizingMaskIntoConstraints = false

		if contentView.superview == nil {
			containerView.addSubview(contentView)
		} else {
			contentView.removeConstraints(contentView.constraints)
		}

		let viewSideConstraints = [
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
			containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		]

		containerView.addConstraints(viewSideConstraints)
		containerView.layoutIfNeeded()
	}
}
