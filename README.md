

# SecuredCalls Voice SDK Integration Guide

## Prerequisites

Ensure you have the following for using the SecuredCalls Voice SDK for iOS:

- Mac OS with developer mode enabled
- Xcode 11.0 or above
- At least one physical iOS device running iOS 16 or later
- Swift 5.0 or later
-    **Register on SecuredCalls.com** and obtain the `config.dat` file and secret

## Adding the SDK to Your Project

### Swift Package Manager

1. Open your project in Xcode.
2. Go to **File** > **Swift Packages** > **Add Package Dependency...**.
3. Enter the repository URL:  
   `https://github.com/expertstack-studios/ios-securevoicecall-sdk`
4. When prompted for the version, select **Exact** and enter **1.0.21**, then click **Next**.
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

- **Location Usage Description**  
    ```xml
    <key>Privacy - Location When In Use Usage Description</key>
    <string>Explain why access to location is needed.</string>
    <key>Privacy - Location Always and When In Use Usage Description</key>
    <string>Explain why access to location is needed.</string>
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
  2. Add **"App Groups"** and configure the identifier **group.com.your.app**.

## Creating a Notification Service Extension in Xcode

 Follow these steps to create a Notification Service Extension in your Xcode project. This extension allows you to modify the content of remote notifications before they are delivered to the user.

   #### 1. Add a New Notification Service Extension Target

   1. Open your Xcode project.
   2. Select the project file in the Navigator pane.
   3. Click on the `+` button at the bottom of the target list to add a new target.
   4. Choose `Notification Service Extension` from the list of available templates.
   5. Click `Next`, give your extension a name (e.g., `MyNotificationServiceExtension`), and click `Finish`.
   6. Add the required framework:
      - Select the main Notification Service Extension target in the Targets section.
      - Navigate to the General tab.
      - Scroll down to the Frameworks, Libraries, and Embedded Content section.
      - Click on the + button.
      - Search for and select the SecuredCallsVoiceSDK.framework you need 
      - Click Add to include the framework in your project.
   7. App Groups in Notification Service Extension
      - In the **"Signing & Capabilities"** tab, click **"+"**.
      - Add **"App Groups"** and configure the identifier **group.com.your.app**.
      
    
   #### 2. Implement the Notification Service Extension Logic

   1. Open the `NotificationService.swift` file in the newly created extension folder.
   2. Modify the `didReceive` method to customize the notification's content.

   ```swift
   import SecuredCallsVoiceSDK
   import UserNotifications

   class NotificationService: UNNotificationServiceExtension {
	override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
		Task {
			await SecuredCallsVoice.processNotificationAsync(
                    request: request,
                    // ✅ The incoming UNNotificationRequest received by
                    // the Notification Service / Notification Extension.
                    
                    appGroupID: "group.com.your.app",
                    // ✅ App Group Identifier used for sharing data between
                    // the Main App and the Notification Extension.
                    // ⚠️ IMPORTANT: This MUST be the SAME App Group ID
                    // that was passed during `SecuredCallsVoice.initialize(...)`.
                    
                    withContentHandler: contentHandler
                    // ✅ Completion handler used to return the modified
                    // notification content to the system after SDK processing.
                )
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
   ```
   ```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       do {
       
			// MARK: - Optional Typography Customization
			//
			// The Typography object allows you to customize fonts used across
			// different UI surfaces of the SecuredCalls SDK.
			//
			// ⚠️ IMPORTANT:
			// • ALL typography fields are OPTIONAL
			// • If Typography is not provided, or if any font is nil,
			//   the SDK will automatically fall back to its DEFAULT system fonts
			// • Font customization is purely visual and does NOT affect SDK behavior
			//

			var typography = Typography(
				
				displayName: UIFont(name: "AvenirNextLTPro-Demi", size: 36),
				// Optional
				// Used for: large display titles, marquee-style text
				
				timer: UIFont(name: "AvenirNext-Medium", size: 32)?.withMonospacedDigits(),
				// Optional
				// Used for: Call duration timer
				// Recommended to use monospaced digits for stable timer rendering
				
				callStatus: UIFont(name: "AvenirNext-Regular", size: 20),
				// Optional
				// Used for: Call status labels such as
				// "Incoming Call", "Connecting", "Dialing"
				
				poweredBy: UIFont(name: "AvenirNext-Medium", size: 18),
				// Optional
				// Used for: "Powered by" branding text
				
				callIntentTitle: UIFont(name: "AvenirNext-DemiBold", size: 16),
				// Optional
				// Used for: Call intent title text in in-app call UI
				
				callIntentBody: UIFont(name: "AvenirNext-DemiBold", size: 24),
				// Optional
				// Used for: Call intent body / primary message text
				
				buttonTitle: UIFont(name: "AvenirNext-DemiBold", size: 14),
				// Optional
				// Used for: Button titles across SDK UI
				
				callkitCallIntentTitle: UIFont(name: "AvenirNext-Regular", size: 8),
				// Optional
				// Used for: Call intent title shown on the iOS CallKit screen
				// Smaller font size recommended due to CallKit layout constraints
				
				callkitCallIntentBody: UIFont(name: "AvenirNext-DemiBold", size: 16),
				// Optional
				// Used for: Call intent body text on the CallKit screen
				
				pipDisplayName: UIFont(name: "AvenirNext-DemiBold", size: 24),
				// Optional
				// Used for: Display name shown in Picture-in-Picture (PiP) mode
				
				keypadButtonTitle: UIFont(name: "AvenirNext-DemiBold", size: 24)
				// Optional
				// Used for: Dial pad / keypad button text
			)
            // initialize SDK
			try SecuredCallsVoice.initialize(
                    "xxxxxxxSECRETxxxxxxx", 
                    // ✅ SecuredCalls client secret provided by the SecuredCalls team
                    
                    configFileName: "ConfigFileName", 
                    // ✅ Name of the configuration file (without extension) used by the SDK
                    
                    settings: ScSDKSettingsModel(
                        handlePermission: true,
                        // ✅ When true, the SDK will automatically check and request
                        // required permissions via system popups if not already granted.
                        
                        showPipView: true,
                        // ✅ When true, enables Picture-in-Picture (PiP) mode,
                        // allowing the user to continue using the app during an ongoing call.
                        
                        logLevel: .Debug,
                        // ✅ Controls SDK logging level:
                        // case Error = 0
                        // case Warning = 1
                        // case Debug = 2
                        // case Information = 3
                        // case Off = -1 (Default)
                        
                        scCallKitIconName: "AppIcon-Mono",
                        // ✅ Mono-color image name used on the CallKit screen.
                        // ⚠️ The image MUST be a monochrome asset for proper display.
                        
                        typography: typography
						// Optional
						// If not provided, SDK uses default typography
                    ),
                    
                    appGroupID: "group.com.your.app"
                    // ✅ App Group Identifier used for data sharing between
                    // the Main App and the Notification Extension.
                    // ⚠️ IMPORTANT: The SAME App Group ID must be used in BOTH
                    // the main app and the notification extension.
                )
            )
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
			try SecuredCallsVoice.initialize(
				"xxxxxxxSECRETxxxxxxx",
				configFileName: "ConfigFileName",
				settings: ScSDKSettingsModel(
					handlePermission: true,
					showPipView: true,
					logLevel: .Debug,
					scCallKitIconName: "AppIcon-Mono"
				),
                appGroupID: "group.com.your.app"
            )
        
           // Request permissions and login asynchronously
           Task {
               await SecuredCallsVoice.requestNotificationPermissionAsync()
               await SecuredCallsVoice.requestContactAccessAsync()
               await SecuredCallsVoice.requestLocationPermissionAsync()
           }
       } catch {
           print("\(error.localizedDescription)")
       }
       return true
   }
   ```

   ## UserIdentifier
   **UserIdentifier can be any user identifier if you are only using in-app calls. However, if you have configured both in-app and PSTN calls, the user identifier should be a mobile number.**
   ```swift
   let userIdentifier = "userIdentifier"
   ```
   ## Consumer Registration Code
   **Use the registerConsumerAsync(customerId:) method to register the user once per app installation.**
   ```swift
   let consumerRegistrationResult = await SecuredCallsVoice.registerConsumerAsync(customerId: userIdentifier)
   let key = "isConsumerRegistered"
        // Check if already registered
        let alreadyRegistered = UserDefaults.standard.bool(forKey: key)
        guard !alreadyRegistered else {
            print("🔁 Already registered")
            return
        }

        // Register consumer
        do {
            let result = try await SecuredCallsVoice.registerConsumerAsync(customerId: userIdentifier)
            switch result {
				case .success(let result):
					logger.info("success")
				case .failure(let error):
					logger.info("failure : \(error.localizedDescription)")
			}
            UserDefaults.standard.set(true, forKey: key)
        } catch {
            print("\(error.localizedDescription)")
        }

   ```
   ## User Login
   - ### Login Code
   ```swift
   let userIdentifier = "userIdentifier"

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
       do {
			UNUserNotificationCenter.current().delegate = self
			registerForVoIPPushes()
			try SecuredCallsVoice.initialize(
				"xxxxxxxSECRETxxxxxxx",
				configFileName: "ConfigFileName",
				settings: ScSDKSettingsModel(
					handlePermission: true,
					showPipView: true,
					logLevel: .Debug,
					scCallKitIconName: "AppIcon-Mono"
				),
                appGroupID: "group.com.your.app"
            )
        
           Task {
               await SecuredCallsVoice.requestNotificationPermissionAsync()
               await SecuredCallsVoice.requestContactAccessAsync()
               await SecuredCallsVoice.requestLocationPermissionAsync()
               // Request permissions and login asynchronously
               let loginResult = await SecuredCallsVoice.loginAsync(identifier: userIdentifier)
               switch loginResult {
				    case .success(let result):
				    	logger.info("success")
				    case .failure(let error):
				    	logger.info("failure : \(error.localizedDescription)")
			    }
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
		let isProduction = false
		if type == PKPushType.voIP {
			Task {
				await SecuredCallsVoice.registerVoipTokenAsync(
					token: pushCredentials.token,
					isProduction: isProduction
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
  
  ### Make Outbound callback to Customer care

   ```swift
   Task {
		do {
			try await SecuredCallsVoice.startCallAsync(number: "61450000001", callType: .inApp)
		} catch {
			print("Error: \(error)")
		}
	}
  ```
### Logout User Session

```swift
	Task {
		if let userIdentifier = UserDefaults.standard.string(forKey: "userIdentifier") {
			do {
				try await SecuredCallsVoice.logoutAsync(identifier: userIdentifier)
			} catch {
				print("Logout failed: \(error)")
			}
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
