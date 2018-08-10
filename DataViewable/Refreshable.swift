//
//  Refreshable.swift
//  EmptyDataSet
//
//  Created by Ian MacCallum on 8/7/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

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
