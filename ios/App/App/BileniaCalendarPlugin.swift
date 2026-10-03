import Foundation
import Capacitor
import EventKit
import EventKitUI

/// Opens Apple's native EKEventEditViewController so the user can confirm "Add".
/// Used only from native iOS — web/Android keep the .ics flow.
@objc(BileniaCalendarPlugin)
public class BileniaCalendarPlugin: CAPInstancePlugin, CAPBridgedPlugin, EKEventEditViewDelegate {
    public let identifier = "BileniaCalendarPlugin"
    public let jsName = "BileniaCalendar"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "addCalendarEvent", returnType: CAPPluginReturnPromise)
    ]

    private var pendingCall: CAPPluginCall?
    private let eventStore = EKEventStore()

    @objc func addCalendarEvent(_ call: CAPPluginCall) {
        guard let title = call.getString("title")?.trimmingCharacters(in: .whitespacesAndNewlines),
              !title.isEmpty else {
            call.reject("title is required")
            return
        }

        guard let startDateStr = call.getString("startDate"),
              let endDateStr = call.getString("endDate"),
              let startDate = Self.parseIsoDate(startDateStr),
              let endDate = Self.parseIsoDate(endDateStr) else {
            call.reject("startDate and endDate must be valid ISO-8601 strings")
            return
        }

        if startDate >= endDate {
            call.reject("startDate must be before endDate")
            return
        }

        let notes = call.getString("notes")
        let urlString = call.getString("url")
        let reminderMinutesBefore = call.getInt("reminderMinutesBefore") ?? 60

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            // iOS 17+: EKEventEditViewController runs out-of-process and does NOT
            // require a prior permission prompt (Apple TN3152 / WWDC23). Requesting
            // write-only first can fail or no-op on newer iOS (16/26/27) while older
            // iPhones still worked with the permission path.
            self.presentEditor(
                call: call,
                title: title,
                startDate: startDate,
                endDate: endDate,
                notes: notes,
                urlString: urlString,
                reminderMinutesBefore: reminderMinutesBefore
            )
        }
    }

    private func presentEditor(
        call: CAPPluginCall,
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String?,
        urlString: String?,
        reminderMinutesBefore: Int
    ) {
        if pendingCall != nil {
            call.reject("Calendar editor already open", "PENDING")
            return
        }

        guard let presenter = presentationHost() else {
            call.reject("No view controller available")
            return
        }

        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        if let urlString, let url = URL(string: urlString) {
            event.url = url
        }

        let minutes = max(0, reminderMinutesBefore)
        if minutes > 0 {
            event.addAlarm(EKAlarm(relativeOffset: TimeInterval(-minutes * 60)))
        }

        let editor = EKEventEditViewController()
        editor.eventStore = eventStore
        editor.event = event
        editor.editViewDelegate = self
        editor.modalPresentationStyle = .formSheet

        pendingCall = call
        presenter.present(editor, animated: true)
    }

    /// Topmost VC in the active scene — reliable after UIScene / SceneDelegate.
    private func presentationHost() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes where scene.activationState == .foregroundActive {
            let root =
                scene.windows.first(where: \.isKeyWindow)?.rootViewController
                ?? scene.windows.first?.rootViewController
            if let host = topMost(from: root) {
                return host
            }
        }
        return topMost(from: bridge?.viewController)
    }

    private func topMost(from root: UIViewController?) -> UIViewController? {
        guard var top = root else { return nil }
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

    public func eventEditViewController(
        _ controller: EKEventEditViewController,
        didCompleteWith action: EKEventEditViewAction
    ) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let call = self.pendingCall
            self.pendingCall = nil

            let status: String
            switch action {
            case .saved:
                status = "saved"
            case .canceled:
                status = "cancelled"
            case .deleted:
                status = "deleted"
            @unknown default:
                status = "unknown"
            }
            call?.resolve(["action": status])
        }
    }

    private static func parseIsoDate(_ value: String) -> Date? {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: value) {
            return date
        }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: value)
    }
}
