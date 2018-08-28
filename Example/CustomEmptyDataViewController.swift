import UIKit

class CustomEmptyDataViewController: UIViewController {

	@IBOutlet weak var dataView: DataView!

	var isEmpty = false {
		didSet {
			dataView.reloadEmptyDataSet()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		dataView.emptyDataSetSource = self
		dataView.emptyDataSetDelegate = self

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(title: "Data", style: .plain, target: self, action: #selector(loadData)),
			UIBarButtonItem(title: "Empty", style: .plain, target: self, action: #selector(hideData))
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

	func dataViewHasData(_ dataView: DataViewable) -> Bool? {
		return !isEmpty
	}
}

extension CustomEmptyDataViewController: DataViewDelegate {

}

extension CustomEmptyDataViewController: EmptyDataViewDelegate {
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
