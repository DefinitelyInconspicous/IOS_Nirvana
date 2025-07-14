//
//  OnboardingView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Redhill!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                OnboardingStep(
                    number: 1,
                    text: "Connect the correct villager and drag him to the correct tree! You cannot drag through trees, other villagers, or their paths! You can click on the villager to restart the path."
                )
                
                OnboardingStep(
                    number: 2,
                    text: "When you successfully bring a villager to their tree, you will receive a historical fact about Redhill!"
                )
                
                OnboardingStep(
                    number: 3,
                    text: "Remember, you have to match the colours - but don't forget to drag the villager to the tree, and not the tree to the villager!"
                )
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            Text("Good Luck!")
                .font(.title2)
                .bold()
                .padding(.bottom, 20)
            
            Button("Let's Start!") {
                dismiss()
            }
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}
