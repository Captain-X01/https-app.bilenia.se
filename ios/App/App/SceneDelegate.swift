import UIKit
import Capacitor

/// UIScene lifecycle required when building with Xcode 26+/iOS 26+ SDK.
///
/// Forwards deep links / Universal Links via ApplicationDelegateProxy so this
/// compiles against Capacitor 8.3–8.5 (SceneDelegateProxy only exists in 8.5+ SPM).
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Use our CAPBridgeViewController subclass (plugins + edge-swipe).
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = BridgeViewController()
        self.window = window
        window.makeKeyAndVisible()

        // Cold-start deep links arrive in connectionOptions (not openURLContexts).
        for context in connectionOptions.urlContexts {
            _ = ApplicationDelegateProxy.shared.application(
                UIApplication.shared,
                open: context.url,
                options: [:]
            )
        }
        for userActivity in connectionOptions.userActivities {
            _ = ApplicationDelegateProxy.shared.application(
                UIApplication.shared,
                continue: userActivity,
                restorationHandler: { _ in }
            )
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            _ = ApplicationDelegateProxy.shared.application(
                UIApplication.shared,
                open: context.url,
                options: [:]
            )
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = ApplicationDelegateProxy.shared.application(
            UIApplication.shared,
            continue: userActivity,
            restorationHandler: { _ in }
        )
    }
}
