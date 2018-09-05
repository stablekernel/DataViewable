import UIKit

public protocol Refreshable: class {
	/// Called when the loading view is setup in the container view
	func startRefreshing()

	/// Called when the loading view is removed from the container view
	func stopRefreshing()
}

extension UIRefreshControl: Refreshable {
	public func startRefreshing() {
		beginRefreshing()
	}

	public func stopRefreshing() {
		endRefreshing()
	}
}

extension UIActivityIndicatorView: Refreshable {
	public func startRefreshing() {
		startAnimating()
	}

	public func stopRefreshing() {
		stopAnimating()
	}
}
