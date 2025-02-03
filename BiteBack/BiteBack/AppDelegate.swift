//
//  AppDelegate.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
