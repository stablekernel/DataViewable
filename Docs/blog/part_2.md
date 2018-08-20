

## Part 2: Building an Empty Data Set Framework
We’re going to build an extensible, protocol-based framework for using empty data sets with any class type. Any view can display data, but this framework will include a bunch of logic that we may want to reuse at a higher level, for example if we are using some component/coordinator based architecture where the object containing the logic sits above the view. Our protocol will account for this by requiring the class implementing this protocol to tell us which views we should use to setup our empty data set view in. Our implementation will not only account for the handling of empty data, but also will provide us with an out-of-the-box solution for using loading indicators so our users are never left with a blank screen. 

### Empty Data Set State
An empty data set only cares about two things when deciding what to display: do we have data to display and are we currently loading? These `Bool` properties `hasData` and `isLoading` have 4 possible combinations.

Table: hasData and isLoading map to state
This leaves us with 4 states:
1. hasData: false, isLoading: false —> Empty
2. hasData: false, isLoading: true —> Loading
3. hasData: true, isLoading: false —> Data
4. hasData: true, isLoading: true —> Updating/Refreshing

This state is reflected in our `DataViewState` enum where we define the cases and provide an initializer based on `hasData` and `isLoading` state:

```swift
public enum DataViewState {
  case data
  case loading
  case updating
  case empty

  init(hasData: Bool, isLoading: Bool) {
    switch (hasData, isLoading) {
    case (true, true): self = .updating
    case (true, false): self = .data
    case (false, true): self = .loading
    case (false, false): self = .empty
    }
  }
}
```

### DataViewable Protocol
It all boils down to the `DataViewable` protocol. This protocol allows non-view types to be data viewable elements (i.e. abstractions around views such as `UIViewController` or coordinator/component architecture components) if need be, but we’ll focus primarily on `UIView` based classes. Don’t worry about the protocol inheritance to `EmptyDataSetDelegate` for now. We will only use this for hooks. Here’s the protocol:

```swift
public protocol DataViewable: DataViewDelegate {
  var emptyDataSetDelegate: DataViewDelegate? { get }
  var emptyDataSetSource: DataViewSource? { get }

  // State
  var hasData: Bool { get }
  var isLoading: Bool { get }
  func reloadEmptyDataSet()

  // View
  var containerView: UIView { get }
  var contentView: UIView? { get }
  var emptyView: UIView? { get set }
  var loadingView: UIView? { get set }
  func addContentView(_ contentView: UIView, to containerView: UIView)
}
```

The protocol is pretty simple. There is an `emptyDataSetSource` and `emptyDataSetDelegate` for customization, `hasData` and `isLoading` for maintaining state, `containerView` for specifying the view in which to setup the empty data view and loading indicator, and `contentView`/`emptyView`/`loadingView` references so we can remove them from the view hierarchy when the state changes. Finally, we have `reloadEmptyDataSet()` which will setup the `emptyView` or `loadingView` in the `containerView` depending on the current state.

In the `DataViewable` protocol extension we provide default implementations for everything in the protocol. We won’t dive much into these implementation details, but definitely take a look at the code! One thing I do want to comment on regarding our implementation is the use of  `objc_getAssociatedObject` and `objc_setAssociatedObject` to provide defaults for our stored properties (`emptyDataSetDelegate`, `emptyDataSetSource`, `isLoading`, `contentView`, `emptyView`, and `loadingView`). Stored properties are not allowed in extensions so we implement them by defining getters/setters for the property and using Objective-C associated objects. This taps into the Objective-C runtime to dynamically associate values. If this makes you uncomfortable, don’t worry. These are only defaults and these will never be called if you implement them in your subclass. 

### Conditional Conformance for UIView Components
Our default `hasData` implementation in the `DataViewable` protocol extension will delegate that responsibility back to the `emptyDataSetSource` which has a `hasDataForDataView(_:) -> Bool?` call. With a `UITableView`, `UICollectionView`, or `UIImageView`, we can provide better default values based on the data these types display.

For `UIImageView` subclasses, it’s safe to assume that if `image` is set to a non-nil `UIImage` then we have data. This assumption can be applied to all image views that conform to `DataViewable` using conditional conformance to the `DataViewable` protocol:
```swift
public extension DataViewable where Self: UIImageView {
  public var hasData: Bool {

    // Customn user defined hasData parameter
    if let hasData = emptyDataSetSource?.hasDataForDataView(self) {
      return hasData
    }

    return image != nil
  }
}
```

For `UITableView` and `UICollectionView` subclasses we can take the same approach but we can check `numberOfSections` and `numberOfRows(inSection:)` to determine if we have data.

```swift
public extension DataViewable where Self: UITableView {
  public var hasData: Bool {

    // Custom user defined hasData parameter
    if let hasData = emptyDataSetSource?.hasDataForDataView(self) {
      return hasData
    }

    // Get the item count
    let itemCount = (0..<numberOfSections).reduce(0) {
      $0 + numberOfRows(inSection: $1)
    }
    
    return itemCount > 0
  }
}
```

### Concrete Subclasses for UIView Components
Once our `DataViewable` protocol has been implemented, our empty data and loading indicators will show only if we call `reloadEmptyDataSet()` manually whenever our data changes. With common UI components (i.e. `UITableView`, `UICollectionView`, and `UIImageView`) there are functions that we use to update the data (i.e. `reloadData()` on `UITableView`). We need to tap into these functions and call `reloadEmptyDataSet()` so our empty data set state is updated automatically. Many other empty data set implementations will swizzle the methods, but we will use subclassing for this implementation, calling our concrete `UITableView` subclass `DataTableView`. To get all the great functionality from `DataViewable` all we need to do is make our subclass conform to `DataViewable` and override the functions that manipulate the table view’s data to call `reloadEmptyDataSet()`:

```swift
open class DataTableView: UITableView, DataViewable {

  override open func reloadData() {
    super.reloadData()
    reloadEmptyDataSet()
  }
  // Same for [insert/delete][Rows/Sections](_:)
}
```

Usage


Future Work 

