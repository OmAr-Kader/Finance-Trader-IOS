//
//  Finance_Trader_IOSApp.swift
//  Finance-Trader-IOS
//
//  Created by OmAr on 24/04/2024.
//

import SwiftUI

@main
struct Finance_Trader_IOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Main(app: delegate.app)
        }
    }
}
