# DataViewable

<p align="center">
    <a href="https://cocoapods.org/pods/DataViewable">
        <img src="https://img.shields.io/cocoapods/v/DataViewable.svg" alt="CocoaPods" />
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat" alt="Carthage" />
    </a>
</p>

DataViewable is an extensible, protocol-based framework to make it easy to display empty data sets and loading indicators for any view that is used to display data to users. The `DataViewable` protocol defines an interface for creating empty data sets. Default implementations in the `DataViewable` protocol extension provide the bulk of the logic necessary to easily implement empty data sets and loading indicators on any view type. Conditional conformance to the `DataViewable` protocol allows us to provide useful overrides of the default implementations for various UI elements (`UITableView`, `UICollectionView`, `UIImageView`, `UIView`, etc...).



# Installation

## CocoaPods:

Add the line `pod "DataViewable"` to your Podfile

## Carthage:

Add the line `github "stablekernel/DataViewable"` to your Cartfile

## Manual:

Clone the repo and drag the file files in Sources/ into your Xcode project.

## Swift Package Manager:

Add the line `.Package(url: "https://github.com/stablekernel/DataViewable.git", majorVersion: 0)` to your Package.swift


# Usage

Implement `DataViewSource` and `emptyViewForDataView` to return the empty view you wish to display.

```swift
extension ViewController: DataViewSource {

  func emptyViewForDataView(_ dataView: DataViewable) -> UIView? {
    let view = EmptyDataView(delegate: self)
    view.imageView.image = #imageLiteral(resourceName: "error_image")
    view.titleLabel.text = "Sorry, no data!"
    view.detailLabel.text = "Something bad happened :("
    view.button.setTitle("Reload", for: .normal)
    return view
  }
}

extension ViewController: EmptyDataViewDelegate {
  func emptyDataViewWasPressed(_ emptyDataView: EmptyDataView) {
    // Some action
  }

  func emptyDataViewDidPressButton(_ emptyDataView: EmptyDataView) {
    reloadData()
  }

  func emptyDataViewDidPressImage(_ emptyDataView: EmptyDataView) {
    // Some action
  }
}
```

Set this `DataViewSource` as the `emptyDataSetSource` of some `DataViewable`

```swift

@IBOutlet weak var tableView: DataTableView!

override func viewDidLoad() {
  super.viewDidLoad()
  tableView.emptyDataSetSource = self
  reloadData()
}
```

Set `isLoading` to `true` before fetching your data and `false` when complete. Assign your data and reload your view as you normally would.

```swift
func reloadData() {
  tableView.isLoading = true

  Store.fetchData { [weak self] result in

    switch result {
    case .value(let data):
      self?.data = data
    case .error(let error):
      self?.error = error
    }

    self?.tableView.isLoading = false
    self?.tableView.reloadData()
  }
}
```


# Platform support

DataViewable supports all current Apple platforms with the following minimum versions:

- iOS 11
- OS X: n/a
- watchOS: n/a
- tvOS: n/a



