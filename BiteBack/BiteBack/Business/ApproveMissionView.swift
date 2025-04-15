//
//  ApproveMissionView.swift
//  BiteBack
//
//  Created by Neel Gundavarapu on 4/15/25.
//

import SwiftUI
import FirebaseFirestore

struct ApproveMissionView: View {
    let documentRef: DocumentReference
    let stepProofs: [String]

    @Environment(\.dismiss) var dismiss
    @State private var isRedeeming = false
    @State private var showMessage = false
    @State private var message = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Review Mission Proofs")
                    .font(.title2)
                    .bold()

                ForEach(stepProofs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { image in
                        image.resizable()
                             .scaledToFit()
                             .frame(height: 200)
                             .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                    }
                }

                Button(action: approveMission) {
                    if isRedeeming {
                        ProgressView()
                    } else {
                        Text("Approve & Redeem")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                if showMessage {
                    Text(message)
                        .foregroundColor(message.contains("success") ? .green : .red)
                        .padding()
                }
            }
            .padding()
        }
    }

    func approveMission() {
        isRedeeming = true
        documentRef.updateData(["redeemed": true]) { error in
            isRedeeming = false
            if let error = error {
                message = "Failed to redeem: \(error.localizedDescription)"
            } else {
                message = "Mission successfully redeemed!"
            }
            showMessage = true
        }
    }
}

