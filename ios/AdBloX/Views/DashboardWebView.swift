import SwiftUI
import WebKit

/// Loads the AdBloX device's web dashboard through the VPN tunnel.
/// Only accessible when connected — shows a "connect first" message otherwise.
struct DashboardWebView: View {
    @EnvironmentObject var vpn: VPNManager
    @State private var isLoading = true
    @State private var loadFailed = false
    @State private var webView: WKWebView?

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBg.ignoresSafeArea()

                if vpn.state.isActive, let url = vpn.dashboardURL {
                    // Connected — show the dashboard
                    AdBloXWebView(
                        url: url,
                        isLoading: $isLoading,
                        loadFailed: $loadFailed,
                        webView: $webView
                    )
                    .ignoresSafeArea(.container, edges: .bottom)

                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.adbloxCyan)
                                .scaleEffect(1.2)
                            Text("Loading \(vpn.deviceName)...")
                                .font(.subheadline)
                                .foregroundColor(.adbloxMuted)
                        }
                    }

                    if loadFailed {
                        dashboardError
                    }
                } else {
                    // Not connected
                    notConnected
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if vpn.state.isActive {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { webView?.reload() }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.adbloxCyan)
                        }
                    }
                }
            }
            // Reload when VPN connects
            .onChange(of: vpn.state, perform: { newState in
                if newState.isActive {
                    loadFailed = false
                    isLoading = true
                    if let url = vpn.dashboardURL {
                        webView?.load(URLRequest(url: url))
                    }
                }
            })
        }
    }

    private var notConnected: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.slash")
                .font(.system(size: 48))
                .foregroundColor(.adbloxMuted)

            Text("Not Connected")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Connect to your AdBloX device first.\nThe dashboard will load automatically.")
                .font(.subheadline)
                .foregroundColor(.adbloxMuted)
                .multilineTextAlignment(.center)

            if !vpn.deviceIP.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "server.rack")
                        .font(.caption)
                    Text(vpn.deviceIP)
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundColor(.adbloxCyan.opacity(0.6))
            }
        }
        .padding()
    }

    private var dashboardError: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.adbloxRed)

            Text("Cannot Load Dashboard")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            Text("Connected to VPN but the dashboard\nat \(vpn.deviceIP) is not responding.")
                .font(.subheadline)
                .foregroundColor(.adbloxMuted)
                .multilineTextAlignment(.center)

            Button(action: {
                loadFailed = false
                isLoading = true
                if let url = vpn.dashboardURL {
                    webView?.load(URLRequest(url: url))
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.adbloxCyan)
                .cornerRadius(10)
            }
        }
        .padding()
    }
}

/// WKWebView wrapper for the AdBloX dashboard
struct AdBloXWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool
    @Binding var webView: WKWebView?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.isOpaque = false
        wv.backgroundColor = UIColor(Color.adbloxBg)
        wv.scrollView.backgroundColor = UIColor(Color.adbloxBg)
        wv.allowsBackForwardNavigationGestures = true
        wv.load(URLRequest(url: url))

        DispatchQueue.main.async { self.webView = wv }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, loadFailed: $loadFailed)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        @Binding var loadFailed: Bool

        init(isLoading: Binding<Bool>, loadFailed: Binding<Bool>) {
            _isLoading = isLoading
            _loadFailed = loadFailed
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
            loadFailed = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            loadFailed = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            loadFailed = true
        }

        // Allow loading HTTP (the AdBloX device is on a local/mesh network)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}
