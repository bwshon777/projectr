// Created by Utsav Talati 

import SwiftUI

import MapKit



struct FastFoodLocation: Identifiable {

    let id = UUID()

    let name: String

    let coordinate: CLLocationCoordinate2D

}



struct MapView: View {

    // Setting initial location to Vanderbilt University's coordinates because i want to see if this works

    @State private var position: MapCameraPosition = .region(

        MKCoordinateRegion(

            center: CLLocationCoordinate2D(latitude: 36.1447, longitude: -86.8021), // Vanderbilt University

            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Adjust zoom level

        )

    )

    

    // locations near vanderbilt in case we can't get it to work in time for the demo lol but eventually we will store these and retrieve them which requires us to change how we let restaurants sign up for the app

    @State private var fastFoodLocations = [

        FastFoodLocation(

            name: "Satay",

            coordinate: CLLocationCoordinate2D(latitude: 36.148317, longitude: -86.808000)

        ),

        FastFoodLocation(

            name: "Oscar's Taco Shop",

            coordinate: CLLocationCoordinate2D(latitude: 36.148918, longitude: -86.806122)

        ),

        FastFoodLocation(

            name: "Bella Italia",

            coordinate: CLLocationCoordinate2D(latitude: 36.142716, longitude: -86.791676)

        ),

        FastFoodLocation(

            name: "Inchin's Bamboo Garden",

            coordinate: CLLocationCoordinate2D(latitude: 36.153069, longitude: -86.796227)

        ),

        FastFoodLocation(

            name: "Hopdoddy",

            coordinate: CLLocationCoordinate2D(latitude: 36.136330, longitude: -86.801399)

        )

    ]



    var body: some View {

        Map(position: $position) {

            UserAnnotation() // Optional, will show the user's location

            

            // Add markers

            ForEach(fastFoodLocations) { location in

                Marker(location.name, coordinate: location.coordinate)

                    .tint(.red) // Make the markers red

            }

        }

        .mapControls {

            MapUserLocationButton() // Button to re-center on user location

            MapCompass() //

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
