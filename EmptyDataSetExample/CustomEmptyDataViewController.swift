//
//  CustomEmptyDataViewController.swift
//  DataViewableExample
//
//  Created by Ian MacCallum on 7/20/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

class CustomEmptyDataViewController: UIViewController {

    @IBOutlet weak var dataView: DataView!

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    var isEmpty = false {
        didSet {
            dataView.reloadEmptyDataSet()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.frame.size = CGSize(width: 48, height: 48)

        dataView.emptyDataSetSource = self
        dataView.emptyDataSetDelegate = self

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Data", style: .plain , target: self, action: #selector(loadData)),
            UIBarButtonItem(title: "Empty", style: .plain , target: self, action: #selector(hideData))
        ]
    }

    @objc func loadData() {
        dataView.isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.dataView.isLoading = false
            self?.isEmpty = false
        }
    }

    @objc func hideData() {
        isEmpty = true
        dataView.isLoading = false
    }
}

extension CustomEmptyDataViewController: DataViewSource {

    func emptyViewForDataView(_ dataView: DataViewable) -> UIView? {
        return EmptyDataViewFactory.makeEmptyDataView(for: self)
    }

    func loadingViewForDataView(_ dataView: DataViewable) -> UIView? {
        return activityIndicator
    }

    func hasDataForDataView(_ dataView: DataViewable) -> Bool? {
        return !isEmpty
    }
}

extension CustomEmptyDataViewController: DataViewDelegate {

}


extension CustomEmptyDataViewController: EmptyDataViewDelegate {
    func emptyDataViewWasPressed(_ EmptyDataView: EmptyDataView) {
        print("tap")
    }

    func emptyDataViewDidPressButton(_ EmptyDataView: EmptyDataView) {
        loadData()
    }

    func emptyDataViewDidPressImage(_ EmptyDataView: EmptyDataView) {
        print("image")
    }
}

