//
//  AppDelegate.swift
//  DoBetter
//
//  Created by Никита Шестаков on 04.01.2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow? { mainWindow }

    var mainWindow: MainUIWindow?
    var appCoordinator: AppCoordinator?
    var userDefaults: UserDefaults = .standard

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _setupFirebase()

        mainWindow = AppCoordinator.shared.window
        window?.tintColor = .foreground
        _setStartViewController()
        _setupAppearance()
        return true
    }

    private func _setupFirebase() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            return guardUnreachable("Invalid GoogleService-Info path")
        }
        guard let options = FirebaseOptions(contentsOfFile: path) else {
            return guardUnreachable("Invalid path for firebase options")
        }

        FirebaseApp.configure(options: options)
    }

    private func _setStartViewController() {
        AppCoordinator.shared.start()
    }

    private func _setupAppearance() {
        let backImg = #imageLiteral(resourceName: "icBack").imageWithInset(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))

        UINavigationBar.appearance().backIndicatorImage = backImg
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImg
        UINavigationBar.appearance().tintColor = .white

        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().tintColor = .accent

        UIBarButtonItem.appearance()
                .setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .medium)],
                                        for: .normal)
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketIOManager.shared.disconnectSocket()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SocketIOManager.shared.connectSocket()
    }

    func sessionUpdated() {
    }

    func sessionDidReset() {
    }
}
