import UIKit
import CoreData
import Firebase
import FirebaseAuth
import FirebaseStorage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        super.init()
        FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error {
                print("Failed to sign in anonymously with error \(error)")
            }
        }
        return true
    }
}

