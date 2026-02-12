import SwiftUI

@main
struct AdBloXApp: App {
    @StateObject private var tailscale = TailscaleManager()
    @StateObject private var dnsFilter = DNSFilterService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tailscale)
                .environmentObject(dnsFilter)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var tailscale: TailscaleManager

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "shield.checkmark.fill")
                    Text("Dashboard")
                }

            DevicesView()
                .tabItem {
                    Image(systemName: "laptopcomputer.and.iphone")
                    Text("Devices")
                }

            WebDashboardView()
                .tabItem {
                    Image(systemName: "globe")
                    Text("Web Panel")
                }

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(Color.adbloxPrimary)
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(Color.adbloxBackground)
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}
