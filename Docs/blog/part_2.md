

## Part 2: Building an Empty Data Set Framework
Welcome back to a 2 part series on empty data sets. In [Part 1](part_1.md) we covered the use cases of empty data sets, the contexts in which we have empty data, and several examples. In this post we’re going to build an extensible, protocol-based Swift framework to make it easy to display empty data sets and loading indicators wherever we display data in our iOS applications. [DataViewable](https://github.com/stablekernel/DataViewable/) is available on GitHub.

One of the drawbacks of existing empty data set frameworks is their limited extensibility. The most popular alternative, [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet), only supports UITableView and UICollectionView. Our implementation will support any type that conforms to the `DataViewable` protocol. This means that we can handle displaying empty data for any UIView subclass as well as abstractions around UIView such as UIViewController. You can even write your own conditional conformances to the `DataViewable` protocol for your custom types. Using protocol extensions we are able to reuse the logic surrounding empty data sets at a higher level. Our implementation will not only account for handling empty data, but also will provide us with an out-of-the-box solution for using loading indicators so our users are never left with a blank screen.


### Empty Data Set State
Before we dive into the `DataViewable` protocol, it is important to understand the contexts where we have empty data. These contexts are explained in [Part 1](part_1.md). Our state won't account for the differences between the empty, error, and on-boarding contexts because the logic to determine these contexts varies too much on a case to case basis. Instead we will treat all of these as an "empty" state and let you decide which context you are in and the empty view to display to the user based on your implementation. The loading context will map directly to the "loading" state and we should show some sort of loading indicator to the user. The "data" state will indicate that data is present and we should not display an empty view or a loading indicator. Finally, the "updating" state will reflect the situation where we have data and more data is loading or refreshing. We should display a loading indicator to the user over top of our data as the default behavior. An empty data set only cares about two things when deciding what to display: do we have data to display and are we currently loading? These boolean properties, `hasData` and `isLoading`, cover all 4 possible states:

<p align="center" style="margin: 0px auto; width: 100%;">
  <table>
  <tr>
    <th></th>
    <th><b>hasData: true</b></th>
    <th><b>hasData: false</b></th>
  </tr>
  <tr>
    <td><b>isLoading: true</b></td>
    <td>updating/refreshing</td>
    <td>loading</td>
  </tr>
  <tr>
    <td><b>isLoading: false</b></td>
    <td>data</td>
    <td>empty</td>
  </tr>
</table>
</p>

  
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

We will use this state in our `DataViewable` protocol to determine what, if anything, we should display to the user.


### DataViewable Protocol
It all boils down to the `DataViewable` protocol. This protocol allows non-view types to be data viewable elements (i.e. abstractions around views such as `UIViewController` or coordinator/component architecture components) if need be, but we’ll focus primarily on `UIView` based classes. Don’t worry about the protocol inheritance to `EmptyDataSetDelegate` for now. We will only use this for hooks. Here’s the protocol:

```swift
public protocol DataViewable: DataViewDelegate {
  var emptyDataSetDelegate: DataViewDelegate? { get }
  var emptyDataSetSource: DataViewSource? { get }
  
  var hasData: Bool { get }
  var isLoading: Bool { get set }
  
  var containerView: UIView { get }
  var emptyView: UIView? { get set }
  var loadingView: UIView? { get set }
  
  func addContentView(_ contentView: UIView, to containerView: UIView)
  func contentViewWithEmptyView(_ emptyView: UIView) -> UIView
  func contentViewWithLoadingView(_ loadingView: UIView) -> UIView

  func reloadEmptyDataSet()
}
```

The protocol is pretty simple. There is an `emptyDataSetSource` and `emptyDataSetDelegate` for customization, `hasData` and `isLoading` for maintaining state, `containerView` for specifying the view in which to setup the empty data view and loading indicator, and `emptyView`/`loadingView` references so we can remove them from the view hierarchy when the state changes. We have define `contentViewWithEmptyView(_:) -> UIView` and `contentViewWithLoadingView(_:) -> UIView` so subclasses may override how the `emptyView` and `loadingView` are setup in their `contentView`. We define `func addContentView(_:to:)` to allow for customization of how a `contentView` is setup in the specified `containerView`. The default functionality here is to make a `contentView` span the entirety of the `containerView`, but when we have a table view with a header, we want to pin the top of the `contentView` to the bottom of the header view instead of the top of the table view. Finally, we have `reloadEmptyDataSet()` which will either show or hide the `emptyView` or `loadingView` depending on the current state. 

In the `DataViewable` protocol extension we provide default implementations for everything in the protocol except `containerView`. This is where the bulk of our framework logic lies. We won’t dive much into these implementation details, but definitely take a look at the [code](https://github.com/stablekernel/DataViewable/)! One thing I do want to comment on regarding our implementation is the use of  `objc_getAssociatedObject` and `objc_setAssociatedObject` to provide defaults for our stored properties (`emptyDataSetDelegate`, `emptyDataSetSource`, `isLoading`, `emptyView`, and `loadingView`). Stored properties are not allowed in extensions so we implement them by defining getters/setters for the property and using Objective-C associated objects. This taps into the Objective-C runtime to dynamically associate values with an object. If this makes you uncomfortable, don’t worry, these are only defaults and these will never be called if you implement them in your subclass. Most other implementations take a similar approach.

### Conditional Conformance for View Components
Our default `hasData` implementation in the `DataViewable` protocol extension will return `true` but may be overriden by implementing `hasDataForDataView(_:) -> Bool?` for the `emptyDataSetSource`. With a `UITableView`, `UICollectionView`, or `UIImageView`, we can provide better default values based on the data these types display.

For `UIImageView` subclasses, it’s safe to assume that if `image` is set to a non-nil `UIImage` then we have data. This assumption can be applied to all image views that conform to `DataViewable` using [conditional conformance](https://swift.org/blog/conditional-conformance/) to the `DataViewable` protocol:

```swift
public extension DataViewable where Self: UIImageView {
  public var hasData: Bool {
    return image != nil
  }
}
```

For `UITableView` and `UICollectionView` subclasses we can take the same approach but we can check `numberOfSections` and `numberOfRows(inSection:)` to determine if we have data.

```swift
public extension DataViewable where Self: UITableView {
  public var hasData: Bool {

    // Get the item count
    let itemCount = (0..<numberOfSections).reduce(0) {
      $0 + numberOfRows(inSection: $1)
    }
    
    return itemCount > 0
  }

  public func addContentView(_ contentView: UIView, to containerView: UIView) {
    // Setup contentView underneath table view's header view if it exists
  }

}

// More or less the same for UICollectionView
```

### Concrete Subclasses for UIView Components
Once conformance to the `DataViewable` protocol has been acheived, empty data and loading indicators will show only if `reloadEmptyDataSet()` is manually called whenever data changes. With common UI components (i.e. `UITableView`, `UICollectionView`, and `UIImageView`) there are existing functions that are used to update the data (i.e. `reloadData()` on `UITableView`). We need to tap into these functions where applicable and call `reloadEmptyDataSet()` so our empty data set state is updated automatically when our data is updated. Other implementations will swizzle these methods, but we will use subclassing for this implementation, calling our concrete `UITableView` subclass `DataTableView`. To get all the great functionality from `DataViewable` all we need to do is make our subclass conform to `DataViewable` and override the functions that manipulate the table view’s data to call `reloadEmptyDataSet()`:

```swift
open class DataTableView: UITableView, DataViewable {

  override open func reloadData() {
    super.reloadData()
    reloadEmptyDataSet()
  }
  // Same for [insert/delete][Rows/Sections](_:)
}
```

### Usage

Our concrete subclasses are now ready to be used. For use with a table view, all we need to do is use a DataTableView and implement its source. We will use the default views this framework provides for both the loading indicator and the empty view. 

```swift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: DataTableView!
    
    var listItems: [String]?
    var error: Error?


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.reloadData()

        loadData()
    }

    func loadData() {
        tableView.isLoading = true

        SomeService.fetchData { [weak self] result in
            self?.tableView.isLoading = false

            switch result {
              case .value(let items):
                self?.listItems = items
                self?.error = nil
              case .error(let error):
                self?.listItems = nil
                self?.error = error
            }

            self?.tableView.reloadData()

        }
    }
}

extension ViewController: UITableViewDataSource {
  // Implement UITableViewDataSource
}

extension ViewController: DataViewSource {

    func emptyViewForDataView(_ dataView: DataViewable) -> UIView? {
        let view = EmptyDataView(delegate: delegate)
        // Customize view using error we received
        return view
    }
}

extension ViewController: EmptyDataViewDelegate {
    func emptyDataViewDidPressButton(_ EmptyDataView: EmptyDataView) {
        // Try to fetch data again
        loadData()
    }

}

```

And that's all there is to it! All we need to do is use a `DataViewable` view, implement `DataViewSource`, set `isLoading ` to true before fetching our data, and set `isLoading` to false once we have resolved our data. All of the logic is handled by `DataViewable`. 



