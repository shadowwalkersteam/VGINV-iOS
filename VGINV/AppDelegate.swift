//
//  AppDelegate.swift
//  VGINV
//
//  Created by Zohaib on 6/15/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import UIKit
import CometChatPro
import Firebase
import UserNotifications
import PushKit
import L10n_swift
import OneSignal
import UserNotifications
//import LanguageManager_iOS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var items: [L10n] = L10n.supportedLanguages.map { L10n(language: $0) }
    
    let gcmMessageIDKey = "gcm.message_id"
    var blockedUsersArray = [String]()
    let blockedUserRequest = BlockedUserRequest.BlockedUserRequestBuilder(limit: 100).build();
    var window: UIWindow?
    var groupRequest: GroupsRequest? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        //START OneSignal initialization code
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: false]
        
        // Replace 'YOUR_ONESIGNAL_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
          appId: "af0bb11e-f674-47a8-8718-bc1c78c36019",
          handleNotificationAction: nil,
          settings: onesignalInitSettings)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;

        // The promptForPushNotifications function code will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 6)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
        //END OneSignal initializataion code
        
        
        // Override point for customization after application launch.
        self.initialization()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        CometChat.calldelegate = self
        CometChat.messagedelegate = self
        //        L10n.shared.language = self.items[1].language
        //        LanguageManager.shared.defaultLanguage = .deviceLanguage
        
        if let language = UserDefaults.standard.string(forKey: "language") {
            L10n.shared.language = language
        }
        
        // store
        NotificationCenter.default.addObserver(forName: .L10nLanguageChanged, object: self, queue: nil) { _ in
            UserDefaults.standard.set(L10n.shared.language, forKey: "language")
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
//        self.presentCall()
        window?.makeKeyAndVisible()
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .dark
        }
        #endif
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print( "Message ID: \(messageID)")
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print( "Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print( "Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print( "APNs token retrieved: \(deviceToken)")
        let   tokenString = deviceToken.reduce("", {$0 + String(format: "%02X",    $1)})
        print( "deviceToken: \(tokenString)")
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
        voipRegistry.delegate = self
    }
    
    
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        self.initialization()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("active")
        UserDefaults(suiteName: "group.com.technosoft.VGINV")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("terminated")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("foreground")
        UserDefaults(suiteName: "group.com.technosoft.VGINV")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.initialization()
    }
    
    func initialization(){
        if(ConstantStrings.appId.contains(NSLocalizedString("Enter", comment: "")) || ConstantStrings.appId.contains(NSLocalizedString("ENTER", comment: "")) || ConstantStrings.appId.contains("NULL") || ConstantStrings.appId.contains("null") || ConstantStrings.appId.count == 0){
            
        }else{
            let appSettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: ConstantStrings.region).build()
            CometChat.init(appId:ConstantStrings.appId, appSettings: appSettings, onSuccess: { (Success) in
                print( "Initialization onSuccess \(Success)")
            }) { (error) in
                print( "Initialization Error \(error.errorDescription)")
            }
        }
    }
    
    private func openController(controller: UIViewController) {
        DispatchQueue.main.async {
            let topMostViewController = UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            LoginController.skipScreen = true
            var currentController = topMostViewController
            while let presentedController = currentController.presentedViewController {
                currentController = presentedController
            }
            let navigationController: UINavigationController = UINavigationController(rootViewController: controller)
            navigationController.modalPresentationStyle = .fullScreen
            currentController.present(navigationController, animated: true, completion: nil)
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        var sender:String = String()
        var type :String = String()
        
        if let userInfo = (notification.request.content.userInfo as? [String : Any]){
            let messageObject = userInfo["message"]
            
            if let someString = messageObject as? String {
                
                if let dict = someString.stringTodictionary(){
                    
                    sender = dict["sender"] as? String ?? ""
                    type = dict["type"] as! String
                    
                    let message = CometChat.processMessage(dict).0
                    let notificationSender = message?.senderUid
                    
                    let topMostViewController = UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()

                    if let navigationController = topMostViewController as? CometChatMessageList {
                        let currentReceiver = navigationController.currentUser?.uid
                        if currentReceiver == notificationSender {
                         completionHandler([])
                         return
                        }
                    } else if let navigationController = topMostViewController.children[0].topMostViewController() as? CometChatMessageList {
                        let currentReceiver = navigationController.currentGroup?.guid
                        if currentReceiver == message?.receiverUid {
                         completionHandler([])
                         return
                        }
                    }
                }
            }
        }
        
        if(blockedUsersArray.contains(sender)){
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(notification.request.identifier)"])
        }else if(type == "audio") || (type == "video"){
            
        }else{
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let userInfo = (response.notification.request.content.userInfo as? [String : Any]){
            if (userInfo.debugDescription.contains("message")) {
                let messageObject = userInfo["message"]
                if let someString = messageObject as? String {
                    if let dict = someString.stringTodictionary(){
                        print("Call Object: \(CometChat.processMessage(dict))")
                        let message = CometChat.processMessage(dict).0
                        let notificationSender = message?.senderUid
                        if (message?.receiverType.rawValue == 1) {
                            DashboardViewController.isMembersChat = true
                            groupRequest = GroupsRequest.GroupsRequestBuilder(limit: 50).set(joinedOnly: true).build()
                            groupRequest!.fetchNext(onSuccess: { (groups) in
                                print("fetchGroups onSuccess: \(groups)")
                                if groups.count != 0{
                                    let joinedGroups = groups.filter({$0.hasJoined == true && $0.guid == message?.receiverUid})
                                    DispatchQueue.main.async {
                                        LoginController.skipScreen = true
                                        let messageList = CometChatMessageList()
                                        messageList.set(conversationWith: joinedGroups[0], type: .group)
                                        messageList.hidesBottomBarWhenPushed = true
                                        let topMostViewController = UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()
                                        var currentController = topMostViewController
                                        while let presentedController = currentController.presentedViewController {
                                            currentController = presentedController
                                        }
                                        let navigationController: UINavigationController = UINavigationController(rootViewController: messageList)
                                        navigationController.modalPresentationStyle = .fullScreen
                                        currentController.present(navigationController, animated: true, completion: nil)
                                    }
                                }
                            }) { (error) in
                                print("refreshGroups error:\(String(describing: error?.errorDescription))")
                            }
                        } else {
                            DashboardViewController.isMembersChat = false
                            CometChat.getConversation(conversationWith: message?.senderUid ?? "", conversationType: .user, onSuccess: { (conversation) in
                                DispatchQueue.main.async {
                                    LoginController.skipScreen = true
                                    let messageList = CometChatMessageList()
                                    messageList.set(conversationWith: ((conversation?.conversationWith as? User)!), type: .user)
                                    messageList.hidesBottomBarWhenPushed = true
                                    let topMostViewController = UIApplication.shared.keyWindow!.rootViewController!.topMostViewController()
                                    var currentController = topMostViewController
                                    while let presentedController = currentController.presentedViewController {
                                        currentController = presentedController
                                    }
                                    let navigationController: UINavigationController = UINavigationController(rootViewController: messageList)
                                    navigationController.modalPresentationStyle = .fullScreen
                                    currentController.present(navigationController, animated: true, completion: nil)
                                }
                            }) { (error) in
                              print("error \(String(describing: error?.errorDescription))")
                            }
                        }
                    }
                }
            } else {
                 let messageObject = userInfo["aps"]
                if let someString = messageObject as? Dictionary<String, Any> {
                    let secondaryDict = someString["alert"]
                    if let dict = secondaryDict as? Dictionary<String, Any>{
                        if (dict["body"].debugDescription.contains("Project") || dict["body"].debugDescription.contains("Deal") || dict["body"].debugDescription.contains("Hello")) {
                            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProjectsDealsController") as? ProjectsDealsController {
                                openController(controller: controller)
                            }
                        } else if (dict["body"].debugDescription.contains("You have a new friend request from")) {
                            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "notifications") as? NotificationsController {
                                openController(controller: controller)
                            }
                            
                        }  else if (dict["body"].debugDescription.contains("Friend Request Accepted")) {
                            if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allFriends") as? FriendsController {
                                openController(controller: controller)
                            }
                            
                        }
                    }
                }
            }
        }
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        print("Firebase registration token1: \(Messaging.messaging().fcmToken)")
        
        
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
    // [END ios_10_data_message]
}

extension AppDelegate : CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        
        print("message is: \(textMessage.stringValue())")
    }
}


extension AppDelegate : PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        if pushCredentials.token.count == 0 {
            print("voip token NULL")
            return
        }
        //print out the VoIP token. We will use this to test the notification.
        let   tokenString = pushCredentials.token.reduce("", {$0 + String(format: "%02X",    $1)})
        print("voip token \(tokenString)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        let payloadDict = payload.dictionaryPayload["aps"] as? Dictionary<String, String>
        let message = payloadDict?["alert"]
        
        //present a local notifcation to visually see when we are recieving a VoIP Notification
        if UIApplication.shared.applicationState == UIApplication.State.background {
            
            let localNotification = UILocalNotification()
            localNotification.alertBody = message
            localNotification.applicationIconBadgeNumber = 1
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            UIApplication.shared.presentLocalNotificationNow(localNotification);
        }
            
        else {
            DispatchQueue.main.async {
                
                let alert = UIAlertView(title: "VoIP Notification", message: message, delegate: nil, cancelButtonTitle: "Ok");
                alert.show()
            }
        }
        NSLog("incoming voip notfication: \(payload.dictionaryPayload)")
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        NSLog("token invalidated")
    }
    
}



extension String {
    
    func stringTodictionary() -> [String:Any]? {
        
        var dictonary:[String:Any]?
        
        if let data = self.data(using: .utf8) {
            
            do {
                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                
                if let myDictionary = dictonary
                {
                    return myDictionary;
                }
            } catch let error as NSError {
                print(error)
            }
            
        }
        return dictonary;
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}
