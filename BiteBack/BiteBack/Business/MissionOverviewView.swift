//
//  MissionOverviewView.swift
//  BiteBack
//
//  Created by Neel Gundavarapu on 4/16/25.
//
import SwiftUI
import FirebaseFirestore
 
 struct MissionOverviewView: View {
     @Environment(\.dismiss) var dismiss
 
     @Binding var mission: Mission
     let restaurantId: String
 
     @State private var completionCount: Int = 0
     @State private var redemptionCount: Int = 0
     @State var shouldDismissToBusiness = false
 
     var body: some View {
         VStack {
             headerSection
             contentSection
         }
         .padding([.horizontal, .bottom])
         .background(Color(.systemGroupedBackground))
         .onAppear(perform: fetchMissionStats)
         .onChange(of: shouldDismissToBusiness) { shouldDismiss in
             if shouldDismiss {
                 dismiss()
             }
         }
         .navigationBarBackButtonHidden(true)
     }
 
     var headerSection: some View {
         VStack(alignment: .leading, spacing: 12) {
             // Push everything up into the safe area
             HStack {
                 Button(action: { dismiss() }) {
                     Image(systemName: "arrow.left")
                         .foregroundColor(.gray)
                         .font(.title2)
                         .padding(.leading, 4) // nudges it left a bit
                 }
                 Spacer()
             }

             Text("Mission Overview")
                 .font(.largeTitle)
                 .fontWeight(.bold)
                 .padding(.horizontal, 4)
         }
         .padding(.top, 10) // Adjust this for how high up you want it
     }
 
     var contentSection: some View {
         ScrollView {
             VStack(spacing: 30) {
                 missionDetailCard
                 statsCard
                 editButton
             }
             .padding(.bottom)
         }
     }
 
     var missionDetailCard: some View {
         VStack(alignment: .leading, spacing: 20) {
             detailRow(icon: "textformat", text: mission.title)
             detailRow(icon: "doc.text", text: mission.description)
             detailRow(icon: "giftcard.fill", text: mission.reward)
 
             if let expiration = mission.expiration {
                 detailRow(icon: "calendar", text: expiration)
             }
 
             VStack(alignment: .leading, spacing: 12) {
                 HStack(spacing: 12) {
                     Image(systemName: "list.bullet.rectangle")
                         .foregroundColor(.blue)
                     Text("Steps")
                         .font(.body)
                 }
 
                 ForEach(mission.steps.indices, id: \.self) { i in
                     HStack(spacing: 12) {
                         Image(systemName: "checkmark.circle")
                             .foregroundColor(.blue)
                         Text("Step \(i + 1): \(mission.steps[i].description)")
                             .font(.body)
                     }
                 }
             }
         }
         .frame(maxWidth: .infinity, alignment: .leading)
         .padding()
         .background(Color.white)
         .cornerRadius(20)
         .shadow(color: .gray.opacity(0.1), radius: 8)
     }
 
     func detailRow(icon: String, text: String) -> some View {
         HStack(alignment: .top, spacing: 12) {
             Image(systemName: icon)
                 .foregroundColor(.blue)
             Text(text)
                 .font(.body)
         }
     }
 
     var statsCard: some View {
         HStack(spacing: 40) {
             VStack(spacing: 8) {
                 Image(systemName: "checkmark.seal.fill")
                     .foregroundColor(.green)
                     .font(.title)

                 Text("Completed by")
                     .font(.caption)
                     .foregroundColor(.gray)

                 Text("\(completionCount) users")
                     .font(.title2)
                     .fontWeight(.medium)
             }
             .frame(maxWidth: .infinity)

             VStack(spacing: 8) {
                 Image(systemName: "gift.fill")
                     .foregroundColor(.red)
                     .font(.title)

                 Text("Redeemed by")
                     .font(.caption)
                     .foregroundColor(.gray)

                 Text("\(redemptionCount) users")
                     .font(.title2)
                     .fontWeight(.medium)
             }
             .frame(maxWidth: .infinity)
         }
         .padding(24)
         .frame(maxWidth: .infinity)
         .background(Color.white)
         .cornerRadius(20)
         .shadow(color: .gray.opacity(0.2), radius: 10)
     }
 
     var editButton: some View {
         NavigationLink(destination: EditMissionView(mission: $mission, shouldDismissToBusiness: $shouldDismissToBusiness, restaurantId: restaurantId)) {
             Text("Edit Mission")
                 .frame(maxWidth: .infinity)
                 .padding()
                 .background(Color(red: 0.0, green: 0.698, blue: 1.0))
                 .foregroundColor(.white)
                 .cornerRadius(12)
         }
     }
 
     func fetchMissionStats() {
         let db = Firestore.firestore()
         db.collectionGroup("completedMissions")
             .whereField("missionTitle", isEqualTo: mission.title)
             .getDocuments { snapshot, error in
                 guard let documents = snapshot?.documents else { return }
 
                 completionCount = documents.count
                 redemptionCount = documents.filter { ($0["redeemed"] as? Bool) == true }.count
             }
     }
 }

