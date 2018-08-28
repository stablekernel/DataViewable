import UIKit

open class DataTableView: UITableView, DataViewable {

	// MARK: - Reload Empty Data Souce

	override open func reloadData() {
		super.reloadData()
		reloadEmptyDataSet()
	}

	open override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
		super.insertSections(sections, with: animation)
		reloadEmptyDataSet()
	}

	open override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
		super.insertRows(at: indexPaths, with: animation)
		reloadEmptyDataSet()
	}

	open override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
		super.deleteSections(sections, with: animation)
		reloadEmptyDataSet()
	}

	open override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
		super.deleteRows(at: indexPaths, with: animation)
		reloadEmptyDataSet()
	}
}
