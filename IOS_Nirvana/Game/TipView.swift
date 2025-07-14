//
//  TipView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI

struct TipView: View {
    let tip: Tip
    @Binding var language: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: tip.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(.primary)

            Text(tip.localizedTitle(for: language))
                .font(.headline)

            Text(tip.localizedContent(for: language))
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

