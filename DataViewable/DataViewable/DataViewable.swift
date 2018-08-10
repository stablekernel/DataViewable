import UIKit

private var kDataViewSource = "emptyDataSetSource"
private var kDataViewDelegate = "emptyDataSetDelegate"
private var kContentView = "contentView"
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
    var contentView: UIView? { get set }
    var emptyView: UIView? { get set }
    var loadingView: UIView? { get set }
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

    public var contentView: UIView? {
        get {
            return objc_getAssociatedObject(self, &kContentView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &kContentView, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

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
        if let hasData = emptyDataSetSource?.hasDataForDataView(self) {
            return hasData
        }

        return false
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

        let style = emptyDataSetDelegate?.emptyStyleForDataView(self)
            ?? emptyStyleForDataView(self)
            ?? DataViewDefaultStyle()

        emptyDataSetDelegate?.dataView(self, willShowEmptyView: emptyView)
        dataView(self, willShowEmptyView: emptyView)

        let contentView = UIView()
        contentView.backgroundColor = style.contentViewBackgroundColor

        addContentView(contentView, to: containerView)
        addEmptyView(emptyView, to: contentView)

        dataView(self, didShowEmptyView: emptyView)
        emptyDataSetDelegate?.dataView(self, didShowEmptyView: emptyView)

        self.contentView = contentView
        self.emptyView = emptyView
    }

    private func hideEmptyView() {
        guard let emptyView = emptyView else {
            return
        }
        emptyDataSetDelegate?.dataView(self, willHideEmptyView: emptyView)
        dataView(self, willHideEmptyView: emptyView)

        emptyView.removeFromSuperview()
        contentView?.removeFromSuperview()

        dataView(self, didHideEmptyView: emptyView)
        emptyDataSetDelegate?.dataView(self, didHideEmptyView: emptyView)

        self.contentView = nil
        self.emptyView = nil
    }

    private func showLoadingView() {
        
        guard let loadingView = loadingView ?? emptyDataSetSource?.loadingViewForDataView(self),
            !loadingView.isDescendant(of: containerView) else {
                return
        }

        let style = emptyDataSetDelegate?.loadingStyleForDataView(self)
            ?? loadingStyleForDataView(self)
            ?? DataViewDefaultStyle()

        dataView(self, willShowLoadingView: loadingView)
        emptyDataSetDelegate?.dataView(self, willShowLoadingView: loadingView)

        let contentView = UIView()
        contentView.isUserInteractionEnabled = false
        contentView.backgroundColor = style.contentViewBackgroundColor
        
        addContentView(contentView, to: containerView)
        addLoadingView(loadingView, to: contentView)

        if let refreshable = loadingView as? Refreshable {
            refreshable.startRefreshing()
        }

        dataView(self, didShowLoadingView: loadingView)
        emptyDataSetDelegate?.dataView(self, didShowLoadingView: loadingView)

        self.contentView = contentView
        self.loadingView = loadingView
    }


    private func hideLoadingView() {
        guard let loadingView = loadingView else {
            return
        }

        emptyDataSetDelegate?.dataView(self, willHideLoadingView: loadingView)
        dataView(self, willHideLoadingView: loadingView)

        loadingView.removeFromSuperview()
        contentView?.removeFromSuperview()

        // If the loading view is refreshable end refreshing
        if let refreshable = loadingView as? Refreshable {
            refreshable.stopRefreshing()
        }

        dataView(self, didHideLoadingView: loadingView)
        emptyDataSetDelegate?.dataView(self, didHideLoadingView: loadingView)

        self.loadingView = nil
        self.contentView = nil
    }

    // MARK: - View setup hooks

    private func addEmptyView(_ emptyView: UIView, to contentView: UIView) {
        emptyView.translatesAutoresizingMaskIntoConstraints = false

        if emptyView.superview == nil {
            contentView.addSubview(emptyView)
        } else {
            emptyView.removeConstraints(emptyView.constraints)
        }

        emptyView.setContentHuggingPriority(.required, for: .horizontal)
        emptyView.setContentHuggingPriority(.required, for: .vertical)
        emptyView.setContentCompressionResistancePriority(.required, for: .horizontal)
        emptyView.setContentCompressionResistancePriority(.required, for: .vertical)

        let viewSideConstraints = [
            contentView.topAnchor.constraint(equalTo: emptyView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: emptyView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: emptyView.rightAnchor)
        ]

        viewSideConstraints.forEach { $0.priority = .required }

        contentView.addConstraints(viewSideConstraints)
        contentView.layoutIfNeeded()
    }

    private func addLoadingView(_ loadingView: UIView, to contentView: UIView) {

        loadingView.translatesAutoresizingMaskIntoConstraints = false

        if loadingView.superview == nil {
            contentView.addSubview(loadingView)
        }

        loadingView.setContentHuggingPriority(.required, for: .horizontal)
        loadingView.setContentHuggingPriority(.required, for: .vertical)
        loadingView.setContentCompressionResistancePriority(.required, for: .horizontal)
        loadingView.setContentCompressionResistancePriority(.required, for: .vertical)

        let centerConstraints = [
            contentView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
        ]

        let viewSideConstraints = [
            contentView.topAnchor.constraint(greaterThanOrEqualTo: loadingView.topAnchor),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: loadingView.bottomAnchor),
            contentView.leftAnchor.constraint(greaterThanOrEqualTo: loadingView.leftAnchor),
            contentView.rightAnchor.constraint(greaterThanOrEqualTo: loadingView.rightAnchor)
        ]

        viewSideConstraints.forEach { $0.priority = .fittingSizeLevel - 1 }

        contentView.addConstraints(centerConstraints)
        contentView.addConstraints(viewSideConstraints)
        contentView.layoutIfNeeded()
    }

    // Default functionality is to add the empty view over the entire container view
    public func addContentView(_ contentView: UIView, to containerView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false

        if contentView.superview == nil {
            containerView.addSubview(contentView)
        } else {
            contentView.removeConstraints(contentView.constraints)
        }

        contentView.setContentHuggingPriority(.required, for: .horizontal)
        contentView.setContentHuggingPriority(.required, for: .vertical)
        contentView.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentView.setContentCompressionResistancePriority(.required, for: .vertical)

        let viewSideConstraints = [
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ]

        viewSideConstraints.forEach { $0.priority = .required }

        containerView.addConstraints(viewSideConstraints)
        containerView.layoutIfNeeded()
    }
}
