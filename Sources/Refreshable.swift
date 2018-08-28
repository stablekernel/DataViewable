import UIKit

public protocol Refreshable: class {
	func startRefreshing()
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

