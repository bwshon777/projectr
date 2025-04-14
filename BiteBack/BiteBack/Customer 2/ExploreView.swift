import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""

    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 10) {
                // Title with welcome message
                Text("🔍 Explore Nearby Restaurants")
                    .font(.title2)
                    .bold()
                    .padding(.top, 20)

                
                // Map view
                MapView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(15)
                    .padding()
                    .shadow(radius: 5)
            }

            
        }
    }
}

// MARK: - Preview
struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}

