import SwiftUI

struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $viewModel.title)
                        .onChange(of: viewModel.title) { viewModel.suggestPrice() }
                    TextField("Description", text: $viewModel.description)
                        .onChange(of: viewModel.description) { viewModel.suggestPrice() }
                }
                
                Section(header: Text("Pricing"), footer: Text("Our AI suggests an optimal price to help you sell faster.")) {
                    TextField("Price (₹)", text: $viewModel.price)
                        .keyboardType(.numberPad)
                    
                    if viewModel.isFetchingSuggestion {
                        HStack {
                            ProgressView()
                                .padding(.trailing, 4)
                            Text("Analyzing market price...")
                                .foregroundColor(Theme.secondaryText)
                                .font(.subheadline)
                        }
                    } else if let suggestion = viewModel.suggestedPriceRange, let explanation = viewModel.aiExplanation {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(Theme.accent)
                                Text("AI Suggested Range: \(suggestion)")
                                    .foregroundColor(Theme.accent)
                                    .fontWeight(.medium)
                            }
                            Text(explanation)
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(Theme.error)
                            .font(.caption)
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await viewModel.publishListing()
                        }
                    }) {
                        HStack {
                            if viewModel.isPublishing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 4)
                            }
                            Text(viewModel.isPublishing ? "Publishing..." : "Publish Listing")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(Theme.accent)
                    .disabled(viewModel.isPublishing)
                }
            }
            .navigationTitle("Sell an Item")
        }
    }
}

#Preview {
    CreateListingView()
}
