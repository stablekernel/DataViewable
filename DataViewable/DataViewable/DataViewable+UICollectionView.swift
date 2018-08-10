//
//  DataViewable+UICollectionView.swift
//  DataViewable
//
//  Created by Ian MacCallum on 7/31/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

public extension DataViewable where Self: UICollectionView {
    public var hasData: Bool {

        // Customn user defined hasData parameter
        if let hasData = emptyDataSetSource?.hasDataForDataView(self) {
            return hasData
        }

        // Get the item count
        let itemCount = (0..<numberOfSections).reduce(0) {
            $0 + numberOfItems(inSection: $1)
        }
        
        return itemCount > 0
    }
}
