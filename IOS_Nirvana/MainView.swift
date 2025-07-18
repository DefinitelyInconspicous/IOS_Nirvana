//
//  MainView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 14/7/25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("The Legend")
                .font(Font.custom("Caveat", size: 48))
            
            Text("of")
                .font(Font.custom("Caveat-Bold", size: 42))
                .padding(.bottom, 10)

            Text("RED⫸HILL")
                .font(Font.custom("CaesarDressing-Regular", size: 54))

            Text("Click to enter")
                .font(.caption)
                .italic()
                .foregroundColor(.gray)
                .padding(.top, 5)

            Button(action: {
                // Handle language selection
            }) {
                Text("SELECT A LANGUAGE")
                    .font(Font.custom("CaesarDressing-Regular", size: 18))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black, lineWidth: 2)
                    )
            }
            .padding(.top, 20)
        }
        .multilineTextAlignment(.center)
        .padding()
        .onAppear() {
            for family in UIFont.familyNames.sorted() {
                print("Family: \(family)")
                for name in UIFont.fontNames(forFamilyName: family) {
                    print(" - \(name)")
                }
            }
        }
    }
        
}

#Preview {
    MainView()
}

