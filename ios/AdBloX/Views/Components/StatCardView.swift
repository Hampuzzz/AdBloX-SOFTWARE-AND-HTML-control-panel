import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .cornerRadius(8)
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.adbloxTextMuted)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
            }
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
