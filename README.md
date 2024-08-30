
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
    <string>group.branding</string>
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

## App Groups

  1. In the **"Signing & Capabilities"** tab, click **"+"**.
  2. Add **"App Groups"** and configure the identifier **group.branding**.

## Creating a Notification Service Extension in Xcode

 Follow these steps to create a Notification Service Extension in your Xcode project. This extension allows you to modify the content of remote notifications before they are delivered to the user.

   #### 1. Add a New Notification Service Extension Target

   1. Open your Xcode project.
   2. Select the project file in the Navigator pane.
   3. Click on the `+` button at the bottom of the target list to add a new target.
   4. Choose `Notification Service Extension` from the list of available templates.
   5. Click `Next`, give your extension a name (e.g., `MyNotificationServiceExtension`), and click `Finish`.
   6. App Groups in Notification Service Extension
     - 1. In the **"Signing & Capabilities"** tab, click **"+"**.
     - 2. Add **"App Groups"** and configure the identifier **group.branding**.
   
    
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


   ### Step-by-Step Setup for `AppDelegate` in SwiftUI

   1. **Create a new `AppDelegate` Class:**
      - Right-click on your project folder in the Xcode Project Navigator.
      - Select **New File** -> **Swift File**.
      - Name the file `AppDelegate.swift`.

   2. **Define Your `AppDelegate` Class:**
      - Open `AppDelegate.swift` and define the `AppDelegate` class that conforms to `UIApplicationDelegate`. You can also implement any delegate methods you need here.

       ```swift
       import UIKit
       class AppDelegate: NSObject, UIApplicationDelegate {
           func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
               // Perform any necessary setup here
               return true
           }
       }
       ```

   3. **Modify the Main SwiftUI App Struct:**
      - In your `App` struct (typically found in your `AppName.swift` file), use the `@UIApplicationDelegateAdaptor` property wrapper to connect your `AppDelegate` class with your SwiftUI application.

       ```swift
       import SwiftUI

       @main
       struct AppName_SwiftUIApp: App {
           // Connect AppDelegate
           @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
           var body: some Scene {
               WindowGroup {
                   ContentPage() 
               }
           }
       }
       ```

## SDK Initialization

   ## Initialize the SDK in `AppDelegate.swift`:

   ```swift
   import Foundation
   import PushKit
   import SecuredCallsVoiceSDK
   import UIKit

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       do {
            // initialize SDK
           try SecuredCallsVoice.initialize("xxxxxxxSECRETxxxxxxx")
       } catch {
           print("Failed to initialize SecuredCallsVoice SDK: \(error.localizedDescription)")
       }
       return true
   }
   ```

   ## Requesting Permissions
   ### Request Contact Access and Notification Permission

   ```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
       do {
           UNUserNotificationCenter.current().delegate = self
           try SecuredCallsVoice.initialize("xxxxxxxSECRETxxxxxxx")
        
           // Request permissions and login asynchronously
           Task {
               await SecuredCallsVoice.requestNotificationPermissionAsync()
               await SecuredCallsVoice.requestContactAccessAsync()
           }
       } catch {
           print("\(error.localizedDescription)")
       }
       return true
   }
   ```

   ## User Login

   ### UserIdentifier
   **UserIdentifier can be any user identifier if you are only using in-app calls. However, if you have configured both in-app and PSTN calls, the user identifier should be a mobile number.**
   ```swift
   let userIdentifier = "userIdentifier"
   ```
   - ### Login Code
   ```swift
   let userIdentifier = "userIdentifier"

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
       do {
           UNUserNotificationCenter.current().delegate = self
           registerForVoIPPushes()
           try SecuredCallsVoice.initialize("xxxxxxxSECRETxxxxxxx")
        
           Task {
               await SecuredCallsVoice.requestNotificationPermissionAsync()
               await SecuredCallsVoice.requestContactAccessAsync()
               // Request permissions and login asynchronously
               let loginStatus = await SecuredCallsVoice.loginAsync(identifier: userIdentifier)
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
   ```

## APNS and VOIP Token Management

   ### Register Device APNS Token

   ```swift
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let token = deviceToken.hexString
       Task {
               // Retrieve the 'isProduction' flag from UserDefaults to determine the environment
               // 'true' indicates a production environment, while 'false' indicates a sandbox environment
               // This flag should be set by the client based on the current deployment stage
               let isProduction = false
               await SecuredCallsVoice.registerDeviceAsync(customerId: userIdentifier, token: token, isProduction: isProduction)
       }
   }
   ```

   ```swift
	extension Data {
		var hexString: String {
			return map { String(format: "%02.2hhx", $0) }.joined()
		}
	}
```


   ### Register Device VOIP Token And Report Incoming VOIP Push

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
   }
   ```

  ### Report Incoming VOIP Push

   ```swift
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
