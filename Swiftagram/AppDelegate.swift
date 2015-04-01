//
//  AppDelegate.swift
//  Swiftagram
//
//  Created by Marius Horga on 3/13/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        DataSource.sharedInstance
        let navVC = UINavigationController()
        if (DataSource.sharedInstance.accessToken == nil) {
            let loginVC = LoginViewController()
            navVC.setViewControllers([loginVC], animated: true)
            NSNotificationCenter.defaultCenter().addObserverForName(LoginViewController().LoginViewControllerDidGetAccessTokenNotification, object: nil, queue: nil, usingBlock: { (note: NSNotification?) in
                let imagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as ImagesTableViewController
                navVC.setViewControllers([imagesVC], animated: true)
            })
        } else {
            let imagesVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as ImagesTableViewController
            navVC.setViewControllers([imagesVC], animated: true)
        }
        window?.rootViewController = navVC
        window?.backgroundColor = UIColor.whiteColor()
        window?.makeKeyAndVisible()
        return true
    }

}

