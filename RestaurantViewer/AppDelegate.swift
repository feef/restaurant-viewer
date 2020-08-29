//
//  AppDelegate.swift
//  RestaurantViewer
//
//  Created by Feef Anthony on 8/29/20.
//  Copyright © 2020 Feef Anthony. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    internal var window: UIWindow?
    private var rootCoordinator: MapCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        let navigationController = UINavigationController()
        window.rootViewController = navigationController
        rootCoordinator = MapCoordinator(navigationController: navigationController)
        rootCoordinator.start()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

