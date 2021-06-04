//
//  AppDelegate.swift
//  GettMobileDelivery
//
//  Created by Gett on 5/5/21.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var appCoordinator: AppCorrdinator?
    private var apiKey: String {
      get {
        guard let filePath = Bundle.main.path(forResource: "GoogleServices-Info", ofType: "plist") else {
          fatalError("Couldn't find file 'GoogleServices-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'GoogleServices-Info.plist'.")
        }
        if value == "AIzaSyBq2Z7qOER7IH0dtzYyzE4NCV8BNUTuUa8" {
            fatalError("Insert API Key in GoogleServices-Info.plist")
        }
        return value
      }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        appCoordinator = AppCorrdinator(window: window!)
        appCoordinator?.start()
        
        GMSServices.provideAPIKey("AIzaSyBq2Z7qOER7IH0dtzYyzE4NCV8BNUTuUa8")

        return true
    }
}

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//
//
//}
//
