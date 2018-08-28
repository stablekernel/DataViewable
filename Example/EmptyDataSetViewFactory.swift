import UIKit

class EmptyDataViewFactory {

	static func makeEmptyDataView(for delegate: EmptyDataViewDelegate) -> EmptyDataView {
		let view = EmptyDataView(delegate: delegate)
		view.imageView.image = #imageLiteral(resourceName: "error_image")
		view.titleLabel.text = "Sorry, no data!"
		view.detailLabel.text = "Something bad happened :("
		view.button.setTitle("Reload", for: .normal)
		return view
	}
}
