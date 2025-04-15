// AddMissionView.swift
// BiteBack

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct AddMissionView: View {
    let restaurantName: String

    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: String = ""
    @State private var expiration: String = ""
    @State private var steps: [String] = [""]
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Custom Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.gray)
            }

            Text("Create a Mission")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    GroupBox(label: Text("MISSION DETAILS").fontWeight(.bold)) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                        TextField("Reward", text: $reward)
                        TextField("Expiration Date (YYYY-MM-DD)", text: $expiration)
                    }

                    GroupBox(label: Text("MISSION STEPS").fontWeight(.bold)) {
                        if !steps.isEmpty {
                            ForEach(steps.indices, id: \ .self) { index in
                                HStack {
                                    TextField("Step \(index + 1)", text: $steps[index])
                                    if steps.count > 1 {
                                        Button(action: { steps.remove(at: index) }) {
                                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                        Button(action: { steps.append("") }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Step")
                            }.foregroundColor(.blue)
                        }
                    }

                    GroupBox(label: Text("UPLOAD IMAGE").fontWeight(.bold)) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(12)
                        }

                        Button("Select Image") {
                            isImagePickerPresented.toggle()
                        }
                        .foregroundColor(.blue)
                    }

                    Button(action: addMission) {
                        Text("Add Mission")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(title.isEmpty || description.isEmpty || reward.isEmpty || expiration.isEmpty || selectedImage == nil || steps.contains(where: { $0.isEmpty }))
                }
            }
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
        .navigationBarBackButtonHidden(true)
    }

    func addMission() {
        let db = Firestore.firestore()
        let restaurantRef = db.collection("restaurants")

        restaurantRef.whereField("name", isEqualTo: restaurantName).getDocuments { (snapshot, error) in
            if let snapshot = snapshot, let doc = snapshot.documents.first {
                uploadImage(restaurantId: doc.documentID)
            }
        }
    }

    func uploadImage(restaurantId: String) {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference().child("missions/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if error == nil {
                storageRef.downloadURL { url, _ in
                    if let imageUrl = url?.absoluteString {
                        addMissionToRestaurant(restaurantId: restaurantId, imageUrl: imageUrl)
                    }
                }
            }
        }
    }

    func addMissionToRestaurant(restaurantId: String, imageUrl: String) {
        let db = Firestore.firestore()
        let missionRef = db.collection("restaurants").document(restaurantId).collection("missions").document()

        let missionData: [String: Any] = [
            "title": title,
            "description": description,
            "reward": reward,
            "expiration": expiration,
            "status": "active",
            "imageUrl": imageUrl,
            "steps": steps.isEmpty ? [""] : steps
        ]

        missionRef.setData(missionData) { _ in
            dismiss()
        }
    }

    func clearForm() {
        title = ""
        description = ""
        reward = ""
        expiration = ""
        steps = [""]
        selectedImage = nil
    }
}



    // MARK: - Custom Image Picker

    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            var parent: ImagePicker

            init(parent: ImagePicker) {
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


