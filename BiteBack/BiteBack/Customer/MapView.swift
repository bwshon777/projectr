import SwiftUI
import MapKit
import FirebaseFirestore
import Firebase
import CoreLocation

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
}

// MARK: - Models
struct BusinessLocation: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let businessStreet: String
    let businessCity: String
    let businessState: String
}

struct BusinessMission: Identifiable {
    let id: String
    let title: String
    let description: String
    let reward: String
}

// MARK: - MapView
struct MapView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var position: MapCameraPosition = .automatic
    @State private var businessLocations: [BusinessLocation] = []
    @State private var isLoading: Bool = true
    @State private var selectedBusiness: BusinessLocation? = nil
    @State private var showingMissionSheet = false
    @State private var missions: [BusinessMission] = []
    @State private var route: MKRoute? = nil
    @State private var hasSetInitialRegion = false  // 👈 NEW

    private let geocoder = CLGeocoder()

    func isValidBusinessData(_ data: [String: Any]) -> Bool {
        return data["businessName"] != nil &&
               data["businessStreet"] != nil &&
               data["businessCity"] != nil &&
               data["businessState"] != nil
        
    }

    func parseBusiness(from data: [String: Any]) -> (String, String, String, String)? {
        guard
            let name = data["businessName"],
            let street = data["businessStreet"],
            let city = data["businessCity"],
            let state = data["businessState"]
        else {
            print("❌ Missing field in: \(data)")
            return nil
        }

        let nameStr = String(describing: name)
        let streetStr = String(describing: street)
        let cityStr = String(describing: city)
        let stateStr = String(describing: state)

        print("✅ Parsed business: name=\(nameStr), street=\(streetStr), city=\(cityStr), state=\(stateStr)")

        return (nameStr, streetStr, cityStr, stateStr)
    }
    
    func fetchBusinessLocations() {
        let db = Firestore.firestore()
        businessLocations = []
        isLoading = true

        db.collection("users")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching users: \(error.localizedDescription)")
                    isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No user documents found.")
                    isLoading = false
                    return
                }

                var validBusinesses: [(String, String, String, String)] = []

                for document in documents {
                    let data = document.data()
                    print("Raw data:", data)

                    guard data["mode"] as? String == "business" else {
                        continue
                    }

                    if let (name, street, city, state) = parseBusiness(from: data) {
                        validBusinesses.append((name, street, city, state))
                    } else {
                        print("Skipping document: invalid business data")
                    }
                }

                if validBusinesses.isEmpty {
                    print("❌ No valid business addresses to geocode.")
                    isLoading = false
                    return
                }

                var completedCount = 0
                for (i, (name, street, city, state)) in validBusinesses.enumerated() {
                    let address = "\(street), \(city), \(state)"
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: "’", with: "'")

                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                        print("📍 Attempting to geocode:", address)
                        geocodeAddress(address) { coordinate in
                            completedCount += 1

                            if let coordinate = coordinate {
                                let location = BusinessLocation(
                                    name: name,
                                    coordinate: coordinate,
                                    businessStreet: street,
                                    businessCity: city,
                                    businessState: state
                                )
                                DispatchQueue.main.async {
                                    businessLocations.append(location)
                                    print("🟢 Added to map: \(name)")
                                }
                            } else {
                                print("❌ Geocoding failed for: \(address)")
                            }

                            if completedCount == validBusinesses.count {
                                DispatchQueue.main.async {
                                    print("✅ All geocoding complete. Found \(businessLocations.count) locations.")
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
            }
    }


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
                completion(nil)
            }
        }
    }

    func fetchMissions(for restaurantName: String) {
        let db = Firestore.firestore()
        db.collection("restaurants")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching restaurants: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                for document in documents {
                    let data = document.data()
                    if let name = data["name"] as? String, name == restaurantName {
                        db.collection("restaurants")
                            .document(document.documentID)
                            .collection("missions")
                            .getDocuments { missionSnapshot, error in
                                if let error = error {
                                    print("Error fetching missions: \(error)")
                                    return
                                }

                                missions = missionSnapshot?.documents.compactMap { doc in
                                    let data = doc.data()
                                    return BusinessMission(
                                        id: doc.documentID,
                                        title: data["title"] as? String ?? "Untitled",
                                        description: data["description"] as? String ?? "",
                                        reward: data["reward"] as? String ?? "0"
                                    )
                                } ?? []

                                showingMissionSheet = true
                            }
                        break
                    }
                }
            }
    }

    func getDirections(to destination: CLLocationCoordinate2D) {
        guard let userLocation = locationManager.userLocation else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.route = route
                position = .region(MKCoordinateRegion(
                    center: destination,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            } else {
                print("Failed to get route: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading nearby businesses...")
                    .padding()
            } else {
                Map(position: $position) {
                    UserAnnotation()

                    ForEach(businessLocations) { location in
                        Annotation("", coordinate: location.coordinate) {
                            VStack(spacing: 4) {
                                Button(action: {
                                    selectedBusiness = location
                                    fetchMissions(for: location.name)
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "building.2.crop.circle")
                                            .resizable()
                                            .frame(width: 28, height: 28)
                                            .foregroundColor(.red)
                                        Text(location.name)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.white.opacity(0.8))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }

                    if let route = route {
                        MapPolyline(route.polyline)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }

                if route != nil {
                    Button(action: {
                        route = nil
                    }) {
                        Text("Clear Route")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .onAppear {
            fetchBusinessLocations()
        }
        .onChange(of: "\(locationManager.userLocation?.latitude ?? 0),\(locationManager.userLocation?.longitude ?? 0)") { _ in
            guard let newLocation = locationManager.userLocation, !hasSetInitialRegion else { return }

            position = .region(MKCoordinateRegion(
                center: newLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
            hasSetInitialRegion = true
        }

        .sheet(isPresented: $showingMissionSheet) {
            NavigationView {
                VStack(spacing: 0) {
                    Text(selectedBusiness?.name ?? "Missions")
                        .font(.title2).bold()
                        .padding(.top)

                    Divider()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(missions) { mission in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(mission.title)
                                        .font(.headline)
                                    Text(mission.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Text("Reward: \(mission.reward)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }

                            if let destination = selectedBusiness?.coordinate {
                                Button(action: {
                                    getDirections(to: destination)
                                    showingMissionSheet = false
                                }) {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "location.fill")
                                        Text("Get Directions")
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .padding(.top)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Business Locations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

