//
//  DataViewable+UILabel.swift
//  DataViewable
//
//  Created by Ian MacCallum on 8/23/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

public extension DataViewable where Self: UILabel {
	public var hasData: Bool {
		return text != nil
	}
}
