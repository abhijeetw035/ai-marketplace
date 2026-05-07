import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Image Upload Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Photos")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.small) {
                                PhotosPicker(selection: $viewModel.selectedItems, maxSelectionCount: 5, matching: .images) {
                                    VStack {
                                        Image(systemName: "camera.badge.ellipsis")
                                            .font(.title)
                                        Text("Add Photos")
                                            .font(.caption)
                                    }
                                    .foregroundColor(Theme.accent)
                                    .frame(width: 100, height: 100)
                                    .background(Theme.secondaryBackground)
                                    .cornerRadius(DesignSystem.CornerRadius.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                            .stroke(Theme.border, style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    )
                                }
                                .padding(.leading)
                                
                                ForEach(0..<viewModel.selectedImagesData.count, id: \.self) { index in
                                    if let uiImage = UIImage(data: viewModel.selectedImagesData[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                                            .overlay(
                                                Button(action: {
                                                    viewModel.selectedImagesData.remove(at: index)
                                                    viewModel.selectedItems.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.black.opacity(0.5).clipShape(Circle()))
                                                }
                                                .padding(4),
                                                alignment: .topTrailing
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                    .appearAnimation()
                    
                    // Title and Description
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Listing Details")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(Theme.primary)
                        
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            CustomTextField(title: "Title", placeholder: "What are you selling?", text: $viewModel.title)
                                .onChange(of: viewModel.title) { _, _ in viewModel.suggestPrice() }
                            
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                                Text("Description")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(Theme.secondaryText)
                                TextEditor(text: $viewModel.description)
                                    .padding(8)
                                    .frame(height: 100)
                                    .background(Theme.background)
                                    .cornerRadius(DesignSystem.CornerRadius.small)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                                            .stroke(Theme.border, lineWidth: 1)
                                    )
                                    .onChange(of: viewModel.description) { _, _ in viewModel.suggestPrice() }
                            }
                        }
                        .padding()
                        .background(Theme.background)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .appearAnimation()
                    
                    // Pricing Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Pricing")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(Theme.primary)
                        
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            CustomTextField(title: "Price (₹)", placeholder: "0", text: $viewModel.price)
                                .keyboardType(.numberPad)
                            
                            if viewModel.isFetchingSuggestion {
                                HStack {
                                    ProgressView()
                                        .padding(.trailing, 4)
                                    Text("AI is analyzing market value...")
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(Theme.secondaryText)
                                }
                                .padding(.top, 4)
                            } else if let suggestion = viewModel.suggestedPriceRange, let explanation = viewModel.aiExplanation {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(Theme.accent)
                                        Text("AI Suggested Range: \(suggestion)")
                                            .font(DesignSystem.Typography.headline)
                                            .foregroundColor(Theme.accent)
                                    }
                                    
                                    Text(explanation)
                                        .font(DesignSystem.Typography.caption)
                                        .foregroundColor(Theme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.accent.opacity(0.05))
                                .cornerRadius(DesignSystem.CornerRadius.small)
                            }
                        }
                        .padding()
                        .background(Theme.background)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .appearAnimation(delay: 0.1)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(Theme.error)
                            .font(DesignSystem.Typography.caption)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.publishListing()
                        }
                    }) {
                        if viewModel.isPublishing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Publish Listing")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .disabled(viewModel.isPublishing)
                    .appearAnimation(delay: 0.2)
                }
                .padding(.vertical)
            }
            .background(Theme.secondaryBackground)
            .navigationTitle("Sell an Item")
        }
    }
}

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(Theme.secondaryText)
            TextField(placeholder, text: $text)
                .padding()
                .background(Theme.background)
                .cornerRadius(DesignSystem.CornerRadius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
                        .stroke(Theme.border, lineWidth: 1)
                )
                .keyboardType(keyboardType)
        }
    }
}

#Preview {
    CreateListingView()
}
