//
//  PipeView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI

struct PipeView: Shape {
    let directions: Set<Direction>

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        for direction in directions {
            path.move(to: center)
            switch direction {
            case .up:
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            case .down:
                path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            case .left:
                path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            case .right:
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            }
        }
        return path
    }
}
