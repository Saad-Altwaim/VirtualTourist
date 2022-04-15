//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Saad altwaim on 8/29/21.
//  Copyright © 2021 Saad Altwaim. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        setDefaultsValuesForZoomAndCenter()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

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

    func setDefaultsValuesForZoomAndCenter()
    {
        let userDefaults = UserDefaults.standard

        if  userDefaults.object(forKey: "latZoom") == nil && userDefaults.object(forKey: "latZoom") == nil
        {
            userDefaults.set(0.5, forKey: "latZoom")
            userDefaults.set(0.5, forKey: "lonZoom")
        }
        
        if  userDefaults.object(forKey: "latCenter") == nil && userDefaults.object(forKey: "lonCenter") == nil
        {
            userDefaults.set(21.532633, forKey: "latCenter")
            userDefaults.set(39.177899, forKey: "lonCenter")
        }
    }

}

