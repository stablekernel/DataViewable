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
			UIBarButtonItem(title: "Data", style: .plain, target: self, action: #selector(loadData)),
			UIBarButtonItem(title: "Empty", style: .plain, target: self, action: #selector(hideData))
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
	func emptyDataViewWasPressed(_ emptyDataView: EmptyDataView) {
		print("tap")
	}

	func emptyDataViewDidPressButton(_ emptyDataView: EmptyDataView) {
		loadData()
	}

	func emptyDataViewDidPressImage(_ emptyDataView: EmptyDataView) {
		print("image")
	}
}
