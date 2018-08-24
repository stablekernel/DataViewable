//
//  DataViewable+UITableView.swift
//  DataViewable
//
//  Created by Ian MacCallum on 7/31/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

private var kShouldDisplayOverHeader = "shouldDisplayOverHeader"

public extension DataViewable where Self: UITableView {

    public var shouldDisplayDataViewableOverHeader: Bool {
        get {
            return objc_getAssociatedObject(self, &kShouldDisplayOverHeader) as? Bool ?? true
        }
        set {
            if shouldDisplayDataViewableOverHeader != newValue {
                objc_setAssociatedObject(self, &kShouldDisplayOverHeader, newValue, .OBJC_ASSOCIATION_RETAIN)
                reloadEmptyDataSet()
            }
        }
    }

    public var hasData: Bool {
        // Get the item count
        let itemCount = (0..<numberOfSections).reduce(0) {
            $0 + numberOfRows(inSection: $1)
        }
        
        return itemCount > 0
    }

	public func addEmptyView(_ emptyView: UIView, to containerView: UIView) {
		containerView.translatesAutoresizingMaskIntoConstraints = false
		emptyView.translatesAutoresizingMaskIntoConstraints = false

		if emptyView.superview == nil {
			containerView.addSubview(emptyView)
		} else {
			emptyView.removeConstraints(emptyView.constraints)
		}

		let topConstraint: NSLayoutConstraint

		if let headerView = tableHeaderView, !shouldDisplayDataViewableOverHeader {
			topConstraint = headerView.bottomAnchor.constraint(equalTo: emptyView.topAnchor)
		} else {
			topConstraint = frameLayoutGuide.topAnchor.constraint(equalTo: emptyView.topAnchor)
		}

		let viewSideConstraints = [
			topConstraint,
			frameLayoutGuide.bottomAnchor.constraint(equalTo: emptyView.bottomAnchor),
			frameLayoutGuide.leftAnchor.constraint(equalTo: emptyView.leftAnchor),
			frameLayoutGuide.rightAnchor.constraint(equalTo: emptyView.rightAnchor)
		]

		containerView.addConstraints(viewSideConstraints)
		containerView.layoutIfNeeded()
	}

//	public func addLoadingView(_ loadingView: UIView, to containerView: UIView) {
//		loadingView.translatesAutoresizingMaskIntoConstraints = false
//
//		if loadingView.superview == nil {
//			containerView.addSubview(loadingView)
//		} else {
//			loadingView.removeConstraints(loadingView.constraints)
//		}
//
//		let topConstraint: NSLayoutConstraint
//
//		if let headerView = tableHeaderView, !shouldDisplayDataViewableOverHeader {
//			topConstraint = headerView.bottomAnchor.constraint(greaterThanOrEqualTo: loadingView.topAnchor)
//		} else {
//			topConstraint = frameLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: loadingView.topAnchor)
//		}
//
//		let viewSideConstraints = [
//			topConstraint,
//			frameLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: loadingView.bottomAnchor),
//			frameLayoutGuide.leftAnchor.constraint(greaterThanOrEqualTo: loadingView.leftAnchor),
//			frameLayoutGuide.rightAnchor.constraint(greaterThanOrEqualTo: loadingView.rightAnchor)
//		]
//
//		containerView.addConstraints(viewSideConstraints)
//		containerView.layoutIfNeeded()
//	}
}
