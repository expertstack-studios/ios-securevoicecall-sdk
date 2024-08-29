
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

### Creating a Notification Service Extension in Xcode

Follow these steps to create a Notification Service Extension in your Xcode project. This extension allows you to modify the content of remote notifications before they are delivered to the user.

#### 1. Add a New Notification Service Extension Target

1. Open your Xcode project.
2. Select the project file in the Navigator pane.
3. Click on the `+` button at the bottom of the target list to add a new target.
4. Choose `Notification Service Extension` from the list of available templates.
5. Click `Next`, give your extension a name (e.g., `MyNotificationServiceExtension`), and click `Finish`.

#### 2. Implement the Notification Service Extension Logic

1. Open the `NotificationService.swift` file in the newly created extension folder.
2. Modify the `didReceive` method to customize the notification's content.

```swift
import SecuredCallsVoiceSDK
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
	override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
		Task {
			await SecuredCallsVoice.processNotificationAsync(request: request, withContentHandler: contentHandler)
		}
	}

	override func serviceExtensionTimeWillExpire() {}
}
```

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

### Appdelegate

```swift
class AppDelegate: NSObject, UIApplicationDelegate {
	let userIdentifier = "919930848454"

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		do {
			registerForVoIPPushes()
			try SecuredCallsVoice.initialize("xxxxSecretxxxxx")
			Task {
				await SecuredCallsVoice.requestNotificationPermissionAsync()
				await SecuredCallsVoice.requestContactAccessAsync()
				let securedCallsVoiceHasLoggedIn = await SecuredCallsVoice.loginAsync(identifier: userIdentifier)
			}
		} catch {
			print("\(error.localizedDescription)")
		}
		return true
	}

	private func registerForVoIPPushes() {
		let voipRegistry = PKPushRegistry(queue: nil)
		voipRegistry.delegate = self
		voipRegistry.desiredPushTypes = [.voIP]
	}
}
```


### UNNotificationServiceExtension

```swift
import UserNotifications
import SecuredCallsVoiceSDK

class NotificationService: UNNotificationServiceExtension {
	
	override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
		Task{
			await SecuredCallsVoice.processNotificationAsync(request: request, withContentHandler: contentHandler)
		}
	}
	
	override func serviceExtensionTimeWillExpire() {
	}
	
}
```

### Appdelegate extension PKPushRegistryDelegate

```swift
extension AppDelegate: PKPushRegistryDelegate {
	func pushRegistry(
		_ registry: PKPushRegistry,
		didUpdate pushCredentials: PKPushCredentials,
		for type: PKPushType
	) {
		if type == PKPushType.voIP {
			Task {
				await SecuredCallsVoice.registerVoipTokenAsync(
					token: pushCredentials.token
				)
			}
		}
	}

	func pushRegistry(
		_ registry: PKPushRegistry,
		didReceiveIncomingPushWith payload: PKPushPayload,
		for type: PKPushType,
		completion: @escaping () -> Void
	) {
		switch type {
		case .voIP:
			SecuredCallsVoice.reportNewInComingCall(payload: payload)
		default:
			return
		}
		completion()
	}
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
