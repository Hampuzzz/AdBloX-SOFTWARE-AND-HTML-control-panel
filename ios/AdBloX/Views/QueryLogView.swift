import SwiftUI

struct QueryLogView: View {
    @State private var entries: [QueryEntry] = []
    @State private var searchText = ""
    @State private var filterStatus = "all"
    @State private var isLoading = true
    @State private var totalQueries = 0

    var filteredEntries: [QueryEntry] {
        entries.filter { entry in
            let matchesSearch = searchText.isEmpty || entry.domain.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = filterStatus == "all" || entry.status == filterStatus
            return matchesSearch && matchesStatus
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                HStack(spacing: 8) {
                    filterButton("All", "all")
                    filterButton("Blocked", "blocked")
                    filterButton("Allowed", "allowed")
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Query list
                List(filteredEntries) { entry in
                    QueryRow(entry: entry)
                        .listRowBackground(Color.adbloxBackground)
                        .listRowSeparatorTint(Color.adbloxBorder)
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search domains...")
            }
            .background(Color.adbloxBackground)
            .navigationTitle("Query Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(totalQueries) queries")
                        .font(.caption)
                        .foregroundColor(.adbloxTextMuted)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView().tint(.adbloxPrimary)
                }
            }
        }
        .task {
            do {
                let response = try await APIClient.shared.getQueryLog()
                entries = response.entries
                totalQueries = response.total
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }

    private func filterButton(_ label: String, _ value: String) -> some View {
        Button(action: { filterStatus = value }) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(filterStatus == value ? Color.adbloxPrimaryDim : Color.adbloxCardBg)
                .foregroundColor(filterStatus == value ? .adbloxPrimary : .adbloxTextMuted)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(filterStatus == value ? Color.adbloxPrimary.opacity(0.3) : Color.adbloxBorder, lineWidth: 1)
                )
        }
    }
}

struct QueryRow: View {
    let entry: QueryEntry

    var body: some View {
        HStack {
            Circle()
                .fill(entry.isBlocked ? Color.adbloxDanger : Color.adbloxSuccess)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.domain)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundColor(.adbloxText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(entry.type)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.adbloxPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.adbloxPrimaryDim)
                        .cornerRadius(4)

                    Text(entry.device)
                        .font(.caption2)
                        .foregroundColor(.adbloxTextMuted)

                    if let list = entry.list {
                        Text(list)
                            .font(.caption2)
                            .foregroundColor(.adbloxDanger.opacity(0.8))
                    }
                }
            }

            Spacer()

            Text(entry.status)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(entry.isBlocked ? .adbloxDanger : .adbloxSuccess)
        }
    }
}
