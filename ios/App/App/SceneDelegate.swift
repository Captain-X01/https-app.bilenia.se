import UIKit
import Capacitor

/// UIScene lifecycle required when building with Xcode 26+/iOS 26+ SDK.
/// Deep links / Universal Links are forwarded via SceneDelegateProxy (Capacitor 8.5+).
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Use our CAPBridgeViewController subclass (plugins + edge-swipe).
        // Window is created in code; Main.storyboard no longer owns the root window.
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = BridgeViewController()
        self.window = window
        window.makeKeyAndVisible()

        SceneDelegateProxy.shared.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        SceneDelegateProxy.shared.scene(scene, openURLContexts: URLContexts)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SceneDelegateProxy.shared.scene(scene, continue: userActivity)
    }
}
