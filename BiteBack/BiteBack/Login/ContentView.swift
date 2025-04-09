//
//  ContentView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            LoginView() // Presents the login view
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
