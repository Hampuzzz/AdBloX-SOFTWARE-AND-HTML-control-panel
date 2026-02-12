import SwiftUI
import WebKit

struct WebDashboardView: View {
    @State private var isLoading = true
    @State private var loadError = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBackground.ignoresSafeArea()

                WebView(
                    url: URL(string: "https://mesh.adblox.se")!,
                    isLoading: $isLoading,
                    loadError: $loadError
                )
                .edgesIgnoringSafeArea(.bottom)

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.adbloxPrimary)
                            .scaleEffect(1.5)
                        Text("Loading Dashboard...")
                            .font(.subheadline)
                            .foregroundColor(.adbloxTextMuted)
                    }
                }

                if loadError {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.adbloxTextMuted)
                        Text("Cannot reach mesh.adblox.se")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Make sure you're connected to the AdBloX mesh network.")
                            .font(.subheadline)
                            .foregroundColor(.adbloxTextMuted)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationTitle("Web Panel")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadError: Bool

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor(Color.adbloxBackground)
        webView.scrollView.backgroundColor = UIColor(Color.adbloxBackground)
        webView.load(URLRequest(url: url))

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, loadError: $loadError)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool
        @Binding var loadError: Bool

        init(isLoading: Binding<Bool>, loadError: Binding<Bool>) {
            _isLoading = isLoading
            _loadError = loadError
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
            loadError = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            loadError = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
            loadError = true
        }
    }
}
