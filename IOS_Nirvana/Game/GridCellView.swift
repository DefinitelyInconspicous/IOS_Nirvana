//
//  GridCellView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI

struct GridCellView: View {
    let cell: GridCell
    
    private func findFile(type: String, Color: String) -> String {
        print(Color + type)
        return Color + type
    }
    
    var body: some View {
        ZStack {
            if let pathColor = cell.pathColor {
                PipeView(directions: cell.pathDirections)
                    .stroke(pathColor.color, style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
            }
            
            if let node = cell.node {
                switch node.type {
                case .start:
                    let file = findFile(type: "ppl", Color: node.color.color.description)
                    Image(file)
                        .resizable()
                        .frame(width: 150, height: 150)
                case .end:
                    let file = findFile(type: "tree", Color: node.color.color.description)
                    Image(file)
                        .resizable()
                        .frame(width: 120, height: 120)
                }
            }
        }
    }
}
