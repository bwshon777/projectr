import SwiftUI
import FirebaseFirestore

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ApproveMissionView: View {
    let documentRef: DocumentReference
    let stepProofs: [String]

    @Environment(\.dismiss) var dismiss
    @State private var isRedeeming = false
    @State private var showMessage = false
    @State private var message = ""
    @State private var selectedImageURL: IdentifiableURL? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.gray)
            }

            Text("Review Mission Proofs")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(stepProofs, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedImageURL = IdentifiableURL(url: url)
                                    }
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }

                    Button(action: approveMission) {
                        if isRedeeming {
                            ProgressView()
                        } else {
                            Text("Approve & Redeem")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.0, green: 0.698, blue: 1.0))
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
        .padding()
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedImageURL) { identifiable in
            ZStack {
                Color.black.ignoresSafeArea()
                AsyncImage(url: identifiable.url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            selectedImageURL = nil
                        }
                } placeholder: {
                    ProgressView()
                        .foregroundColor(.white)
                }
            }
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
