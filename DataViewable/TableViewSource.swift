//
//  TableViewSource.swift
//  DataViewable
//
//  Created by Ian MacCallum on 8/13/18.
//  Copyright © 2018 Ian MacCallum. All rights reserved.
//

import UIKit


public protocol SectionedDataViewSource: class {
    func tableView(_ tableView: UITableView, emptyCellAt indexPath: IndexPath) -> UITableViewCell
}

public protocol SectionedTableViewDelegate: class {

}

public class TableDataViewSource: NSObject {

    var emptyDataSections: Set<Int> = .init()

    weak var dataSource: UITableViewDataSource?
    weak var delegate: UITableViewDelegate?

    weak var emptyDataSource: SectionedDataViewSource?
    weak var emptyDelegate: SectionedTableViewDelegate?

    init(
        dataSource: UITableViewDataSource?, emptyDataSource: SectionedDataViewSource?,
        delegate: UITableViewDelegate?, emptyDelegate: SectionedTableViewDelegate?
    ) {
        self.dataSource = dataSource
        self.emptyDataSource = emptyDataSource
        self.delegate = delegate
        self.emptyDelegate = emptyDelegate
        super.init()
    }
}

extension TableDataViewSource: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSections?(in: tableView) ?? 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0

        if rowCount == 0 {
            emptyDataSections.insert(section)
            return 1
        } else {
            emptyDataSections.remove(section)
            return rowCount
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let isEmptySection = emptyDataSections.contains(indexPath.section)

        if isEmptySection {
            return emptyDataSource!.tableView(tableView, emptyCellAt: indexPath)
        } else {
            return dataSource!.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource?.tableView?(tableView, titleForHeaderInSection: section)
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return dataSource?.tableView?(tableView, titleForFooterInSection: section)
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let isEmptySection = emptyDataSections.contains(indexPath.section)

        if isEmptySection {
            return false
        } else {
            return dataSource?.tableView?(tableView, canEditRowAt: indexPath) ?? false
        }
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let isEmptySection = emptyDataSections.contains(indexPath.section)

        if isEmptySection {
            return false
        } else {
            return dataSource?.tableView?(tableView, canMoveRowAt: indexPath) ?? false
        }
    }

    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataSource?.sectionIndexTitles?(for: tableView)
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return dataSource?.tableView?(tableView, sectionForSectionIndexTitle: title, at: index) ?? 0
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let isEmptySection = emptyDataSections.contains(indexPath.section)

        if !isEmptySection {
            dataSource?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let isEmptySection = emptyDataSections.contains(sourceIndexPath.section)

        if !isEmptySection {
            dataSource?.tableView?(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        }
    }
}


