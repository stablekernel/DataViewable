import UIKit

open class DataCollectionView: UICollectionView, DataViewable {

	// MARK: - Reload Empty Data Souce

	override open func reloadData() {
		super.reloadData()
		reloadEmptyDataSet()
	}

	open override func insertSections(_ sections: IndexSet) {
		super.insertSections(sections)
		reloadEmptyDataSet()
	}

	open override func insertItems(at indexPaths: [IndexPath]) {
		super.insertItems(at: indexPaths)
		reloadEmptyDataSet()
	}

	open override func deleteSections(_ sections: IndexSet) {
		super.deleteSections(sections)
		reloadEmptyDataSet()
	}

	open override func deleteItems(at indexPaths: [IndexPath]) {
		super.deleteItems(at: indexPaths)
		reloadEmptyDataSet()
	}
}



