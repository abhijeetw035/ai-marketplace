import SwiftUI

// MARK: - Trust Badge (compact, for cards)

struct TrustBadge: View {
    let result: TrustScoreResult
    
    private var color: Color { Color(hex: result.grade.colorHex) }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: result.grade.icon)
                .font(.caption2)
            Text("\(result.score)")
                .font(.caption)
                .fontWeight(.bold)
        }
        .foregroundColor(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .cornerRadius(DesignSystem.CornerRadius.small)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Trust Score Panel (expanded, for detail view)

struct TrustScorePanel: View {
    let result: TrustScoreResult
    @State private var expanded = false
    
    private var color: Color { Color(hex: result.grade.colorHex) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Header row
            Button(action: { withAnimation(.spring()) { expanded.toggle() } }) {
                HStack {
                    Image(systemName: result.grade.icon)
                        .foregroundColor(color)
                    Text(result.grade.rawValue)
                        .font(.headline)
                        .foregroundColor(color)
                    Text("· \(result.score)/100")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(result.score) / 100, height: 6)
                        .animation(.easeOut, value: result.score)
                }
            }
            .frame(height: 6)
            
            // Explanation
            Text(result.explanation)
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            
            // Expanded breakdown + flags
            if expanded {
                Divider().padding(.vertical, 4)
                
                // Score breakdown
                VStack(spacing: 6) {
                    ScoreRow(label: "Title",       value: result.breakdown.titleScore,       max: 25)
                    ScoreRow(label: "Description", value: result.breakdown.descriptionScore, max: 25)
                    ScoreRow(label: "Price",       value: result.breakdown.priceScore,       max: 25)
                    ScoreRow(label: "Images",      value: result.breakdown.imageScore,       max: 25)
                }
                
                if !result.flags.isEmpty {
                    Divider().padding(.vertical, 4)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Flags")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.secondaryText)
                        ForEach(result.flags) { flag in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: flag.severity.icon)
                                    .font(.caption)
                                    .foregroundColor(flagColor(flag.severity))
                                Text(flag.message)
                                    .font(.caption)
                                    .foregroundColor(Theme.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func flagColor(_ severity: FlagSeverity) -> Color {
        switch severity {
        case .info:     return Theme.accent
        case .warning:  return Theme.warning
        case .critical: return Theme.error
        }
    }
}

// MARK: - Breakdown Row

private struct ScoreRow: View {
    let label: String
    let value: Int
    let max: Int
    
    var ratio: CGFloat { CGFloat(value) / CGFloat(max) }
    var barColor: Color { ratio > 0.7 ? Theme.success : ratio > 0.4 ? Theme.warning : Theme.error }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.secondaryText)
                .frame(width: 80, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor.opacity(0.15))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor)
                        .frame(width: geo.size.width * ratio, height: 5)
                }
            }
            .frame(height: 5)
            Text("\(value)/\(max)")
                .font(.caption2)
                .foregroundColor(Theme.secondaryText)
                .frame(width: 30, alignment: .trailing)
        }
    }
}
