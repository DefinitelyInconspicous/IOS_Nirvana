//
//  MainView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 14/7/25.
//

import SwiftUI

struct MainView: View {
    @State private var selectedLanguage: Language? = nil
    @State private var showStoryView: Bool = false
    @State private var showHomeView: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("The Legend  ")
                    .font(Font.custom("Caveat", size: 250))

                HStack {
                    Text("of  ")
                        .font(Font.custom("Caveat", size: 56))

                    Text("RE")
                        .font(Font.custom("CaesarDressing", size: 74))

                    Button {
                        if selectedLanguage != nil {
                            showStoryView = true
                        }
                    } label: {
                        Text("⫸")
                            .font(Font.custom("CaesarDressing", size: 100))
                    }

                    Text("HILL")
                        .font(Font.custom("CaesarDressing", size: 74))
                }

                Text("Click to enter")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.gray)
                    .padding(.top, 5)

                Button {
                    showHomeView = true
                } label: {
                    Text("SELECT A LANGUAGE")
                        .font(Font.custom("CaesarDressing-Regular", size: 18))
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .padding(.top, 20)

                NavigationLink("", value: selectedLanguage)
                    .opacity(0)
            }
            .multilineTextAlignment(.center)
            .padding()
            .navigationDestination(isPresented: $showHomeView) {
                HomeView(selectedLanguage: $selectedLanguage)
            }
            .navigationDestination(isPresented: $showStoryView) {
                if let lang = selectedLanguage {
                    StoryView(language: lang)
                }
            }
        }
    }
}

#Preview {
    MainView()
}
