
# SecuredCalls Voice SDK Integration Guide

## Prerequisites

Ensure you have the following for using the SecuredCalls Voice SDK for iOS:

- Mac OS with developer mode enabled
- Xcode 11.0 or above
- At least one physical iOS device running iOS 16.4 or later
- Swift 5.0 or later
-    **Register on SecuredCalls.com** and obtain the `config.dat` file and secret

## Adding the SDK to Your Project

### Swift Package Manager

1. Open your project in Xcode.
2. Go to **File** > **Swift Packages** > **Add Package Dependency...**.
3. Enter the repository URL: https://github.com/expertstack-studios/ios-securevoicecall-sdk
4. Select the latest version and click **Next**.
5. Choose the packages required and click **Finish**.

## Configuring `Info.plist`

Add the following keys to your `Info.plist` file:

### Privacy Keys

- **Microphone Usage Description**  
    ```xml
    <key>NSMicrophoneUsageDescription</key>
    <string>Explain why microphone access is needed.</string>
    ```

- **User Notifications Usage Description**  
    ```xml
    <key>NSUserNotificationsUsageDescription</key>
    <string>Explain why notifications are necessary.</string>
    ```

- **Contacts Usage Description**  
    ```xml
    <key>NSContactsUsageDescription</key>
    <string>Explain why access to contacts is needed.</string>
    ```

### Environment Configuration

- **SC_APP_GROUP**  
    ```xml
    <key>SC_APP_GROUP</key>
    <string>group.your.app.identifier</string>
    ```

## Enabling Capabilities in Xcode

### Background Modes

1. Go to your Xcode project target.
2. Select the **"Signing & Capabilities"** tab.
3. Click **"+"** and add **"Background Modes"**.
4. Check relevant options:
   - **Audio, AirPlay, and Picture in Picture**
   - **Voice over IP**
   - **Background fetch**
   - **Remote notifications**

### Push Notifications

1. In the **"Signing & Capabilities"** tab, click **"+"**.
2. Add **"Push Notifications"**.

### App Groups

1. In the **"Signing & Capabilities"** tab, click **"+"**.
2. Add **"App Groups"** and configure the identifier.

## SDK Initialization

Initialize the SDK in `AppDelegate.swift`:

```swift
import SecuredCallsVoiceSDK

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    do {
        try SecuredCallsVoice.initialize("xxxxxxxSECRETxxxxxxx")
    } catch {
        print("Failed to initialize SecuredCallsVoice SDK: \(error.localizedDescription)")
    }
    return true
}
```
## Requesting Permissions

### Request Contact Access


```swift
import SecuredCallsVoiceSDK

func requestContactAccess() async {
    await SecuredCallsVoice.requestContactAccessAsync()
}
``` 

### Request Notification Permission

```swift

import SecuredCallsVoiceSDK

func requestNotificationPermission() async {
    await SecuredCallsVoice.requestNotificationPermissionAsync()
} 
```

## User Login

### Login Code

```swift

import SecuredCallsVoiceSDK

func loginUser(userIdentifier: String) async {
    let success = await SecuredCallsVoice.loginAsync(identifier: userIdentifier)
    print("SecuredCallsVoice login status = \(success)")
} 
```

## APNS and VOIP Token Management

### Register Device APNS Token

```swift

import SecuredCallsVoiceSDK

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.hexString
    Task {
        if let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") {
            // Retrieve the 'isProduction' flag from UserDefaults to determine the environment
            // 'true' indicates a production environment, while 'false' indicates a sandbox environment
            // This flag should be set by the client based on the current deployment stage
            let isProduction = UserDefaults.standard.bool(forKey: "isProduction")
            await SecuredCallsVoice.registerDeviceAsync(customerId: userIdentifier, token: token, isProduction: isProduction)
        } else {
            print("\(#function) user not registered")
        }
    }
}
```

### Register Device VOIP Token

```swift

import SecuredCallsVoiceSDK
import PushKit

func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    if type == .voIP {
        Task {
            await SecuredCallsVoice.registerVoipTokenAsync(token: pushCredentials.token)
        }
    }
}
```

### Report Incoming VOIP Push

```swift

import SecuredCallsVoiceSDK
import PushKit

func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
    if type == .voIP {
        SecuredCallsVoice.reportNewInComingCall(payload: payload)
    }
    completion()
}
``` 

## Notes

-   **API Key**: Replace `"xxxxxxxSECRETxxxxxxx"` with your actual API key.

By following these steps, you’ll integrate the SecuredCalls Voice SDK effectively, meeting user privacy expectations and handling notifications efficiently.

## Implementation Time Estimates Breakdown

| **Task**                            | **Description**                                                                 | **Estimated Time** |
|-------------------------------------|---------------------------------------------------------------------------------|--------------------|
| **1. Adding the SDK to Your Project** | Using Swift Package Manager to add the SDK to your Xcode project.                 | 2 minutes          |
| **2. Configuring `Info.plist`**       | Adding necessary privacy keys and environment configuration.                     | 2 minutes          |
| **3. Enabling Capabilities in Xcode** | Configuring Background Modes, Push Notifications, and App Groups.                | 2 minutes          |
| **4. SDK Initialization**             | Initializing the SDK in `AppDelegate.swift` with the provided API key.            | 2 minutes          |
| **5. Requesting Permissions**         | Implementing methods for requesting contact and notification permissions.         | 2 minutes          |
| **6. User Login**                    | Implementing user login functionality.                                            | 5 minutes          |
| **7. APNS and VOIP Token Management** | Handling APNS and VOIP token registration and reporting incoming VOIP pushes.      | 5 minutes          |
| **8. Handling Notifications** | Managing push notifications and VOIP token updates. | 5 minutes | 
| **9. Reporting Incoming Calls** | Reporting incoming VOIP calls to the SDK. | 5 minutes |


**Total Estimated Time: 30 minutes**
