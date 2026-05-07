import SwiftUI

struct ListingDetailView: View {
    @StateObject var viewModel: ListingDetailViewModel
    @State private var trustResult: TrustScoreResult? = nil
    
    init(listing: Listing? = nil) {
        _viewModel = StateObject(wrappedValue: ListingDetailViewModel(listing: listing))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Image Carousel
                TabView {
                    if let images = viewModel.listing?.images, !images.isEmpty {
                        ForEach(images, id: \.self) { imageUrl in
                            AsyncImage(url: URL(string: imageUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .clipped()
                        }
                    } else {
                        ForEach(0..<3) { index in
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    // Header Info
                    if let listing = viewModel.listing {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                            Text(listing.title)
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(Theme.primary)
                            
                            Text(String(format: "₹%.0f", listing.price))
                                .font(DesignSystem.Typography.largeTitle)
                                .foregroundColor(Theme.accent)
                            
                            HStack {
                                if let trust = trustResult {
                                    TrustBadge(result: trust)
                                }
                                Spacer()
                                Text("Posted 2 hours ago")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(Theme.secondaryText)
                            }
                        }
                        .appearAnimation()
                    
                        Divider()
                        
                        // Trust Score Panel
                        if let trust = trustResult {
                            TrustScorePanel(result: trust)
                                .appearAnimation(delay: 0.1)
                        }
                        
                        Divider()
                        
                        // Seller Profile
                        HStack(spacing: DesignSystem.Spacing.medium) {
                            Circle()
                                .fill(Theme.tertiaryBackground)
                                .frame(width: 50, height: 50)
                                .overlay(Image(systemName: "person.fill").foregroundColor(Theme.secondaryText))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.sellerName)
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(Theme.primary)
                                Text("Verified Seller • \(viewModel.sellerRating) ★")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(Theme.secondaryText)
                            }
                            
                            Spacer()
                            
                            Button("Contact") {}
                                .font(DesignSystem.Typography.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Theme.accent.opacity(0.1))
                                .foregroundColor(Theme.accent)
                                .cornerRadius(DesignSystem.CornerRadius.pill)
                        }
                        .padding(.vertical, 4)
                        .appearAnimation(delay: 0.15)
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Description")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(Theme.primary)
                            
                            Text(listing.description)
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(Theme.secondaryText)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .appearAnimation(delay: 0.2)
                    }
                    
                    Spacer(minLength: 100) 
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if let listing = viewModel.listing {
                trustResult = TrustScoreEngine.evaluate(listing: listing)
            }
        }
        .overlay(
            VStack {
                Spacer()
                HStack(spacing: DesignSystem.Spacing.medium) {
                    Button(action: {
                        viewModel.toggleWishlist()
                    }) {
                        Image(systemName: viewModel.isSaved ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(viewModel.isSaved ? Theme.error : Theme.accent)
                            .frame(width: 50, height: 50)
                            .background(Theme.secondaryBackground)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    NavigationLink(destination: ChatView()) {
                        Text("Chat & Offer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Theme.accent)
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                            .shadow(color: Theme.accent.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .background(Theme.background)
            }
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ListingDetailView()
    }
}
