import Foundation
import Capacitor
import UIKit

/// Opens URLs in *system Safari* (not SFSafariViewController).
/// Required for BankID same-device on iOS: BankID returns to Safari; if Idura
/// started in SFSafariViewController the OIDC session is orphaned and the
/// picker restarts. Starting in Safari keeps one continuous browser session.
@objc(BileniaBrowserPlugin)
public class BileniaBrowserPlugin: CAPInstancePlugin, CAPBridgedPlugin {
    public let identifier = "BileniaBrowserPlugin"
    public let jsName = "BileniaBrowser"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "openExternal", returnType: CAPPluginReturnPromise)
    ]

    @objc func openExternal(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty,
              let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            call.reject("url must be a valid http(s) URL")
            return
        }

        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    call.resolve()
                } else {
                    call.reject("Failed to open URL in Safari")
                }
            }
        }
    }
}
