//
//  BusinessTabView.swift
//  BiteBack
//
//  Created by Neel Gundavarapu on 3/17/25.
//

import SwiftUI

struct BusinessTabView: View {
    var businessName: String
    var body: some View {
        TabView {
            BusinessProfileView(businessName: businessName)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            RedemptionView()
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Redeem")
                }

            BusinessSettingsView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
        .accentColor(Color(red: 0.0, green: 0.698, blue: 1.0))
    }
}

