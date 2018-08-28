import UIKit

class EmptyImageViewController: UIViewController {

	@IBOutlet weak var imageView: DataImageView!

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



