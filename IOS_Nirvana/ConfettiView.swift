//
//  ConfettiView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 20/7/25.
//


import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple]

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    var contextCopy = context
                    let rect = CGRect(x: particle.x, y: particle.y, width: 10, height: 10)
                    contextCopy.fill(Path(ellipseIn: rect), with: .color(particle.color))
                }
            }
            .onAppear {
                withAnimation {
                    generateParticles()
                }
            }
        }
    }

    func generateParticles() {
        particles = (0..<100).map { _ in
            ConfettiParticle(
                x: Double.random(in: 0...UIScreen.main.bounds.width),
                y: Double.random(in: -200...0),
                speed: Double.random(in: 1...4),
                color: colors.randomElement()!
            )
        }

        // Animate falling
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            for i in particles.indices {
                particles[i].y += particles[i].speed
                if particles[i].y > UIScreen.main.bounds.height {
                    particles[i].y = Double.random(in: -200...0)
                    particles[i].x = Double.random(in: 0...UIScreen.main.bounds.width)
                }
            }
        }
    }
}

struct ConfettiParticle {
    var x: Double
    var y: Double
    var speed: Double
    var color: Color
}
