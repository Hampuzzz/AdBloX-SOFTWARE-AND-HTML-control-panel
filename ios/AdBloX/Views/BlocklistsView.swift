import SwiftUI

struct BlocklistsView: View {
    @State private var lists: [BlockList] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(lists.enumerated()), id: \.element.id) { index, list in
                        BlocklistRow(list: list) {
                            lists[index].enabled.toggle()
                            Task {
                                try? await APIClient.shared.toggleBlocklist(
                                    id: list.id,
                                    enabled: lists[index].enabled
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.adbloxBackground)
            .navigationTitle("Blocklists")
            .overlay {
                if isLoading {
                    ProgressView().tint(.adbloxPrimary)
                }
            }
        }
        .task {
            do {
                let response = try await APIClient.shared.getBlocklists()
                lists = response.lists
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}

struct BlocklistRow: View {
    let list: BlockList
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(list.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                if let desc = list.description {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.adbloxTextMuted)
                        .lineLimit(2)
                }

                Text("\(list.formattedEntries) entries")
                    .font(.caption2)
                    .foregroundColor(.adbloxTextMuted)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { list.enabled },
                set: { _ in onToggle() }
            ))
            .tint(.adbloxPrimary)
            .labelsHidden()
        }
        .padding()
        .background(Color.adbloxCardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.adbloxBorder, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
