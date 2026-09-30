import UIKit
import Capacitor

/// Enables iOS edge-swipe back when WebView history has entries (hash router).
class BridgeViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        super.capacitorDidLoad()
        bridge?.registerPluginInstance(BileniaCalendarPlugin())
        bridge?.registerPluginInstance(BileniaBrowserPlugin())
        webView?.allowsBackForwardNavigationGestures = true
    }
}
