//
//  SectionedTableViewController.swift
//  EmptyDataSetExample
//
//  Created by Ian MacCallum on 8/13/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

struct Section {
    let title: String
    var items: [Item]

    var isEmpty: Bool {
        return items.count == 0
    }
}

struct Item {
    let title: String
}

class SectionedTableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var sections: [Section] = [
        Section(title: "First section", items: []),
        Section(title: "Second section", items: [
            Item(title: "item"),
            Item(title: "item"),
            Item(title: "item"),
        ]),
        Section(title: "Third section", items: []),
        Section(title: "Fourth section", items: [
            Item(title: "item"),
            Item(title: "item"),
            Item(title: "item"),
            ])
    ]

    lazy var dataSource = TableDataViewSource(dataSource: self, emptyDataSource: self, delegate: self, emptyDelegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: "EmptySectionTableViewCell", bundle: nil), forCellReuseIdentifier: "emptyCell")
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.dataSource = dataSource
    }

}

extension SectionedTableViewController: UITableViewDataSource {


    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }
}

extension SectionedTableViewController: UITableViewDelegate {

}



extension SectionedTableViewController: SectionedDataViewSource {
    func tableView(_ tableView: UITableView, emptyCellAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath) as! EmptySectionTableViewCell
        cell.owningTableView = tableView

        cell.emptyImageView.image = #imageLiteral(resourceName: "error_image")
        cell.emptyTextLabel.text = "Something went wrong"
        cell.emptyButton.setTitle("Reload", for: .normal)

        cell.onButtonPressed = { [weak self] indexPath, button in
            print("Button pressed")

            self?.sections[indexPath.section].items = [
                Item(title: "Loaded"),
                Item(title: "Loaded")
            ]

            self?.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
        return cell
    }
}

extension SectionedTableViewController: SectionedTableViewDelegate {
    
}

