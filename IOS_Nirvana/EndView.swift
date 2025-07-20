//
//  EndView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 9/7/25.
//

import SwiftUI

struct EndView: View {
    @State private var showConfetti = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("🎉 Congratulations! 🎉")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("You’ve discovered the story of Redhill. \n Please inform your teacher for further instructions.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                    
                    NavigationLink {
                        MainView()
                    } label: {
                        Text("Return to Main Menu")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                
                if showConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        
        }
    }
}


#Preview {
    EndView()
}
