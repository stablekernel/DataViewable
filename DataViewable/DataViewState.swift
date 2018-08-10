//
//  DataViewableState.swift
//  DataViewable
//
//  Created by Ian MacCallum on 7/31/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import Foundation

public enum DataViewState {
    case data
    case loading
    case updating
    case empty

    init(hasData: Bool, isLoading: Bool) {
        switch (hasData, isLoading) {
        case (true, true): self = .updating
        case (true, false): self = .data
        case (false, true): self = .loading
        case (false, false): self = .empty
        }
    }
}
