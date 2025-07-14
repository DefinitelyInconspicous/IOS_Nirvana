//
//  TipView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI

struct TipView: View {
    let tip: Tip
    var body: some View {
        VStack(spacing: 24) {
            Text(tip.title)
                .font(.title)
                .bold()
                .padding()
            Text(tip.content)
                .font(.body)
            Spacer()
        }
        .padding()
    }
}
