import SwiftUI

struct OfflineBanner: View {
    @ObservedObject private var network = NetworkMonitor.shared
    let pendingCount: Int
    
    var body: some View {
        if !network.isConnected {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("You're offline")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if pendingCount > 0 {
                        Text("\(pendingCount) action\(pendingCount == 1 ? "" : "s") queued — will sync when back online.")
                            .font(.caption2)
                            .opacity(0.85)
                    } else {
                        Text("Showing cached content.")
                            .font(.caption2)
                            .opacity(0.85)
                    }
                }
                
                Spacer()
                
                if pendingCount > 0 {
                    Text("\(pendingCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(width: 22, height: 22)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Circle())
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .background(Color(hex: "#1E3A5F"))
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}
