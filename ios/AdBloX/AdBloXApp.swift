import SwiftUI

@main
struct AdBloXApp: App {
    @StateObject private var vpn = VPNManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vpn)
                .preferredColorScheme(.dark)
                .onAppear { configureAppearance() }
        }
    }

    private func configureAppearance() {
        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar

        let navBar = UINavigationBarAppearance()
        navBar.configureWithOpaqueBackground()
        navBar.backgroundColor = UIColor(red: 10/255, green: 10/255, blue: 10/255, alpha: 1)
        navBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBar
        UINavigationBar.appearance().scrollEdgeAppearance = navBar
    }
}

/// Root: 4 tabs — Connect (like Tailscale main), Dashboard (WebView into device),
/// Nodes (mesh peers), Settings
struct RootView: View {
    @EnvironmentObject var vpn: VPNManager

    var body: some View {
        TabView {
            ConnectView()
                .tabItem {
                    Image(systemName: "power")
                    Text("Connect")
                }

            DashboardWebView()
                .tabItem {
                    Image(systemName: "shield.checkmark.fill")
                    Text("Dashboard")
                }

            NodesView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Nodes")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.adbloxCyan)
    }
}
