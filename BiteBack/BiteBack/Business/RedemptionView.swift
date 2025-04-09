import SwiftUI
import CodeScanner
import FirebaseFirestore

struct RedemptionView: View {
    @State private var isPresentingScanner = false
    @State private var scannedCode: String = ""
    @State private var showMessage = false
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Redeem Customer Rewards")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)


            Button(action: {
                isPresentingScanner = true
            }) {
                Label("Scan QR Code", systemImage: "qrcode.viewfinder")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()

            if showMessage {
                Text(message)
                    .foregroundColor(message.contains("successfully") ? .green : .red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .padding()
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr], completion: handleScan)
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        isPresentingScanner = false

        switch result {
        case .success(let scan):
            scannedCode = scan.string
            validateAndRedeemVoucher(voucherId: scannedCode)
        case .failure:
            message = "Failed to scan the QR code."
            showMessage = true
        }
    }

    func validateAndRedeemVoucher(voucherId: String) {
        let db = Firestore.firestore()
        let query = db.collectionGroup("completedMissions").whereField("voucherId", isEqualTo: voucherId)

        query.getDocuments { snapshot, error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
                showMessage = true
                return
            }

            guard let document = snapshot?.documents.first else {
                message = "No matching voucher found."
                showMessage = true
                return
            }

            let data = document.data()
            if let redeemed = data["redeemed"] as? Bool, redeemed == true {
                message = "Voucher already redeemed."
                showMessage = true
                return
            }

            document.reference.updateData(["redeemed": true]) { err in
                if let err = err {
                    message = "Error redeeming voucher: \(err.localizedDescription)"
                } else {
                    message = "Voucher redeemed successfully!"
                }
                showMessage = true
            }
        }
    }
}



