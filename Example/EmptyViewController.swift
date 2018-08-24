//
//  EmptyViewController.swift
//  DataViewableExample
//
//  Created by Ian MacCallum on 7/31/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController, DataViewable {

    var isEmpty = false {
        didSet {
            reloadEmptyDataSet()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyDataSetSource = self
        emptyDataSetDelegate = self

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Data", style: .plain , target: self, action: #selector(loadData)),
            UIBarButtonItem(title: "Empty", style: .plain , target: self, action: #selector(hideData))
        ]

        reloadEmptyDataSet()
    }

    @objc func loadData() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isLoading = false
            self?.isEmpty = false
        }
    }

    @objc func hideData() {
        isEmpty = true
        isLoading = false
    }
}

extension EmptyViewController: DataViewSource {

    func emptyViewForDataView(_ dataView: DataViewable) -> UIView? {
        return EmptyDataViewFactory.makeEmptyDataView(for: self)
    }

    func dataViewHasData(_ dataView: DataViewable) -> Bool? {
        return !isEmpty
    }
}

extension EmptyViewController: DataViewDelegate {

}

extension EmptyViewController: EmptyDataViewDelegate {
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


