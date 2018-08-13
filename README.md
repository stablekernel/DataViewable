# DataViewable
DataViewable is an extensible, protocol-based framework to make it easy to display empty data sets and loading indicators for any view that is used to display data to users. The `DataViewable` protocol defines an interface for creating empty data sets. Default implementations in the `DataViewable` protocol extension provide the bulk of the logic necessary to easily implement empty data sets and loading indicators on any view type. Conditional conformance to the `DataViewable` protocol allows us to provide useful overrides of the default implementations for various UI elements (`UITableView`, `UICollectionView`, `UIImageView`, `UIView`, etc...).

## Part 1: What are Empty Data Sets and Why You Should Use Them?
In this 2 part series we’ll explore the what, when, where, why, and how of empty data sets in mobile applications. In this post we’ll cover everything you need to know about empty data sets with a strong focus on user experience. This post will be pertinent regardless of your role as a stakeholder (I’ll try not to get too technical in this post). In [Part 2: Building an Empty Data Set Framework]() we will walk through a Swift implementation empty data sets in iOS apps so we can reduce boilerplate code. Let’s get started.

### Motivation for Using Empty Data Sets
The vast majority of mobile applications will integrate with some type of database, whether that be local or on a server, then display this data to end users in some fashion. When the database returns non-empty data to display everything is fine and dandy. However, when there is an error retrieving data from the database or when the data is empty (which can be the case when we’re fetching lists of object and none are returned or before we have fetched any data), we run into a situation on how to relay this information to the user. One of the easiest ways to improve user experience in your application is to make sure you correctly handle empty data. This tends to not be a problem for huge companies with vast resources but it is something that is often overlooked in smaller apps. 

#### Contexts
There four main contexts when a user may find themselves with empty data:
1. On-boarding context. A user hasn’t taken any action yet.
2. Loading context. A user has taken an action but due to latency we have not yet received data or an error.
3. Error context. A user has taken an action but something went wrong. 
4. Empty context. A user has taken an action and their action was successfully received but there is actually no data to display.

Consider the following application: users search for restaurants nearby and the results are displayed in a table. The user specifies a radius in which to search. If there are restaurants in range matching the search the server will return them. If there are no restaurants in range the server will give us an empty list. In an example as simple as this, there are several contexts where we may have empty data:

1. The user has not entered anything to search we have no results. On screen, there is an empty search bar and an empty table. (On-boarding)
2. A user types something and before the server gives us a response we show a loading indicator. (Loading)
3. We receive an error. Something went wrong with the connection or the server responded with an error. We have no data to display. (Error)
4. A user searches and receives a successful response but no restaurants matching their search were found within the radius specified (Empty)

In each situation there are differences in how we got to the point of having empty data and what the user needs to do to recover. In the first situation the user is new to the page and needs to search for something. We need to let the user know that searching for something is the action they need to take. In the second situation the user has searched for something but  the user searched for something and something went wrong. We have an error message and we need to forward this on to the user and what (if anything) they can do to recover from it. In the case of truly empty data we need to communicate to the user that there actually were no results matching their search in the specified radius and that they need to either increase their radius or change their search (here is a great place to make suggestions for other types of restaurants). 

### Alternative Approaches
Before we explore how empty data sets are used to mitigate these issues, we’ll examine other common approaches for relaying empty data situations to users:

1. Simply do nothing. Don’t do nothing. If there is no error but also no data to display, the screen is still blank and the user is unsure if there was an error or just no data to display. This is bad.
2. Error popups. Upon receiving an error some developers will present some sort of “something went wrong” popup to the user with an often obscure, but sometimes helpful, error message. The user will promptly dismiss it and be left with a blank screen and no indication on how to go about actually refetching the data to be displayed. This approach feels intrusive like a popup on your computer. The one situation where I would advocate using this approach is when you already have data and the data fails to refresh or load more, but often you can find a better solution.
3. Using a “Pull to Refresh” control (I.e. `UIRefreshControl`). This type of control is great… when you already are displaying data and you want to load the most recent updates at the top of the screen. This feels very natural when you’re refreshing some feed because it’s hidden above the feed until you pull down. In the absence of data, this is suboptimal because the user has no idea the control is even there.
4. Using a randomly placed button. Another approach is placing a button where it has no business being. A refresh button has no business being in the top right corner of a navigation bar. It looks sloppy and wastes precious screen space on important screens that could be used for useful features. It also kills any possibility of having any sort of app-wide navigation bar consistency such as a hamburger button in the top left and a profile button in the top right.

It is very common for developers to use different combinations of these approaches to handle empty data. Different screens in an application may require different combinations of the above approaches. This inconsistency often results in a poor user experience and a frustrated user. A more unified solution is necessary.

### The Empty Data Set Pattern
The empty data set pattern, also known as empty state or blank state, solves this problem by providing us with a logical place within our view to indicate to a user why there is no data being displayed and how they can go about getting the data that they seek. That logical place is the same place where data would be displayed if it was present.

#### Benefits
There are to tons of benefits to using empty data sets app-wide. We already harped on consistency, but this is something worth mentioning again. You will never have a blank screen in your app and your users will have a persistent indicator of why there is no data to display and the actions they need to take to go about getting data. Consistency improves user experience.
Empty data sets are also particularly useful in the on boarding process. AirBnB does an excellent job with a very simple, yet informative empty data view. Notice it says “What will your _*first*_ adventure be?” and provides the user with a button to start planning their first trip.

<p align="center">
  <img src="https://github.com/imaccallum/DataViewable/blob/master/Docs/images/airbnb.png" width="320">
</p>


One of the areas where AirBnB fails is forcing users to signup as soon as they download the app. Use empty data sets to circumvent forced signup and encourage your users to signup after you have demonstrated value to them. Nothing is more frustrating to a user than when they download an app and as soon as they open it, they are hit with a signup screen and they are unable to explore your app at all until they do so. Many people will delete your app immediately. Rather than conditionally showing screens depending on the authenticated state of a user, you can display those screens all the time but use this space to show the features of your application that are available to users who signup and how users can go about logging in or signing up to access these features. You can do this in a couple of ways. First, you can send them directly to a signup flow with the empty view buttons. Another alternative is to direct them to a flow that will demonstrate even more value to your users and further engage them before asking them to signup.
Empty data sets allow us to avoid intrusive popups to display errors and avoid randomly placed buttons as previously mentioned. They provide a place where designers can really show off their creativity or foster brand awareness. Yelp is a great example of this. They use a cute little graphic, an informative error message, and a refresh action to clearly communicate the lack of internet connection.

<p align="center">
  <img src="https://github.com/imaccallum/DataViewable/blob/master/Docs/images/yelp.png" width="320">
</p>

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

