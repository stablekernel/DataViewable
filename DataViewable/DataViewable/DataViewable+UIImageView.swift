//
//  DataViewable+UIImageView.swift
//  DataViewable
//
//  Created by Ian MacCallum on 7/31/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

public extension DataViewable where Self: UIImageView {
    public var hasData: Bool {
        return image != nil
    }
}
