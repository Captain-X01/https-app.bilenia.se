package se.bilenia.app;

import android.os.Bundle;
import android.webkit.CookieManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    scheduleWebViewSetup();
  }

  @Override
  public void onStart() {
    super.onStart();
    scheduleWebViewSetup();
  }

  private void scheduleWebViewSetup() {
    WebView webView = getBridge() != null ? getBridge().getWebView() : null;
    if (webView == null) return;
    webView.post(this::enableCrossOriginCookies);
  }

  private void enableCrossOriginCookies() {
    WebView webView = getBridge().getWebView();
    if (webView == null) return;

    CookieManager cookieManager = CookieManager.getInstance();
    cookieManager.setAcceptCookie(true);
    cookieManager.setAcceptThirdPartyCookies(webView, true);

    WebSettings settings = webView.getSettings();
    settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
  }
}
