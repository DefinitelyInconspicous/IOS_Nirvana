//
//  OnboardingStep.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI
struct OnboardingStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text("\(number)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
    }
}
