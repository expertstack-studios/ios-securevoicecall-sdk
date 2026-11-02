

# SecuredCalls Voice SDK Integration Guide

## Prerequisites

Ensure you have the following for using the SecuredCalls Voice SDK for iOS:

- Mac OS with developer mode enabled
- Xcode 11.0 or above
- At least one physical iOS device running iOS 16 or later
- Swift 5.0 or later
-    **Register on SecuredCalls.com** and obtain the `config.dat` file. Its `authMode`
     (`CUSTOMER_IDP` or `BFF`) decides how your app supplies credentials — see
     [Authentication](#authentication). The SDK no longer accepts a client secret.

## Adding the SDK to Your Project

### Swift Package Manager

1. Open your project in Xcode.
2. Go to **File** > **Swift Packages** > **Add Package Dependency...**.
3. Enter the repository URL:  
   `https://github.com/expertstack-studios/ios-securevoicecall-sdk`
4. When prompted for the version, select **Up to Next Major Version** and enter **1.0.30 < 2.0.0**, then click **Next**.
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

- **Face ID Usage Description**
    ```xml
    <key>NSFaceIDUsageDescription</key>
    <string>Explain why biometric authentication is needed.</string>
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

## Keychain Sharing (Required)

The SDK's storage is Keychain-only — it keeps no state in `UserDefaults` (aside from
a few internal flags — install detection and registration state — kept in the App
Group's `UserDefaults` so they reset on uninstall). Because your main app and its Notification Service Extension are separate
processes, they need a shared Keychain access group to see the same items — without
it, the extension cannot read config, logs, or the signed-in identity the app wrote.

  1. In the **"Signing & Capabilities"** tab, click **"+"**.
  2. Add **"Keychain Sharing"** and add a group, e.g. **com.your.app.shared**.
  3. Repeat the same step for the **Notification Service Extension** target, using the
     **same** group name.
  4. Pass that group as `sharedKeychainGroup` to both `SecuredCallsVoice.initialize(...)`
     and `SecuredCallsVoice.processNotificationAsync(...)`.

⚠️ Pass the group **without** the team-identifier prefix (`com.your.app.shared`, not
`ABCDE12345.com.your.app.shared`). The SDK resolves and prepends the team ID itself.

`sharedKeychainGroup` is a mandatory parameter on both methods — there is no default.

### Session and Storage Behaviour

- The signed-in identity, config and logs are stored in the Keychain and shared between the
  app and the extension through `sharedKeychainGroup`.
- Keychain items survive app uninstall. To avoid a reinstalled app picking up a previous
  identity, the first `initialize(...)` call on a fresh install clears any stored
  `userIdentifier` and `biometricMetadata`. Call `loginAsync(...)` to sign the user in.
- Keep your own copy of the user identifier if you want to sign the user in automatically on
  launch (the demo apps do this in `AppDelegate`).
- `logoutAsync(identifier:)` clears the SDK's stored state when the logout succeeds.

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
                    
                    sharedKeychainGroup: "com.your.app.shared",
                    // ✅ Mandatory — see "Keychain Sharing (Required)" above.
                    // ⚠️ IMPORTANT: This MUST be the SAME value that was passed
                    // during `SecuredCallsVoice.initialize(...)`, and the group
                    // must be enabled on BOTH the app and the extension target.
                    
                    authProvider: MyExtensionAuthProvider(),
                    // ✅ Mandatory — see "Authentication" below. The extension reuses
                    // the session the app cached in the shared Keychain and only
                    // calls this provider when that session has expired.
                    
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
				
				keypadButtonTitle: UIFont(name: "AvenirNext-DemiBold", size: 24),
				// Optional
				// Used for: Dial pad / keypad button text
				
				sheetTitle: UIFont(name: "AvenirNext-DemiBold", size: 20),
				// Optional
				// Used for: Title of SDK-presented bottom sheets
				// (e.g. the permission prompt sheet)
				
				sheetBody: UIFont(name: "AvenirNext-Regular", size: 18),
				// Optional
				// Used for: Body text of SDK-presented bottom sheets
				
				sheetButtonTitle: UIFont(name: "AvenirNext-DemiBold", size: 18)
				// Optional
				// Used for: Button titles inside SDK-presented bottom sheets
			)
            // initialize SDK
			try SecuredCallsVoice.initialize(
                    configFileName: "ConfigFileName", 
                    // ✅ Name of the configuration file (without extension) used by the SDK.
                    // Must contain an authMode of CUSTOMER_IDP or BFF.
                    
                    authProvider: MyAuthProvider.shared,
                    // ✅ Supplies your IDP token (CUSTOMER_IDP) or backend session (BFF).
                    // See "Authentication" below.
                    
                    settings: ScSDKSettingsModel(
                        handlePermission: true,
                        // ✅ When true, the SDK will automatically check and request
                        // required permissions via system popups if not already granted.
                        
                        showPipView: true,
                        // ✅ When true, enables Picture-in-Picture (PiP) mode,
                        // allowing the user to continue using the app during an ongoing call.
                        
                        logLevel: .debug,
                        // ✅ Controls SDK logging level:
                        // case error       = 0
                        // case warning     = 1
                        // case debug       = 2
                        // case information = 3
                        // case off         = -1 (Default)
                        // Capitalised aliases (.Debug, .Off, …) still work.
                        
                        scCallKitIconName: "AppIcon-Mono",
                        // ✅ Mono-color image name used on the CallKit screen.
                        // ⚠️ The image MUST be a monochrome asset for proper display.
                        
                        typography: typography,
						// Optional
						// If not provided, SDK uses default typography
                        
                        sessionReadyTimeoutSeconds: 3.0,
                        // Optional — Default: 3.0
                        // Maximum seconds the SDK waits for its session to become ready
                        // before placing a call back from a missed-call notification.
                        // Increase on slow-network environments.
                        
                        showDataChannelConnectionStatus: false,
                        // Optional — Default: false
                        // When true, the call screen shows a connection status
                        // indicator. Only appears when the data channel is enabled
                        // for the call.
                        
                        showDataChannelConnectionDetails: false
                        // Optional — Default: false
                        // When true, the status indicator becomes tappable and
                        // expands into a panel with connection details.
                        // Has no effect unless showDataChannelConnectionStatus
                        // is also true.
                    ),
                    
                    appGroupID: "group.com.your.app",
                    // ✅ App Group Identifier used for data sharing between
                    // the Main App and the Notification Extension.
                    // ⚠️ IMPORTANT: The SAME App Group ID must be used in BOTH
                    // the main app and the notification extension.
                    
                    sharedKeychainGroup: "com.your.app.shared",
                    // ✅ Mandatory — see "Keychain Sharing (Required)" above.
                    // Requires the "Keychain Sharing" capability on the app AND
                    // the notification extension, using the same group name.
                    // ⚠️ Must match the value passed to processNotificationAsync(...).
                    
                    biometricMetadata: biometricMetadata
                    // Optional — Default: nil
                    // See "Biometric Verification Metadata" below.
                )
       } catch {
           print("Failed to initialize SecuredCallsVoice SDK: \(error.localizedDescription)")
       }
       return true
   }
   ```

   ## Authentication

   The SDK obtains its Secured Calls access token through a `SecuredCallsAuthProvider`
   that your app implements. **No client secret is shipped in, or passed to, the SDK.**
   The tenant's mode comes from the mandatory `authMode` field of your `config.dat`;
   `initialize(...)` throws `SecuredCallError.authModeMissing` if it is absent and
   `SecuredCallError.unsupportedAuthMode` for any other value (including the retired
   `SHARED_SECRET`). Read it at runtime with `SecuredCallsVoice.authMode`.

   | `authMode` | Implement | What the SDK does |
   |------------|-----------|-------------------|
   | `CUSTOMER_IDP` | `identityProviderToken()` — return a valid JWT from your own IDP | Exchanges it at `/branding/device/auth-token/idp`. On `TOKEN_EXPIRED` it asks you once more for a refreshed JWT. |
   | `BFF` | `backendSession(deviceId:)` — your backend calls `/device/auth-token/bff` and returns `token`, `payloadKey` and `expiresAt` | Uses the session as-is. Never calls an auth-token endpoint itself. |

   ```swift
   final class MyAuthProvider: SecuredCallsAuthProvider {
       static let shared = MyAuthProvider()

       // CUSTOMER_IDP
       func identityProviderToken() async throws -> String {
           try await MyIdentityProvider.currentUser.freshIdToken()
       }

       // BFF — forward BOTH token and payloadKey from your backend unchanged.
       // Dropping payloadKey doesn't fail immediately, it breaks every later request.
       func backendSession(deviceId: String) async throws -> SecuredCallsAuthSession {
           let response = try await MyBackend.securedCallsSession(deviceId: deviceId)
           return SecuredCallsAuthSession(
               token: response.token,
               payloadKey: response.payloadKey,
               expiresAtEpochMilliseconds: response.expiresAt
           )
       }
   }
   ```

   Notes:

   - Implement only the method for your mode; the other has a default that throws.
   - The SDK calls the provider whenever it has no valid token: during `initialize(...)`
     (it fetches remote app config), when the cached token is close to expiry, after a
     401, and from the Notification Service Extension. It can run in the background (e.g.
     on a VoIP push), so it must refresh without UI. If the user isn't signed in yet,
     throw — the SDK asks again on the next authenticated call.
   - In `BFF` mode your backend's assertion must use `SecuredCallsVoice.deviceId` as its
     `deviceId` claim (also passed to `backendSession(deviceId:)`).
   - The session (token plus keys derived from `payloadKey`) is cached in the shared
     Keychain group, so the extension can reuse what the app obtained.
   - `logoutAsync(identifier:)` discards the cached session.
   - Each provider call must return within 30 seconds, or the request fails with
     `SecuredCallsAuthError.providerTimedOut`.
   - In `BFF` mode, a session whose `expiresAt` has already passed is rejected
     (`invalidProviderSession`). Issue tokens that live well beyond 2 minutes: the SDK refreshes
     2 minutes before expiry, so a shorter lifetime makes every request call your backend again.
   - Provider errors surface as `SecuredCallsAuthError`.

   ### Migrating from the client-secret API

   1. Remove the client secret from your app (Info.plist, xcconfig, CI secrets, source).
   2. Get a regenerated `config.dat` containing `authMode`.
   3. Replace `initialize("SECRET", configFileName: …)` with
      `initialize(configFileName: …, authProvider: …)`. The old signature is marked
      unavailable, with a compiler message pointing to the new one.
   4. Pass an `authProvider:` to `processNotificationAsync(...)` in your extension.

   ## Biometric Verification Metadata

   `biometricMetadata` is an optional `[String: Any]` dictionary of your own
   application context. When a biometric verification succeeds during a call, the SDK
   sends this dictionary along with the verification result.

   ```swift
   let biometricMetadata: [String: Any] = [
       "CustomerId": userIdentifier,
       "accountId": accountId,
       "verificationContext": "ACCOUNT_ACCESS",
       "location": ["latitude": 37.7749, "longitude": -122.4194],
       "appInfo": [
           "deviceModel": "iPhone 16 Pro",
           "osVersion": "18.3.1",
           "appVersion": "4.2.1"
       ]
   ]
   ```

   Notes:

   - Supported value types are `String`, `Int`, `Double`, `Bool`, `nil`, and arrays or
     dictionaries of those. Anything else (e.g. `Date`, `Float`, a custom type) makes
     `initialize(...)` throw `SecuredCallError.invalidBiometricMetadata`.
   - Passing `nil`, or omitting the parameter, clears any previously stored metadata.

   ## Requesting Permissions
   ### Request Contact Access and Notification Permission

   ```swift
   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
       do {
           UNUserNotificationCenter.current().delegate = self
			try SecuredCallsVoice.initialize(
				configFileName: "ConfigFileName",
				authProvider: MyAuthProvider.shared,
				settings: ScSDKSettingsModel(
					handlePermission: true,
					showPipView: true,
					logLevel: .Debug,
					scCallKitIconName: "AppIcon-Mono"
				),
                appGroupID: "group.com.your.app",
                sharedKeychainGroup: "com.your.app.shared"
            )
        
           // Request permissions and login asynchronously
           Task {
               await SecuredCallsVoice.requestNotificationPermissionAsync()
               await SecuredCallsVoice.requestContactAccessAsync()
               await SecuredCallsVoice.requestLocationPermissionAsync()
               await SecuredCallsVoice.requestMicrophonePermissionAsync()
               await SecuredCallsVoice.requestBiometricPermissionAsync()
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
				configFileName: "ConfigFileName",
				authProvider: MyAuthProvider.shared,
				settings: ScSDKSettingsModel(
					handlePermission: true,
					showPipView: true,
					logLevel: .Debug,
					scCallKitIconName: "AppIcon-Mono"
				),
                appGroupID: "group.com.your.app",
                sharedKeychainGroup: "com.your.app.shared"
            )
        
           Task {
               await SecuredCallsVoice.requestNotificationPermissionAsync()
               await SecuredCallsVoice.requestContactAccessAsync()
               await SecuredCallsVoice.requestLocationPermissionAsync()
               await SecuredCallsVoice.requestMicrophonePermissionAsync()
               await SecuredCallsVoice.requestBiometricPermissionAsync()
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

   - ### Login Result and Concurrent Logins

   `loginAsync(identifier:isForceLogin:)` returns `Result<Bool, Error>`. Only one login runs at
   a time: a second call while one is in progress returns
   `.failure(SDKError.loginAlreadyInProgress)`. Pass `isForceLogin: true` to start a new login
   anyway.

   ```swift
   let result = await SecuredCallsVoice.loginAsync(identifier: userIdentifier, isForceLogin: true)
   ```

   - ### Handing the Login Task to the SDK (Recommended)

   When a user taps a missed-call notification while the app is not running, iOS
   cold-launches the app and may deliver the tap **before** your login has finished.
   Assign your login `Task` to `SecuredCallsVoice.pendingLoginTask` and the SDK will
   await it before attempting the call back, instead of guessing with a timeout.

   ```swift
   let loginTask = Task<Result<Bool, Error>, Never> {
       let result = await SecuredCallsVoice.loginAsync(identifier: userIdentifier)
       switch result {
       case .success:
           logger.info("SecuredCallsVoice login status = success")
       case .failure(let error):
           logger.info("SecuredCallsVoice login status = failure : \(error.localizedDescription)")
       }
       return result
   }
   SecuredCallsVoice.pendingLoginTask = loginTask
   ```

   If you do not set `pendingLoginTask`, the SDK falls back to waiting up to
   `sessionReadyTimeoutSeconds` (default `3.0`) for a login already in progress.

## APNS and VOIP Token Management

   ### Register Device APNS Token

   `isProduction` can be provided in two ways:

   - **Manual** — you determine and pass the flag yourself (e.g. from a build config or UserDefaults).
   - **Auto-detected** — omit `isProduction` and the SDK detects it for you from the app's embedded
     provisioning profile's `aps-environment` entitlement (falls back to `production` for App Store
     builds, which have no embedded profile, and to `sandbox` on the simulator).

   **Manual:**

   ```swift
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let token = deviceToken.hexString
       Task {
               // 'true' indicates a production environment, while 'false' indicates a sandbox
               // environment. This flag should be set by the client based on the current
               // deployment stage.
               let isProduction = false
               await SecuredCallsVoice.registerDeviceAsync(customerId: userIdentifier, token: token, isProduction: isProduction)
       }
   }
   ```

   **OR — Auto-detected** (the SDK determines `isProduction` for you):

   ```swift
   func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       let token = deviceToken.hexString
       Task {
               await SecuredCallsVoice.registerDeviceAsync(customerId: userIdentifier, token: token)
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


   > **Token reuse on login.** The SDK keeps the APNs token passed to `registerDeviceAsync`
   > for the life of the process and sends it again on each `loginAsync(...)`, so push
   > notifications are tied to the account that just signed in. Keep calling
   > `registerDeviceAsync` from `didRegisterForRemoteNotificationsWithDeviceToken` so the
   > token stays current.


   ### Register Device VOIP Token And Report Incoming VOIP Push

   Like `registerDeviceAsync`, `isProduction` can be passed manually or omitted so the SDK
   auto-detects it from the app's provisioning profile:

   **Manual:**

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

   **OR — Auto-detected** (the SDK determines `isProduction` for you):

   ```swift
   extension AppDelegate: PKPushRegistryDelegate {
	func pushRegistry(
		_ registry: PKPushRegistry,
		didUpdate pushCredentials: PKPushCredentials,
		for type: PKPushType
	) {
		if type == PKPushType.voIP {
			Task {
				await SecuredCallsVoice.registerVoipTokenAsync(token: pushCredentials.token)
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
			try await SecuredCallsVoice.startCallAsync(
				number: "61450000001",
				// Optional — if nil, the contact centre number from your config is used.
				
				callType: .inApp,
				// .inApp places the call through the SDK.
				// .pstn hands off to the native dialer.
				
				callIntent: "Card dispute follow-up",
				// Optional — Default: ""
				// Short reason for the call, surfaced on the call screen.
				
				customData: ["ticketId": "T-1029"]
				// Optional — Default: [:]
				// Arbitrary key/value context passed along with the call.
			)
		} catch {
			print("Error: \(error)")
		}
	}
  ```

   `startCallAsync` throws `SecuredCallError.onGoingCall` if a call is already active,
   and `SecuredCallError.invalidNumber` if no number is available. `customData` is also
   accepted by `callBackFromCallHistory(...)`, which derives the call intent itself.

### Logout User Session

`logoutAsync(identifier:)` ends the session, deregisters the user on the backend and, when
that succeeds, clears the SDK's stored state. It returns `Result<Bool, Error>` and does not
throw. On failure the stored state is kept, so you can retry.

```swift
Task {
    switch await SecuredCallsVoice.logoutAsync(identifier: userIdentifier) {
    case .success:
        // Clear your own copy of the identifier.
        break
    case .failure(let error):
        print("Logout failed: \(error.localizedDescription)")
    }
}
```

## Handling Callback from phone history (SwiftUI)

When a user taps a call entry from the iOS Phone app call history (Recents) or initiates a call using Siri, iOS delivers an `NSUserActivity` containing a system call intent such as:

- `INStartAudioCallIntent`
- `INStartCallIntent`

Your application must extract the call identifier from the system intent and forward it to the SecuredCalls Voice SDK.

---

### SwiftUI App Entry – Receiving and Forwarding Call Intents

```swift
import SwiftUI
import Intents
import SecuredCallsVoiceSDK

@main
struct AppName_SwiftUIApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(
                    "INStartAudioCallIntent",
                    perform: handleCallIntent
                )
                .onContinueUserActivity(
                    "INStartCallIntent",
                    perform: handleCallIntent
                )
        }
    }

    /// Receives system call intents and forwards the extracted call
    /// identifier to the SecuredCalls Voice SDK.
    private func handleCallIntent(_ userActivity: NSUserActivity) {

        guard let interaction = userActivity.interaction else {
            return
        }

        var callId: String?

        if let intent = interaction.intent as? INStartAudioCallIntent {
            callId = intent.contacts?.first?.personHandle?.value
        } else if let intent = interaction.intent as? INStartCallIntent {
            callId = intent.contacts?.first?.personHandle?.value
        }

        guard let callIdentifier = callId else {
            return
        }

        Task {
            do {
                try await SecuredCallsVoice.callBackFromCallHistory(
                    callId: callIdentifier,
                    callType: .inApp
                )
            } catch {
                print("SecuredCalls: failed to process call intent – \(error.localizedDescription)")
            }
        }
    }
}
```

## Handling Missed Call Notification Callback

When a user misses an incoming call, the SDK automatically schedules a local notification. Tapping the notification will automatically initiate a call back.

### Handle Notification Tap

Add `userNotificationCenter(_:didReceive:withCompletionHandler:)` to your existing `UNUserNotificationCenterDelegate` extension in `AppDelegate`:
```swift
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task {
            defer { completionHandler() }
            do {
                try await SecuredCallsVoice.callBackFromMissedCallNotification(response)
            } catch {
                print("callBackFromMissedCallNotification failed: \(error.localizedDescription)")
            }
        }
    }
}
```

`callBackFromMissedCallNotification` only acts on notifications whose
`categoryIdentifier` is `MISSED_CALL`, and returns without doing anything for any
other category. It is therefore safe to forward every notification response to it —
though you may still want to check the category yourself if your app has its own
handling for other categories.

### Refreshing Branding History on Foreground Notifications

If you present notifications while the app is in the foreground, call
`SecuredCallsVoice.processNotification()` so the SDK can notify your
`SecuredCallsVoiceDelegate` that branding history changed:

```swift
func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
) {
    completionHandler([.banner, .sound])
    SecuredCallsVoice.processNotification()
}
```

### Notification Appearance

The missed call notification displays:

- **Title**: Call intent (if available), otherwise the app/brand name
- **Body**: 📞 Missed voice call
- **Action**: Tap to call back instantly

## Observing Call Status

Conform to `ICallStatusDelegate` to be notified when a call starts, ends, or fails to
connect. Register the delegate once — for example in your view model's initializer.

```swift
import SecuredCallsVoiceSDK

final class CallViewModel: ICallStatusDelegate {

    init() {
        SecuredCallsVoice.setCallStatusDelegate(self)
    }

    func callStarted() {
        // A call is now connected.
    }

    func callEnded() {
        // The call finished.
    }

    func callFailed(reason: String) {
        // An outgoing call failed before connecting (e.g. poor network).
    }
}
```

Pass `nil` to `setCallStatusDelegate(_:)` to unregister. The delegate is held weakly,
so keep a strong reference to the object that conforms to it.

## Call History and Branding History

The SDK keeps two separate histories: **call history** (actual voice calls) and
**branding history** (branded caller entries delivered by push).

### Reading History

Both methods return `[CallInfoModel]`, which exposes `callId`, `intent`, `note`,
`contactNumber`, `businessName`, `brandImage`, `callType`, `callTime`,
`isIncomingCall`, `callDuration`, `historyType`, and branding colours.

```swift
Task {
    switch await SecuredCallsVoice.getCallHistoryAsync() {
    case .success(let calls):
        print("\(calls.count) calls")
    case .failure(let error):
        print("Failed: \(error.localizedDescription)")
    }

    switch await SecuredCallsVoice.getBrandingHistoryAsync() {
    case .success(let branding):
        print("\(branding.count) branding entries")
    case .failure(let error):
        print("Failed: \(error.localizedDescription)")
    }
}
```

### Clearing History

```swift
Task {
    await SecuredCallsVoice.clearCallHistoryAsync()      // calls only
    await SecuredCallsVoice.clearBrandingHistoryAsync()  // branding only
    await SecuredCallsVoice.clearAllCallHistoryAsync()   // both
}
```

### Reacting to History Updates

Conform to `SecuredCallsVoiceDelegate` to refresh your UI when the SDK writes new
history. `didUpdateBrandingHistory()` has a default empty implementation, so
implement only what you need.

```swift
final class HistoryViewModel: SecuredCallsVoiceDelegate {

    init() {
        SecuredCallsVoice.setHistoryDelegate(self)
    }

    func didUpdateCallHistory() {
        // Reload call history.
    }

    func didUpdateBrandingHistory() {
        // Reload branding history.
    }
}
```

Like the call status delegate, this delegate is held weakly.

To trigger `didUpdateCallHistory()` yourself, for example after your app records a call, call
`SecuredCallsVoice.notifyCallHistoryUpdated()`.

## SDK Logs

`getLogs()` returns the SDK's recorded log lines, and `clearLogs()` removes them.

```swift
Task {
    let lines: [String] = await SecuredCallsVoice.getLogs()
    await SecuredCallsVoice.clearLogs()
}
```

## Handling Callback from phone history (Appdelegate) * documentation in progress

## Handling Callback from phone history (Scenedelegate) * documentation in progress

## Notes

-   **Credentials**: Never embed a Secured Calls secret in your app. Implement
    `SecuredCallsAuthProvider` for your tenant's `authMode` (see [Authentication](#authentication)).

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
| **10. Callback from phone history** | Handling Callback from phone history and pass data to SDK. | 5 minutes |
| **11. Callback from missedcall notification** | Handling Callback from missedcall notification and pass data to SDK. | 5 minutes |


**Total Estimated Time: 40 minutes**
