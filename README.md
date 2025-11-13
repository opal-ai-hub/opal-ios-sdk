# OPAL

OPAL is a customer engagement platform that helps brands build impactful, one-to-one customer relationships on mobile and web. OPAL combines behavioral analytics and personalized messaging to help marketing and growth teams improve their engagement, retention, and monetization efforts.

# OPAL iOS SDK Integration Guide

## Requirements
- The minimum Deployment Target of the SDK is **iOS 13.0**.
- Enable **Background Fetch** and **Remote Notifications** under **Background Modes**.

## Integration

OPAL iOS SDK is distributed as a Swift Universal Fat Framework, and can be installed via the Swift Package Manager.

1. In Xcode, navigate to File > Add Package Dependencies
2. In the “Search or Enter Package URL” search box enter: `https://github.com/opal-ai-hub/opal-ios-sdk`
3. Select the appropriate version and click Add Package

## SDK Initialization

### 1. Import the framework

```swift
import UserNotifications
import OpalSDK
```

### 2. Start the SDK

In `application:didFinishLaunchingWithOptions:`, start the SDK:

```swift
do {
    try Opal.manager.start(withConfigurationFile: "your_config_filename_without_extension")
} catch {
    // Handle error
}
```

> [!NOTE]
> For more information on locating the required OPAL configuration file in the OPAL CMS, check the [Applications](https://docs.opal.ai/user-guide/getting-started/setup-applications) section.

> [!WARNING]
> Always call all SDK methods **after** `start(withConfigurationFile:)` has been invoked.

## Users

A `User` uniquely identifies the app user, enabling targeted push messaging, analytics collection, etc.

`Users` may engage with your brand through different channels, such as mobile apps and websites.
For more information about `Users` in the OPAL platform check [this](https://docs.opal.ai/user-guide/getting-started/named-users).

### Login User

To log in a user to OPAL:

```swift
Opal.manager.loginUser("MyUser") { error in
    if let error {
        // Handle the error
    }
}
```

> [!WARNING]
> Named user identifiers **MUST NOT** contain personally identifiable information (PII) such as usernames, emails, or phone numbers. Failure to comply may result in account suspension.
> Additionally, identifiers **MUST** be unique and permanent for each individual.

### Logout User

To log out a user from OPAL:

```swift
Opal.manager.logoutUser()
```

### Default User

The **Default User** is a unique anonymous user identifier created during the initialization of the SDK.

To retrieve the default user identifier:

```swift
let defaultUser = Opal.manager.defaultUser
```

## Push Notifications

Push Messaging in the OPAL iOS SDK allows your app to deliver timely notifications and updates directly to user's devices. With support for rich media, deep links, and interactive actions, push messages can engage users, drive app usage, and deliver personalized content.

### Register for Push Notifications

```swift
Opal.manager.registerForPushNotifications()
```

>[!NOTE]
>Starting with OPAL v3.2, you can automatically register for provisional notifications:

```swift
Opal.manager.registerForPushNotifications(preferProvisional: true)
```

### Handle APNS Device Token

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Opal.manager.handleDeviceToken(deviceToken)
}
```

## Notification Handling

### Handle Remote Notifications (Foreground)

### Automatically

You can can let OPAL handle all incoming remote notifications by forwarding them to the SDK:

```swift
// Inside your `application:didFinishLaunchingWithOptions:`
Opal.manager.makeUserNotificationCenterDelegate()
```

### Manually
  
If you want to handle notifications yourself, forward them to the SDK like this:

```swift
// Inside your `application:didFinishLaunchingWithOptions:`
UNUserNotificationCenter.current().delegate = self
```

Then implement the delegate methods:

```swift
// Conform to UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    /// Handle notification actions (the user tapped on a notification).
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Opal.manager.handleRemoteNotificationResponse(response, completionHandler: completionHandler)
    }
    
    /// Handle notifications that arrived while the app is in the foreground.
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.list, .banner, .sound, .badge])
        } else {
            completionHandler([.sound, .badge])
        }
    }

}
```

### Handle APNS Token & Remote Notifications (Background)

```swift
extension AppDelegate {

    /// Handle the device's APNS token.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Opal.manager.handleDeviceToken(deviceToken)
    }
    
    /// Handle incoming remote notifications (background).
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Opal.manager.handleRemoteNotification(userInfo, completionHandler: completionHandler)
    }

}
```

## Inbox

The Inbox functionality provides a centralized message center where users can view and interact with messages delivered through the OPAL CMS.
These messages can include rich media content, as well as interactive elements like external urls or deep links that direct users to specific screens or actions within your app.
The Inbox automatically synchronizes message updates, ensuring users always see the latest content.

### Retrieve Messages

To fetch Inbox messages:

```swift
Opal.manager.fetchInbox { (messages, error) in
    // Access the messages (InboxMessage instances)
    // Handle errors
}
```

>[!TIP]
> Remember to dispatch UI updates on the main queue when handling the above callbacks.

### Present Message

To present a specific Inbox item:

```swift
do {
    try Opal.manager.presentInboxItem(item)
} catch {
    // Handle error
}
```

### Delete Message

To delete a specific Inbox message:

```swift
do {
    try Opal.manager.deleteInboxMessage(message)
} catch {
    // Handle error
}
```

### Retrieve Unread Message Count

To retrieve the unread message count:

```swift
Opal.manager.numberOfUnreadMessages { count in
    // Update unread counter
}
```

## Places 

The OPAL Places feature allows your app to deliver personalized, location-aware experiences by detecting when users enter or leave specific geographic areas. By leveraging geofencing technology, it enables you to trigger real-time push messages  based on user proximity to predefined locations such as stores, venues, or points of interest.

### Change Places Messaging Status

To enable OPAL Places Messaging:

#### Enable
```swift
do {
    try Opal.manager.enablePlaces()
} catch {
    // Handle the error
}
```

To disable OPAL Places Messaging:

#### Disable
```swift
do {
    try Opal.manager.disablePlaces()
} catch {
    // Handle the error
}
```

>[!NOTE]
>The above methods can be safely called multiple times.

## Analytics

The OPAL Analytics feature allows you to track user activity and engagement within your app in real time. It enables developers to log screens, custom events, and additional metadata to better understand how users interact with specific features and content. These insights can be used to improve app performance, user experience, and the effectiveness of campaigns or in-app actions.


## Screens

The Screens feature in OPAL Analytics lets you track which parts of your app users visit. Each screen event helps you understand navigation patterns and user behavior, providing valuable insights into how users move through your app and interact with its content.

To log a screen:

### Manually

```swift
let screen = "the name of the screen"
let extra = [<your-key> : <your-value>] // See notes below

do {
    try Opal.manager.logScreenWithName(screen, data: extra)
} catch {
    // Handle the error
}
```

### SwiftUI

If you are using SwiftUI, you can log screens automatically by using the `.logScreenWithName` modifier:
```swift 
// You can use `onLoad` or `onAppear` modes
// You can also (optionally) pass extra data as a dictionary
myView
   .logScreenWithName("screenName", mode: .noLoad, data: ["key": "value"])
```

>[!TIP]
>If the screen name is formatted like a domain (e.g. `account.profile.status`) where the screen name is the last component, each of the previous components are automatically registered as 'screen groups' for the particular screen.

>[!WARNING]
>Please mind the following:
>- Parameter **screen** SHOULD contain only **characters**, **numbers** and **dots** (.).
>- Length of the screen name and screen groups **should be up to 50**.
>- If the value of a key of the data dictionary is **null**, the key will be omitted.
>- Allowed values for the data dictionary are:
>  - **String**
>  - **Number**
>  - **Date**
>  - **Boolean**


### Custom Events

The Custom Events feature in OPAL Analytics lets you track specific user actions and interactions within your app, such as button clicks, form submissions, or purchases.

Each event can include a category, an action, and additional metadata, helping you measure engagement, understand user behavior, and optimize in-app experiences.

To log an event:

```swift
let category = "the event category"
let action = "the event action"
let extra = [<your-key> : <your-value>] // See notes below

do {
    try Opal.manager.logEventWith(category: category, action: action, data: extra)
} catch {
    // Handle the error
}
```

>[!WARNING]
>Please mind the following:
>- Parameter **category** SHOULD contain only **characters** and **numbers**.
>- Length of the event category **should be up to 50**.
>- Parameter **action** SHOULD contain only **characters** and **numbers**.
>- Length of the event action **should be up to 50**.
>- If the value of a key of the data dictionary is **null**, the key will be omitted.
>- Acceptable values for the data dictionary are:
>  **String**
>  **Number**
>  **Date**
>  **Boolean**

## Preferences

The OPAL Preferences feature allows you to define and manage user interests or behavioral tags, enabling better audience segmentation and personalized targeting.

By assigning preferences, you can deliver campaigns that are more relevant to each user, improving engagement, retention, and overall campaign performance.

To register user preferences:

```swift
do {
    try Opal.manager.registerPreferences(["Tag 1", "Tag 2"])
} catch {
    // Handle the error
}
```

## Deep-Links

OPAL SDK supports deep linking through push notification payloads, Rich Page actions, and Inbox messages.

### Configuration

1. Register your OPAL URL scheme in your app’s **Info.plist** under **URL Types**.
2. Implement the URL handler in your `AppDelegate`:

```swift
func application(_ app: UIApplication,
              open url: URL,
               options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    // Handle the URL here
    return true
}
```

>[!NOTE]
>By default, campaigns with deep link actions are automatically closed by OPAL after the action executes. To disable this, set:

```swift
Opal.manager.deeplinkDismissesCampaigns = false;
```

>[!WARNING]
>If you disable automatic dismissal, you **MUST** manually close campaigns via:
>
>```swift
>Opal.manager.closeCampaignIfVisible(animated: true)
>```
>
>This method is safe to call even when no campaign is visible.

## Appendix

### OPAL Error Handling

OPAL reports errors by using Swift's error handling mechanisms. All errors are automatically bridged to ObjC and handled as NSErrors by following the conventions of the language.

* `serviceUnavailable` (The service is temporarily unavailable, e.g. unavailable due to network conditions, maintenance, etc.)
* `featureNotEnabled` (The feature you are trying to use is not enabled in your account)
* `maxTagsReached(supplied: Int, max: Int)` (You have exceeded the max number of tags. The error reports both the supplied and the max counts)
* `maxTagLengthReached(supplied: String)` (You have exceeded the max length for a tag. The error reports the failing tag)
* `invalidScreenName(supplied: String)` (The screen name is invalid. The error reports the failing screen name)
* `invalidExtraKey(supplied: String)` (The extra key is invalid. The error reports the failing extra key)
* `emptyExtraKey(supplied: String)` (The extra key is empty. The error reports the failing extra key)
* `invalidExtraValue(key: String)` (The extra value is invalid. The error reports the failing value)
* `invalidCategory(supplied: String)` (The category is invalid. The error reports the failing category)
* `invalidAction(supplied: String)` (The action is invalid. The error reports the failing action)
* `invalidExtraData` (The extra data is invalid)
* `invalidConfigurationFile` (The configuration file is invalid)
* `invalidConfigurationArguments` (The entries in the configuration file are invalid)
* `undefinedMode` (The mode in the configuration file is undefined)
* `invalidAppKey` (The application key in the configuration file is invalid)
* `invalidAppSecret` (The application secret in the configuration file is invalid)
* `invalidEnvironment` (The application environment in the configuration file is invalid)
* `invalidPlaceData` (The active places data are invalid)

All OPAL errors implement `localizedDescription` in order to provide meaningful debug messages.

## Questions

If you have questions, please contact [hello@opal.ai](mailto:hello@opal.ai) or your assigned technical contact.

## License

This SDK is proprietary software provided by TREBBBLE for use only with OPAL.  
Use of this SDK is governed by the terms described in [LICENSE.txt](./LICENSE.txt).  
You must have a valid subscription to OPAL to use this SDK in your application.

TREBBBLE is a trade name of TREBBBLE S.A., the provider of this SDK and related services.
