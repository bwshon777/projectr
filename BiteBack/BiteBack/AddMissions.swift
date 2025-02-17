//
//  AddMissions.swift
//  BiteBack
//
//  Created by Nicholas Pacella on 2/16/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI  // For Image Picker

struct AddMissionView: View {
    @State private var restaurantName: String = ""
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var reward: String = ""
    @State private var expiration: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Restaurant Details")) {
                    TextField("Restaurant Name", text: $restaurantName)
                }

                Section(header: Text("Mission Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Reward", text: $reward)
                    TextField("Expiration Date (YYYY-MM-DD)", text: $expiration)
                }

                Section(header: Text("Upload Image")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }

                    Button("Select Image") {
                        isImagePickerPresented.toggle()
                    }
                }

                Button(action: addMission) {
                    Text("Add Mission")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(restaurantName.isEmpty || title.isEmpty || description.isEmpty || reward.isEmpty || expiration.isEmpty || selectedImage == nil)
            }
            .navigationTitle("Create a Mission")
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    func addMission() {
        let db = Firestore.firestore()
        let restaurantRef = db.collection("restaurants")

        restaurantRef.whereField("name", isEqualTo: restaurantName).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error checking restaurant: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot, !snapshot.documents.isEmpty {
                let existingRestaurantId = snapshot.documents.first!.documentID
                uploadImage(restaurantId: existingRestaurantId)
            } else {
                let newRestaurantRef = restaurantRef.document()
                newRestaurantRef.setData(["name": restaurantName]) { error in
                    if let error = error {
                        print("Error creating restaurant: \(error.localizedDescription)")
                    } else {
                        print("New restaurant created!")
                        uploadImage(restaurantId: newRestaurantRef.documentID)
                    }
                }
            }
        }
    }

    func uploadImage(restaurantId: String) {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference().child("missions/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting image URL: \(error.localizedDescription)")
                    return
                }

                if let imageUrl = url?.absoluteString {
                    addMissionToRestaurant(restaurantId: restaurantId, imageUrl: imageUrl)
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
            "imageUrl": imageUrl
        ]

        missionRef.setData(missionData) { error in
            if let error = error {
                print("Error adding mission: \(error.localizedDescription)")
            } else {
                print("Mission successfully added!")
                clearForm()
            }
        }
    }

    func clearForm() {
        restaurantName = ""
        title = ""
        description = ""
        reward = ""
        expiration = ""
        selectedImage = nil
    }
}

// Custom Image Picker
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

struct AddMissionView_Preview: PreviewProvider {
    static var previews: some View {
        AddMissionView()
    }
}

