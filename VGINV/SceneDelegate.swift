//
//  SceneDelegate.swift
//  VGINV
//
//  Created by Zohaib on 6/15/20.
//  Copyright © 2020 Techno. All rights reserved.
//

import UIKit
import CometChatPro

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("active")
        UserDefaults(suiteName: "group.com.technosoft.VGINV")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        self.initialization()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("active")
        UserDefaults(suiteName: "group.com.technosoft.VGINV")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
        self.initialization()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        UserDefaults(suiteName: "group.com.technosoft.VGINV")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
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
}

