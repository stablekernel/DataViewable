import UIKit

public protocol DataViewSource {
    func hasDataForDataView(_ dataView: DataViewable) -> Bool?
    func emptyViewForDataView(_ dataView: DataViewable) -> UIView?
    func containerViewForDataView(_ dataView: DataViewable) -> UIView?
    func loadingViewForDataView(_ dataView: DataViewable) -> UIView?
}

public extension DataViewSource {
    func hasDataForDataView(_ dataView: DataViewable) -> Bool? {
        return nil
    }

    func emptyViewForDtaViewable(_ dataViewable: DataViewable) -> UIView? {
        return nil
    }

    func loadingViewForDataView(_ dataView: DataViewable) -> UIView? {
        return nil
    }

    func containerViewForDataView(_ dataView: DataViewable) -> UIView? {
        return nil
    }
}



public protocol SectionedDataViewSource {
    func numberOfSectionsInDataView(_ dataView: DataViewable) -> Int
    func dataView(_ dataView: DataViewable, numberOfItemsInSection section: Int) -> Int?
    func emptyViewForDataView(_ dataView: DataViewable) -> UIView?
    func containerViewForDataView(_ dataView: DataViewable) -> UIView?
    func loadingViewForDataView(_ dataView: DataViewable) -> UIView?
}

public extension SectionedDataViewSource {
    func hasDataForDataView(_ dataView: DataViewable) -> Bool? {
        return nil
    }

    func emptyViewForDtaViewable(_ dataViewable: DataViewable) -> UIView? {
        return nil
    }

    func loadingViewForDataView(_ dataView: DataViewable) -> UIView? {
        return nil
    }

    func containerViewForDataView(_ dataView: DataViewable) -> UIView? {
        return nil
    }
}

