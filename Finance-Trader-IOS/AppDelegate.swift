import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    private(set) var appSet: AppObserve! = nil
    
    var app: AppObserve {
        guard let appSet else {
            let app = AppObserve()
            self.appSet = app
            return app
        }
        return appSet
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        appSet = nil
    }

}

