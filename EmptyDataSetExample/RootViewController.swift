//
//  RootViewController.swift
//  DataViewableExample
//
//  Created by Ian MacCallum on 7/20/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

enum Example: String {
    case tableView = "UITableView"
    case view = "Custom View"
    case image = "Image View"
    case viewController = "View Controller"

    static let allCases: [Example] = [.tableView, .view, .image, .viewController]
}

class RootViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let examples = Example.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self

        title = "Empty Data Set"
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let example = examples[indexPath.row]
        cell.textLabel?.text = example.rawValue
        return cell
    }
}

extension RootViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = examples[indexPath.row]
        let viewController = self.viewController(for: example)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension RootViewController {
    private func viewController(for example: Example) -> UIViewController {
        switch example {
        case .tableView:
            return ViewController()
        case .view:
            return CustomEmptyDataViewController()
        case .image:
            return EmptyImageViewController()
        case .viewController:
            return EmptyViewController()
        }
    }
}
