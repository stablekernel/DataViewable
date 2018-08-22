//
//  EmptySectionTableViewCell.swift
//  DataViewable
//
//  Created by Ian MacCallum on 8/13/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

public class EmptySectionTableViewCell: UITableViewCell {

    @IBOutlet weak var emptyImageView: UIImageView!
    @IBOutlet weak var emptyTextLabel: UILabel!
    @IBOutlet weak var emptyButton: UIButton!

    weak var owningTableView: UITableView?

    var indexPath: IndexPath? {
        return owningTableView?.indexPath(for: self)
    }

    var onButtonPressed: ((IndexPath, UIButton) -> Void)?

    public override func prepareForReuse() {
        super.prepareForReuse()
        owningTableView = nil
    }

    @IBAction func didPressEmptyButton(_ sender: UIButton) {
        guard let indexPath = indexPath else {
            return
        }

        onButtonPressed?(indexPath, sender)
    }
}
