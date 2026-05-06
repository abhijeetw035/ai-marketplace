import SwiftUI

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.5),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .init(x: phase - 0.3, y: 0),
                        endPoint:   .init(x: phase + 0.3, y: 0)
                    )
                    .blendMode(.screen)
                }
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.4)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1.3
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Skeleton Block

struct SkeletonBlock: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Theme.tertiaryBackground)
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Feed Card Skeleton

struct FeedCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Image placeholder
            SkeletonBlock(height: 200, cornerRadius: DesignSystem.CornerRadius.medium)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                SkeletonBlock(width: 180, height: 16)
                SkeletonBlock(width: 100, height: 20)
                HStack {
                    SkeletonBlock(width: 70, height: 12)
                    Spacer()
                    SkeletonBlock(width: 50, height: 12)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.tiny)
        }
        .padding(.bottom, DesignSystem.Spacing.medium)
    }
}

// MARK: - Feed Skeleton List

struct FeedSkeletonList: View {
    var count: Int = 4

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(0..<count, id: \.self) { _ in
                    FeedCardSkeleton()
                }
            }
            .padding()
        }
        .allowsHitTesting(false)
    }
}
