import UIKit

private var kDataViewSource = "emptyDataSetSource"
private var kDataViewDelegate = "emptyDataSetDelegate"
private var kEmptyView = "emptyView"
private var kLoadingView = "loadingView"
private var kIsLoading = "isLoading"

public protocol DataViewable: DataViewDelegate {
    var emptyDataSetDelegate: DataViewDelegate? { get }
    var emptyDataSetSource: DataViewSource? { get }

    // State
    var hasData: Bool { get }
    var isLoading: Bool { get set }
    func reloadEmptyDataSet()

    // View
    var containerView: UIView { get }
    var emptyView: UIView? { get set }
    var loadingView: UIView? { get set }

	func addEmptyView(_ emptyView: UIView, to containerView: UIView)
	func addLoadingView(_ emptyView: UIView, to containerView: UIView)
}

public extension DataViewable {

    // MARK: - Delegates

    public var emptyDataSetSource: DataViewSource? {
        get {
            return objc_getAssociatedObject(self, &kDataViewSource) as? DataViewSource
        }
        set {
            objc_setAssociatedObject(self, &kDataViewSource, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public var emptyDataSetDelegate: DataViewDelegate? {
        get {
            return objc_getAssociatedObject(self, &kDataViewDelegate) as? DataViewDelegate
        }
        set {
            objc_setAssociatedObject(self, &kDataViewDelegate, newValue, .OBJC_ASSOCIATION_ASSIGN)
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
        hideEmptyView()
        hideLoadingView()

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

        addEmptyView(emptyView, to: containerView)

        dataView(self, didShowEmptyView: emptyView)
        emptyDataSetDelegate?.dataView(self, didShowEmptyView: emptyView)

        self.emptyView = emptyView
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

        addLoadingView(loadingView, to: containerView)

        if let refreshable = loadingView as? Refreshable {
            refreshable.startRefreshing()
        }

        dataView(self, didShowLoadingView: loadingView)
        emptyDataSetDelegate?.dataView(self, didShowLoadingView: loadingView)

        self.loadingView = loadingView
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

    func addEmptyView(_ emptyView: UIView, to containerView: UIView) {
        emptyView.translatesAutoresizingMaskIntoConstraints = false

        if emptyView.superview == nil {
            containerView.addSubview(emptyView)
        } else {
            emptyView.removeConstraints(emptyView.constraints)
        }

        let viewSideConstraints = [
            containerView.topAnchor.constraint(equalTo: emptyView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: emptyView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: emptyView.rightAnchor)
        ]

        viewSideConstraints.forEach { $0.priority = .required }

        containerView.addConstraints(viewSideConstraints)
        containerView.layoutIfNeeded()
    }

    func addLoadingView(_ loadingView: UIView, to containerView: UIView) {
        loadingView.translatesAutoresizingMaskIntoConstraints = false

        if loadingView.superview == nil {
            containerView.addSubview(loadingView)
        }

        let centerConstraints = [
            containerView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ]

        let viewSideConstraints = [
            containerView.topAnchor.constraint(greaterThanOrEqualTo: loadingView.topAnchor),
            containerView.bottomAnchor.constraint(greaterThanOrEqualTo: loadingView.bottomAnchor),
            containerView.leftAnchor.constraint(greaterThanOrEqualTo: loadingView.leftAnchor),
            containerView.rightAnchor.constraint(greaterThanOrEqualTo: loadingView.rightAnchor)
        ]

        viewSideConstraints.forEach { $0.priority = .fittingSizeLevel - 1 }

        containerView.addConstraints(centerConstraints)
        containerView.addConstraints(viewSideConstraints)
        containerView.layoutIfNeeded()
    }
}
