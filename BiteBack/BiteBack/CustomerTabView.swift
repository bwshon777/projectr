//
//  CustomerTabView.swift
//  BiteBack
//
//  Created by Neel Gundavarapu on 3/18/25.
//

import SwiftUI

struct CustomerTabView: View {
    var userName: String

    var body: some View {
        TabView {
            MissionsPageView(userName: userName)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            ExploreView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Explore")
                }

            CustomerProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

struct CustomerTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomerTabView(userName: "Test User")
    }
}

