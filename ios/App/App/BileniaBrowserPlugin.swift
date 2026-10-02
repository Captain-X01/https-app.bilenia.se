import Foundation
import Capacitor
import UIKit
import AuthenticationServices

/// iOS BankID / OIDC via ASWebAuthenticationSession.
/// Presents a system auth sheet (not Safari, not SFSafariViewController).
/// When the backend redirects to `se.bilenia.app://…`, the session captures that
/// URL and returns it to JS — no “Öppna i Bilenia?” prompt, no leftover Safari tab.
@objc(BileniaBrowserPlugin)
public class BileniaBrowserPlugin: CAPInstancePlugin, CAPBridgedPlugin, ASWebAuthenticationPresentationContextProviding {
    public let identifier = "BileniaBrowserPlugin"
    public let jsName = "BileniaBrowser"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "openExternal", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "startAuthSession", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "cancelAuthSession", returnType: CAPPluginReturnPromise)
    ]

    private var authSession: ASWebAuthenticationSession?
    private var pendingAuthCall: CAPPluginCall?

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

    /// Starts ASWebAuthenticationSession and resolves with `{ url }` when the
    /// OIDC/BankID flow redirects to `callbackScheme://…`.
    @objc func startAuthSession(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty,
              let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            call.reject("url must be a valid http(s) URL")
            return
        }

        let callbackScheme = (call.getString("callbackScheme") ?? "se.bilenia.app")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "://", with: "")
        guard !callbackScheme.isEmpty else {
            call.reject("callbackScheme is required")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.authSession?.cancel()
            self.pendingAuthCall?.reject("Superseded by a new auth session", "SUPERSEDED")
            self.pendingAuthCall = call

            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackScheme
            ) { [weak self] callbackURL, error in
                guard let self else { return }
                defer {
                    self.authSession = nil
                    self.pendingAuthCall = nil
                }

                if let error = error as? ASWebAuthenticationSessionError,
                   error.code == .canceledLogin {
                    call.reject("User canceled authentication", "CANCELED")
                    return
                }
                if let error {
                    call.reject(error.localizedDescription, "AUTH_SESSION_FAILED")
                    return
                }
                guard let callbackURL else {
                    call.reject("Auth session returned no callback URL", "NO_CALLBACK")
                    return
                }
                call.resolve(["url": callbackURL.absoluteString])
            }

            // Keep cookies inside this session across BankID app handoff (same-device).
            session.prefersEphemeralWebBrowserSession = false
            session.presentationContextProvider = self
            self.authSession = session

            if !session.start() {
                self.authSession = nil
                self.pendingAuthCall = nil
                call.reject("Failed to start ASWebAuthenticationSession", "START_FAILED")
            }
        }
    }

    @objc func cancelAuthSession(_ call: CAPPluginCall) {
        DispatchQueue.main.async { [weak self] in
            self?.authSession?.cancel()
            self?.authSession = nil
            if let pending = self?.pendingAuthCall {
                self?.pendingAuthCall = nil
                pending.reject("Auth session canceled", "CANCELED")
            }
            call.resolve()
        }
    }

    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            if let key = scene.windows.first(where: { $0.isKeyWindow }) {
                return key
            }
            if let any = scene.windows.first {
                return any
            }
        }
        return ASPresentationAnchor()
    }
}
