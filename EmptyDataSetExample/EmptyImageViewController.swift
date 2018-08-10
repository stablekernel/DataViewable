//
//  EmptyImageViewController.swift
//  DataViewableExample
//
//  Created by Ian MacCallum on 7/23/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit

class EmptyImageViewController: UIViewController {

    @IBOutlet weak var imageView: DataImageView!

    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.emptyDataSetSource = self
        imageView.emptyDataSetDelegate = self

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Data", style: .plain , target: self, action: #selector(loadData)),
            UIBarButtonItem(title: "Empty", style: .plain , target: self, action: #selector(hideData))
        ]

        imageView.reloadEmptyDataSet()
    }

    @objc func loadData() {
        imageView.isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.imageView.isLoading = false
            self?.imageView.image = #imageLiteral(resourceName: "success_image")
        }
    }

    @objc func hideData() {
        imageView.image = nil
        imageView.isLoading = false
    }
}

extension EmptyImageViewController: DataViewSource {

    func emptyViewForDataView(_ dataView: DataViewable) -> UIView? {
        return EmptyDataViewFactory.makeEmptyDataView(for: self)
    }

    func loadingViewForDataView(_ dataView: DataViewable) -> UIView? {
        return activityIndicator
    }
}

extension EmptyImageViewController: DataViewDelegate {

}

extension EmptyImageViewController: EmptyDataViewDelegate {
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


