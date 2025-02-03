//
//  TermsAndConditionsView.swift
//  BiteBack
//
//  Created by Brian Shon on 2/2/25.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var accepted: Bool

    // A sample Lorem Ipsum text.
    let loremIpsum = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus lacinia odio vitae vestibulum vestibulum. Cras venenatis euismod malesuada.
    
    Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
    
    Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.
    
    (Replace with actual T&C.)
    """

    var body: some View {
        VStack {
            ScrollView {
                Text(loremIpsum)
                    .padding()
            }
            Button("Accept") {
                accepted = true
                dismiss()
            }
            .padding()
            .foregroundColor(Color(red: 1.0, green: 0.65980, blue: 0))
        }
        .navigationTitle("Terms & Conditions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    @State static var accepted = false
    static var previews: some View {
        NavigationStack {
            TermsAndConditionsView(accepted: $accepted)
        }
    }
}

