//

//  MapView.swift

//  BiteBack

//

//  Created by Utsav Talati on 3/16/25

//



import SwiftUI

import MapKit



struct MapView: View {

    @State private var position: MapCameraPosition = .region(

        MKCoordinateRegion(

            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example Location (San Francisco)

            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

        )

    )



    var body: some View {

        Map(position: $position) {

            UserAnnotation() // Shows user's current location

        }

        .mapControls {

            MapUserLocationButton() // Button to center on user location

            MapCompass() // Adds compass UI

        }

        .edgesIgnoringSafeArea(.all)

        .navigationTitle("Nearby Restaurants")

        .navigationBarTitleDisplayMode(.inline)

    }

}



struct MapView_Previews: PreviewProvider {

    static var previews: some View {

        NavigationStack {

            MapView()

        }

    }

}

