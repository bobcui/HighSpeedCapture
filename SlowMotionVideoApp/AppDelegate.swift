import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let appInitializationQueue = DispatchQueue(label: "com.example.appInitializationQueue")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set camera view controller as root, but don't initialize camera yet
        // This prevents AVCaptureSession configuration conflicts during app launch
        let cameraViewController = CameraViewController()
        
        // Disable view controller's automatic camera initialization
        // We'll enable it after the UI is fully visible
        cameraViewController.disableCameraAutostart = true
        
        window?.rootViewController = cameraViewController
        
        // Make window visible
        window?.makeKeyAndVisible()
        
        // Delay camera initialization until after UI is fully loaded
        // This prevents AVCaptureSession conflicts during app initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak cameraViewController] in
            guard let _ = self, let cameraViewController = cameraViewController else { return }
            
            // Now it's safe to initialize the camera
            print("AppDelegate: Delayed camera initialization starting")
            cameraViewController.enableCameraAutostart()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}