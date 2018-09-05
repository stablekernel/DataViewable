## Part 1: What are Empty Data Sets and Why Should I Use Them?
In this two part series we’ll explore the what, when, where, why, and how of empty data sets in mobile applications. In this post we’ll cover everything you need to know about empty data sets with a strong focus on user experience and examples. This post will be pertinent regardless of your role as a stakeholder (I’ll try not to get too technical in this post). In [Part 2: Building an Empty Data Set Framework](part_2.md) we will walk through a Swift implementation of empty data sets for iOS apps so we can reduce boilerplate code. Let’s get started.

### Motivation for Using Empty Data Sets
The vast majority of mobile applications will integrate with some type of database, whether that be local or on a server, then display this data to end users in some fashion. When the database returns non-empty data to display everything is fine and dandy. However, when there is an error retrieving data from the database or when the data is empty (which can be the case when we’re fetching lists of object and none are returned or before we have fetched any data), we run into a situation on how to relay this information to the user. One of the easiest ways to improve user experience in your application is to make sure you correctly handle empty data. This tends to not be a problem for huge companies with vast resources but it is something that is often overlooked in smaller apps. Here's an example of an empty data set in the OpenTable app. The image on the left shows what this screen would look like without an empty data set. The one on the right is the actual OpenTable UI. 

<p align="center">
  <img src="https://github.com/imaccallum/DataViewable/blob/master/Docs/images/open_table_sbs.png" width="642">
</p>

Without empty data sets users are generally just left with a blank screen. We could probably still figure out how to make a reservation by going to the search tab and taking some action but it isn't abundantly clear based on first glance at the screen. With the empty data set we see a UI that shows us exactly how to "Book a table" and the button is in our face and impossible to miss.

### Contexts
We have non-empty data when we have the correct data that we wish to display to the users. We say we have empty data in all other situations. There four main contexts when a user may find themselves with empty data:
1. On-boarding context - a user has yet to take an action.
2. Loading context - a user has taken an action but due to latency we have not yet received data or an error.
3. Error context - a user has taken an action but something went wrong. 
4. Empty context - a user has taken an action and their action was successfully received but there is actually no data to display.

Consider the following application: users search for restaurants nearby and the results are displayed in a table. The user specifies a radius in which to search. If there are restaurants in range matching the search the server will return them. If there are no restaurants in range the server will give us an empty list. In an example as simple as this, there are several contexts where we may have empty data:

1. The user has not entered anything to search we have no results. On screen, there is an empty search bar and an empty table. (On-boarding)
2. A user types something and before the server gives us a response we show a loading indicator. (Loading)
3. We receive an error. Something went wrong with the connection or the server responded with an error. We have no data to display. (Error)
4. A user searches and receives a successful response but no restaurants matching their search were found within the radius specified. (Empty)

In each situation there are differences in how we got to the point of having empty data and what the user needs to do to recover. In the first situation the user is new to the page and needs to search for something. We need to let the user know that searching for something is the action they need to take. In the second situation the user has searched for something but  the user searched for something and something went wrong. We have an error message and we need to forward this on to the user and what (if anything) they can do to recover from it. In the case of truly empty data we need to communicate to the user that there actually were no results matching their search in the specified radius and that they need to either increase their radius or change their search (here is a great place to make suggestions for other types of restaurants). 

### Alternative Approaches
Before we explore how empty data sets are used to mitigate these issues, we’ll examine other common approaches for relaying empty data situations to users:

1. Simply do nothing. If there is no error but also no data to display, the screen is still blank and the user is unsure if there was an error or just no data to display. This is bad.
2. Error popups. Upon receiving an error some developers will present some sort of “something went wrong” popup to the user with an often obscure, but sometimes helpful, error message. The user will promptly dismiss it and be left with a blank screen and no indication on how to go about actually refetching the data to be displayed. This approach feels intrusive like a popup on your computer. The one situation where I may advocate using this approach is when you already have data and the data fails to refresh or load more, but often you use a less intrusive mechanism such as a banner.
3. Using a “Pull to Refresh” control (I.e. `UIRefreshControl`). This type of control is great… when you already are displaying data and you want to load the most recent updates at the top of the screen. This feels very natural when you’re refreshing some feed because it’s hidden above the feed until you pull down. In the absence of data, this is suboptimal because the user has no idea the control is even there. A refresh control is not a "load data" control, but rather a "load the most recent updates to my data" control.
4. Using a randomly placed button. Another approach is placing a button where it has no business being. A refresh button has no business being in the top right corner of a navigation bar. It looks sloppy and wastes precious screen space on important screens that could be used for useful features. It also kills any possibility of having any sort of app-wide navigation bar consistency such as a hamburger button in the top left and a profile button in the top right.

It is very common for developers to use different combinations of these approaches to handle empty data. Different screens in an application may utilize different combinations of the above approaches. This inconsistency often results in a poor user experience and a frustrated user. A more unified solution is necessary.

### The Empty Data Set Pattern
The empty data set pattern, also known as empty state or blank state, solves this problem by providing us with a logical place within our view to indicate to a user why there is no data being displayed and how they can go about getting the data they seek. That logical place is the same place where data would be displayed if it was present.

#### Benefits
There are to tons of benefits to using empty data sets app-wide. We already harped on consistency, but this is something worth mentioning again. You will never have a blank screen in your app and your users will have a persistent indicator of why there is no data to display and the actions they need to take to go about getting data. Consistency improves user experience.
Empty data sets are also particularly useful in the on boarding process. AirBnB does an excellent job with a very simple, yet informative empty data view. Notice it says “What will your _*first*_ adventure be?” and provides the user with a button to start planning their first trip.

<p align="center">
  <img src="https://github.com/imaccallum/DataViewable/blob/master/Docs/images/airbnb.png" width="320">
</p>


One of the areas where AirBnB fails is forcing users to signup as soon as they download the app. As soon as users open the app for the first time they are hit with a signup screen and they are unable to explore the app at all until they do so. This is one of the more frustrating things a user may experience and many people will delete your app immediately. Don't take it from me, take it from [Apple WWDC 2017: Love at First Launch](https://developer.apple.com/videos/play/wwdc2017/816/). Use empty data sets to circumvent forced signup and encourage your users to signup after you have demonstrated some value to them. Rather than conditionally showing screens depending on the authenticated state of a user, you can display those screens all the time but use this space to show the features of your application that are available to users who signup and how users can go about logging in or signing up to access these features. You can do this in a couple of ways. First, you can send them directly to a signup flow with the empty view buttons which is how OpenTable handles unauthenticated users for the "Profile" and "Reservations" tabs. 

<p align="center">
  <img src="https://github.com/imaccallum/DataViewable/blob/master/Docs/images/open_table_auth.png" width="320">
</p>

Another alternative is to direct them to a flow that will demonstrate even more value to your users and further engage them before asking them to signup.

Empty data sets allow us to avoid intrusive popups to display errors and avoid randomly placed buttons as previously mentioned. They provide a place where designers can really show off their creativity or foster brand awareness. Yelp is a great example of this. They use a cute little graphic, an informative error message, and a refresh action to clearly communicate the lack of internet connection.

<p align="center">
  <img src="https://github.com/imaccallum/DataViewable/blob/master/Docs/images/yelp.png" width="320">
</p>

From this, you know exactly what has gone wrong and what you need to do to recover. Even if you leave the screen and come back you still have this information.

### Getting Started

Empty data sets are more work. This is one of several reasons why empty data sets are often not implemented in mobile apps. It's helpful to pinpoint key areas where important data is displayed and implement helpful text descriptions and action buttons to get started. You don't have to go overboard making custom graphics for every single place you have data.

### Moving Forward

In [Part 2: Building an Empty Data Set Framework](part_2.md), we will try to reduce the amount of code it takes to implement empty data sets and loading indicators to the point where this is no longer an issue. There are several other popular empty data set frameworks, but they do not handle loading indicators so additional logic is necessary to handle this. Additionally, they tend to be less extensible than we would like, supporting only UITableView and UICollectionView. Our implementation will provide first class support for loading indicators and it will be extensible to the point where it can be applied to any type, not just any view type. Stay tuned for [Part 2](part_2.md)!

