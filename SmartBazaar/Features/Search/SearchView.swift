import SwiftUI

struct SearchView: View {
    @State private var query = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.accent)
                    TextField("e.g. cheap iPhone for gaming", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("Search with intent")
                        .font(.headline)
                    Text("Try searching for specific needs like 'good study laptop under 30k'.")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Search")
            .background(Theme.secondaryBackground)
        }
    }
}

#Preview {
    SearchView()
}
