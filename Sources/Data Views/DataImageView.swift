import UIKit

open class DataImageView: UIImageView, DataViewable {

    open override var image: UIImage? {
        didSet {
            reloadEmptyDataSet()
        }
    }
}
