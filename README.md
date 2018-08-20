# DataViewable
DataViewable is an extensible, protocol-based framework to make it easy to display empty data sets and loading indicators for any view that is used to display data to users. The `DataViewable` protocol defines an interface for creating empty data sets. Default implementations in the `DataViewable` protocol extension provide the bulk of the logic necessary to easily implement empty data sets and loading indicators on any view type. Conditional conformance to the `DataViewable` protocol allows us to provide useful overrides of the default implementations for various UI elements (`UITableView`, `UICollectionView`, `UIImageView`, `UIView`, etc...).









