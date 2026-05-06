//
//  SmartBazaarApp.swift
//  SmartBazaar
//
//  Created by Abhijeet Waghmare on 03/05/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()
        return true
    }
}

@main
struct SmartBazaarApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
