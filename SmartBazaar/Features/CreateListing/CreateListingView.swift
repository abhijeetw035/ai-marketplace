import SwiftUI

struct CreateListingView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Pricing"), footer: Text("Our AI will suggest a price once details are filled.")) {
                    TextField("Price (₹)", text: $price)
                        .keyboardType(.numberPad)
                    
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .foregroundColor(Theme.accent)
                        Text("Suggested: ₹4,200 - ₹4,800")
                            .foregroundColor(Theme.accent)
                    }
                }
                
                Section {
                    Button(action: {
                        // Publish action
                    }) {
                        Text("Publish Listing")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Theme.accent)
                }
            }
            .navigationTitle("Sell an Item")
        }
    }
}

#Preview {
    CreateListingView()
}
