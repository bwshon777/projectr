import SwiftUI
import MapKit
import FirebaseFirestore
import Firebase

struct BusinessLocation: Identifiable {
    let id: UUID
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
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    @State private var businessLocations: [BusinessLocation] = []
    
    private let geocoder = CLGeocoder()
    private let documentIDs = [
        "kXnihmM57yYJOpm5HNZomAcho3Z2", // Chili's document ID
        "qXqa3kRRLCZXFbTQUC4JsXagqxt1", // Pokebros document ID
        "gTUE1XeincVNX7EmrI7WdIID5fQ2"  // Thai Satay document ID
    ]
    
    // Fetch multiple business locations from Firestore
    func fetchBusinessLocations() {
        let db = Firestore.firestore()
        
        for (index, documentID) in documentIDs.enumerated() {
            db.collection("users").document(documentID).getDocument { snapshot, error in
                guard let document = snapshot else {
                    print("Error fetching business: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let data = document.data()
                let name = data?["businessName"] as? String ?? "Unknown Business"
                let street = data?["businessStreet"] as? String ?? ""
                let city = data?["businessCity"] as? String ?? ""
                let state = data?["businessState"] as? String ?? ""
                
                let address = "\(street), \(city), \(state)"
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "’", with: "'") // Fixes smart apostrophes
                print("Fetched from Firestore: \(name) at \(address)")

                // Add delay to avoid rate limiting
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                    print("Attempting to geocode: \(address)")
                    geocodeAddress(address) { coordinate in
                        if let coordinate = coordinate {
                            print("Geocoded: \(name) at \(coordinate.latitude), \(coordinate.longitude)")
                            
                            let location = BusinessLocation(
                                id: UUID(),
                                name: name,
                                coordinate: coordinate,
                                businessStreet: street,
                                businessCity: city,
                                businessState: state
                            )
                            
                            DispatchQueue.main.async {
                                businessLocations.append(location)
                                updateMapRegionIfNeeded()
                            }
                        } else {
                            print("Failed to geocode address: \(address)")
                        }
                    }
                }
            }
        }
    }
    
    // Update map to fit all business locations once they're loaded
    func updateMapRegionIfNeeded() {
        guard !businessLocations.isEmpty else { return }
        
        let coordinates = businessLocations.map { $0.coordinate }
        let minLat = coordinates.map { $0.latitude }.min()!
        let maxLat = coordinates.map { $0.latitude }.max()!
        let minLon = coordinates.map { $0.longitude }.min()!
        let maxLon = coordinates.map { $0.longitude }.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let latitudeDelta = max((maxLat - minLat) * 1.5, 0.05)
        let longitudeDelta = max((maxLon - minLon) * 1.5, 0.05)
        
        let span = MKCoordinateSpan(
            latitudeDelta: latitudeDelta,
            longitudeDelta: longitudeDelta
        )
        
        position = .region(MKCoordinateRegion(center: center, span: span))
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
                UserAnnotation()
                
                // Show all business locations
                ForEach(businessLocations) { location in
                    Marker(location.name, coordinate: location.coordinate)
                        .foregroundStyle(.red)
                }
            }
            .onAppear {
                fetchBusinessLocations()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Business Locations")
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
