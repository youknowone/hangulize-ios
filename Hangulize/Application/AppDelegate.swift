//
//  AppDelegate.swift
//  Hangulize
//
//  Created by Jeong YunWon on 2019/11/15.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

import Firebase
import GoogleMobileAds
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        GADMobileAds.sharedInstance().start(completionHandler: nil)
        #if targetEnvironment(simulator)
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID as! String]
        #endif

        FirebaseApp.configure()

        if true {
            let appearance = UIView.appearance()
            appearance.tintColor = .hangulizeTint
            // appearance.backgroundColor = .hangulizeBackground
        }

        if true {
            let appearance = UINavigationBar.appearance()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.hangulizeTint]
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.hangulizeTint]
            appearance.backgroundColor = .hangulizeBackground
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
