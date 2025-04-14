import SwiftUI
import CodeScanner
import CoreImage.CIFilterBuiltins
import FirebaseAuth
import FirebaseFirestore

// MARK: - QR Code Generator

let context = CIContext()
let filter = CIFilter.qrCodeGenerator()

func generateQRCode(from string: String) -> UIImage {
    let data = Data(string.utf8)
    filter.setValue(data, forKey: "inputMessage")

    if let outputImage = filter.outputImage {
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        if let cgimg = context.createCGImage(scaledImage, from: scaledImage.extent) {
            return UIImage(cgImage: cgimg)
        }
    }

    return UIImage(systemName: "xmark.circle") ?? UIImage()
}

// MARK: - Mission Detail View

struct MissionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    let mission: Mission
    @State private var currentStep = 0
    @State private var showQRCode = false
    @State private var voucherId: String = ""
    @State private var qrImage: UIImage? = nil
    @State private var hasLoadedCompletionStatus = false


    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            if !showQRCode {
                if mission.steps.isEmpty {
                    VStack {
                        Text("No mission steps available.")
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Return to Home")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                } else {
                    Text("Step \(currentStep + 1) of \(mission.steps.count)")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    VStack(spacing: 15) {
                        Image(systemName: "checkmark.seal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)

                        Text(mission.steps[currentStep])
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)

                    HStack(spacing: 8) {
                        ForEach(0..<mission.steps.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentStep ? Color.blue : Color.gray.opacity(0.4))
                                .frame(width: 10, height: 10)
                        }
                    }

                    Button(action: {
                        if currentStep < mission.steps.count - 1 {
                            currentStep += 1
                        } else {
                            handleMissionCompletion()
                        }
                    }) {
                        Text(currentStep < mission.steps.count - 1 ? "Next Step" : "Complete & Show QR")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            } else {
                VStack(spacing: 20) {
                    Text("Show this QR code to redeem your reward")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()

                    if let qrImage = qrImage {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                    }
                    
                    Divider()
                        .padding(.horizontal, 50)

                    Text("VOUCHER ID")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(voucherId)
                        .font(.headline)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        
        .onAppear {
            if !hasLoadedCompletionStatus {
                checkIfAlreadyCompleted()
                hasLoadedCompletionStatus = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func checkIfAlreadyCompleted() {
        guard let userId = Auth.auth().currentUser?.uid,
              let missionId = mission.id else { return }

        let ref = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("completedMissions")
            .document(missionId)

        ref.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let existingVoucher = data["voucherId"] as? String {
                self.voucherId = existingVoucher
                self.qrImage = generateQRCode(from: existingVoucher)
                self.showQRCode = true
            }
        }
    }


    func handleMissionCompletion() {
        guard let userId = Auth.auth().currentUser?.uid,
              let missionId = mission.id else {
            print("Missing user ID or mission ID")
            return
        }

        let voucher = generateVoucherID(userId: userId, missionId: missionId)
        self.voucherId = voucher
        self.qrImage = generateQRCode(from: voucher)
        saveQRCodeToFirestore(voucherId: voucher)
        self.showQRCode = true
    }

    func generateVoucherID(userId: String, missionId: String) -> String {
        let shortUser = userId.prefix(5).uppercased()
        let shortMission = missionId.prefix(5).uppercased()
        let random = UUID().uuidString.prefix(4).uppercased()
        return "\(shortUser)-\(shortMission)-\(random)"
    }

    func saveQRCodeToFirestore(voucherId: String) {
        guard let userId = Auth.auth().currentUser?.uid,
              let missionId = mission.id else { return }

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "restaurantId": mission.restaurantId ?? "",
            "missionTitle": mission.title,
            "qrCode": voucherId,
            "voucherId": voucherId,
            "redeemed": false,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("users")
            .document(userId)
            .collection("completedMissions")
            .document(missionId)
            .setData(data) { error in
                if let error = error {
                    print("Error saving QR data: \(error.localizedDescription)")
                } else {
                    print("✅ QR data saved for mission \(missionId)")
                }
            }
    }
}
