//
//  HomeView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 20/7/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedLanguage: Language?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 30)

            VStack(spacing: 8) {
                Text("Choose a Language")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
            }

            Spacer()

            ForEach(Language.allCases) { lang in
                Button {
                    selectedLanguage = lang
                    dismiss()
                } label: {
                    HStack {
                        Spacer()
                        Text(lang.rawValue)
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding()

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.vertical)
    }
}
