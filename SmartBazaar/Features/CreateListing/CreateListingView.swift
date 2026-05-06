import SwiftUI

struct CreateListingView: View {
    @StateObject private var viewModel = CreateListingViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $viewModel.title)
                        .onChange(of: viewModel.title) { viewModel.suggestPrice() }
                    TextField("Description", text: $viewModel.description)
                        .onChange(of: viewModel.description) { viewModel.suggestPrice() }
                }
                
                Section(header: Text("Pricing"), footer: Text("Our AI will suggest a price once details are filled.")) {
                    TextField("Price (₹)", text: $viewModel.price)
                        .keyboardType(.numberPad)
                    
                    if let suggestion = viewModel.suggestedPriceRange {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(Theme.accent)
                            Text("Suggested: \(suggestion)")
                                .foregroundColor(Theme.accent)
                        }
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
