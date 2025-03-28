import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create window with the window scene
        window = UIWindow(windowScene: windowScene)
        
        // Set camera view controller as root, but disable autostart
        let cameraViewController = CameraViewController()
        
        // Disable view controller's automatic camera initialization
        // We'll enable it after the UI is fully visible
        cameraViewController.disableCameraAutostart = true
        
        window?.rootViewController = cameraViewController
        
        // Make window visible
        window?.makeKeyAndVisible()
        
        // Delay camera initialization until after UI is fully loaded
        // This prevents AVCaptureSession conflicts during scene connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak cameraViewController] in
            guard let _ = self, let cameraViewController = cameraViewController else { return }
            
            // Now it's safe to initialize the camera
            print("SceneDelegate: Delayed camera initialization starting")
            cameraViewController.enableCameraAutostart()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}