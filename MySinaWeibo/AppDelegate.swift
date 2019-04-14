//
//  AppDelegate.swift
//  MySinaWeibo
//
//  Created by Stephen Cao on 21/3/19.
//  Copyright © 2019 Stephen Cao. All rights reserved.
//

import UIKit
import UserNotifications
import SVProgressHUD
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupAdditions()
        window = UIWindow()
        window?.backgroundColor = UIColor.white
        window?.rootViewController = SCMainViewController()
        window?.makeKeyAndVisible()
        loadAppInfo()
        
        return true
    }
}

// MARK: - setup additional settings
extension AppDelegate{
    private func setupAdditions() {
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        NetworkActivityIndicatorManager.shared.isEnabled = true
        // get users' authority for title notification, sound and badge number
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound,.carPlay]) { (success, error) in
            print(success ? "success": "error")
        }
    }
}
extension AppDelegate{
    private func loadAppInfo(){
        DispatchQueue.global().async {
            let url = Bundle.main.url(forResource: "main.json", withExtension: nil)
            let data = NSData(contentsOf: url!)
            let docDir = NSString.getDocumentDirectory()
            let jsonPath = (docDir as NSString).appendingPathComponent("main.json")
            data?.write(toFile: jsonPath, atomically: true)
        }
    }
}
