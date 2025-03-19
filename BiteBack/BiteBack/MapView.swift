import SwiftUI
import MapKit
import FirebaseFirestore
import Firebase

struct BusinessLocation: Identifiable {
    let id: UUID // Local UUID for the business
    let name: String
    let coordinate: CLLocationCoordinate2D
    let businessStreet: String
    let businessCity: String
    let businessState: String
}

struct MapView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.1447, longitude: -86.8021), // Vanderbilt University
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Adjust zoom level
        )
    )
    
    @State private var businessLocations: [BusinessLocation] = []
    
    private let geocoder = CLGeocoder()

    // Fetch Chili's location from Firestore (using the specific document ID)
    func fetchBusinessLocation() {
        let db = Firestore.firestore()
        let documentID = "kXnihmM57yYJOpm5HNZomAcho3Z2" // Chili's specific document ID because i couldn't figure out the
        
        db.collection("users").document(documentID).getDocument { snapshot, error in
            guard let document = snapshot else {
                print("Error fetching Chili's business: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let data = document.data()
            let name = data?["businessName"] as? String ?? "Chili's"
            let street = data?["businessStreet"] as? String ?? ""
            let city = data?["businessCity"] as? String ?? ""
            let state = data?["businessState"] as? String ?? ""
            
            // Combine address fields
            let address = "\(street), \(city), \(state)"
            
            // Use geocoding to get coordinates
            geocodeAddress(address) { coordinate in
                if let coordinate = coordinate {
                    // Create a BusinessLocation object with a UUID and add it to the array
                    let location = BusinessLocation(
                        id: UUID(), // Local UUID
                        name: name,
                        coordinate: coordinate,
                        businessStreet: street,
                        businessCity: city,
                        businessState: state
                    )
                    // Add Chili's location to the array
                    self.businessLocations = [location] // Ensure we only show Chili's
                }
            }
        }
    }

    // Geocode address to coordinates
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                // Return the coordinate of the first geocoded result
                completion(placemark.location?.coordinate)
            } else {
                print("No geocoding results found.")
                completion(nil)
            }
        }
    }

    var body: some View {
        VStack {
            Map(position: $position) {
                UserAnnotation() // Optional, will show the user's location
                
                // Add markers for just the Chili's business location
                ForEach(businessLocations) { location in
                    Marker(location.name, coordinate: location.coordinate)
                        .tint(.red) // Make the marker red
                }
            }
            .onAppear {
                fetchBusinessLocation() // Fetch Chili's location when the view appears
            }
            .mapControls {
                MapUserLocationButton() // Button to re-center on user location
                MapCompass() //
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Chili's Location")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MapView()
        }
    }
}

