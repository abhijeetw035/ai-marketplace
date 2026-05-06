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
                // Image Carousel Placeholder
                TabView {
                    ForEach(0..<3) { index in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Text("Image \(index + 1)")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 300)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    // Header Info
                    if let listing = viewModel.listing {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                            Text(listing.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(String(format: "₹%.0f", listing.price))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.accent)
                            
                            HStack {
                                if let trust = trustResult {
                                    TrustBadge(result: trust)
                                }
                                Spacer()
                                Text("Posted 2 hours ago")
                                    .font(.caption)
                                    .foregroundColor(Theme.secondaryText)
                            }
                        }
                    
                    Divider()
                    
                    // Trust Score Panel
                    if let trust = trustResult {
                        TrustScorePanel(result: trust)
                    }
                    
                    Divider()
                    
                    // Seller Profile
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                        
                        VStack(alignment: .leading) {
                            Text("John Doe")
                                .font(.headline)
                            Text("Verified Seller • 4.8 ★")
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                        }
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Description")
                            .font(.headline)
                        
                        if let listing = viewModel.listing {
                            Text(listing.description)
                                .font(.body)
                                .foregroundColor(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    }
                    
                    Spacer(minLength: 80) // Space for bottom buttons
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
                        // Save to wishlist
                    }) {
                        Image(systemName: "heart")
                            .font(.title2)
                            .foregroundColor(Theme.accent)
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
    NavigationView {
        ListingDetailView()
    }
}
