import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreImage.CIFilterBuiltins

// MARK: - QR Code Generator

let context = CIContext()
let filter = CIFilter.qrCodeGenerator()

func generateQRCode(from string: String) -> UIImage {
    let data = Data(string.utf8)
    filter.setValue(data, forKey: "inputMessage")
    if let outputImage = filter.outputImage {
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        if let cgimg = context.createCGImage(scaled, from: scaled.extent) {
            return UIImage(cgImage: cgimg)
        }
    }
    return UIImage(systemName: "xmark.circle") ?? UIImage()
}

// MARK: - Custom Image Picker

struct StepScreenshotPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: StepScreenshotPicker

        init(parent: StepScreenshotPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct MissionDetailView: View {
    @Environment(\.dismiss) var dismiss
    let mission: Mission

    @State private var currentStep = 0
    @State private var showQRCode = false
    @State private var voucherId = ""
    @State private var qrImage: UIImage? = nil
    @State private var stepScreenshots: [UIImage?]
    @State private var isImagePickerPresented = false
    @State private var selectedStepIndex = 0
    @State private var hasLoadedCompletionStatus = false
    
    init(mission: Mission) {
          self.mission = mission
          _stepScreenshots = State(initialValue: Array(repeating: nil, count: mission.steps.count))
      }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            if !showQRCode {
                if mission.steps.isEmpty {
                    emptyMissionView
                } else {
                    stepProgressView
                }
            } else {
                qrCodeView
            }

            Spacer()
        }
        .padding()
        .onAppear {
            stepScreenshots = Array(repeating: nil, count: mission.steps.count)
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: Binding(
                get: { stepScreenshots[selectedStepIndex] },
                set: { stepScreenshots[selectedStepIndex] = $0 }
            ))
        }
        
        .onAppear {
            if !hasLoadedCompletionStatus {
                checkIfAlreadyCompleted()
                hasLoadedCompletionStatus = true
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    var emptyMissionView: some View {
        VStack {
            Text("No mission steps available.")
                .foregroundColor(.gray)
                .padding(.bottom, 10)

            Button("Return to Home") {
                dismiss()
            }
            .fontWeight(.semibold)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    var stepProgressView: some View {
        VStack(spacing: 20) {
            Text("Step \(currentStep + 1) of \(mission.steps.count)")
                .font(.subheadline)
                .foregroundColor(.blue)

            VStack(spacing: 6) {
                Text(mission.steps[currentStep].description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                let link = mission.steps[currentStep].link
                if !link.isEmpty {
                    Link("Visit Link", destination: URL(string: link)!)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                        .padding(.top, 4)
                }
            }
            .padding(.vertical)

            if let screenshot = stepScreenshots[currentStep] {
                Image(uiImage: screenshot)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
            }

            Button("Upload Screenshot Verification") {
                selectedStepIndex = currentStep
                isImagePickerPresented = true
            }
            .foregroundColor(.blue)

            HStack(spacing: 16) {
                // Back step or Exit button
                Button(action: {
                    if currentStep == 0 {
                        dismiss() // Exit to home if it's the first step
                    } else {
                        currentStep -= 1 // Go to previous step
                    }
                }) {
                    Text(currentStep == 0 ? "Exit" : "Back")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                }

                // Next or Complete button
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
                        .background(stepScreenshots[currentStep] == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(stepScreenshots[currentStep] == nil)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
        .shadow(radius: 5)
    }

    var qrCodeView: some View {
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

            Divider().padding(.horizontal, 50)
            Text("VOUCHER ID").font(.caption).foregroundColor(.gray)
            Text(voucherId).font(.headline).fontWeight(.bold).multilineTextAlignment(.center)

            Button(action: {dismiss()} ) {
                Text("Done")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
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
        guard let userId = Auth.auth().currentUser?.uid, let missionId = mission.id else { return }

        let voucher = generateVoucherID(userId: userId, missionId: missionId)
        self.voucherId = voucher
        self.qrImage = generateQRCode(from: voucher)

        uploadScreenshots(userId: userId, missionId: missionId, voucherId: voucher)
    }

    func uploadScreenshots(userId: String, missionId: String, voucherId: String) {
        let storage = Storage.storage()
        let db = Firestore.firestore()
        var uploadedURLs: [String] = []
        let dispatchGroup = DispatchGroup()

        for (index, screenshot) in stepScreenshots.enumerated() {
            guard let imageData = screenshot?.jpegData(compressionQuality: 0.8) else { continue }
            dispatchGroup.enter()
            let ref = storage.reference().child("proofs/\(userId)/\(missionId)/step\(index).jpg")
            ref.putData(imageData, metadata: nil) { _, error in
                if error == nil {
                    ref.downloadURL { url, _ in
                        if let urlStr = url?.absoluteString {
                            uploadedURLs.append(urlStr)
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            let data: [String: Any] = [
                "restaurantId": mission.restaurantId ?? "",
                "missionTitle": mission.title,
                "qrCode": voucherId,
                "voucherId": voucherId,
                "redeemed": false,
                "stepProofs": uploadedURLs,
                "timestamp": FieldValue.serverTimestamp()
            ]

            db.collection("users").document(userId).collection("completedMissions").document(missionId).setData(data) { err in
                if err == nil {
                    showQRCode = true
                }
            }
        }
    }

    func generateVoucherID(userId: String, missionId: String) -> String {
        let shortUser = userId.prefix(5).uppercased()
        let shortMission = missionId.prefix(5).uppercased()
        let random = UUID().uuidString.prefix(4).uppercased()
        return "\(shortUser)-\(shortMission)-\(random)"
    }
}

