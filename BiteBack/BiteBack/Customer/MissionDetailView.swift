import SwiftUI
import CodeScanner

struct MissionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss

    let mission: Mission
    @State private var currentStep = 0
    @State private var showQRCode = false

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
                                .background(Color(red: 0.0, green: 0.698, blue: 1.0))
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
                            showQRCode = true
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

                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .overlay(Text("QR Code").foregroundColor(.gray))

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
        .navigationBarBackButtonHidden(true)
    }
}


