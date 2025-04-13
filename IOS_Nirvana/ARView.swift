//
//  ARView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 13/4/25.
//

import SwiftUI
import RealityKit
import ARKit
import AVFoundation

struct ARViewContainer: UIViewRepresentable {
    @Binding var hasTapped: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(hasTapped: $hasTapped)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.vertical]
        config.environmentTexturing = .automatic
        arView.session.run(config)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    class Coordinator: NSObject {
        var arView: ARView?
        var currentVideoAnchor: AnchorEntity?
        var fishEntities: [Entity] = []
        var fishTimer: Timer?
        @Binding var hasTapped: Bool

        init(hasTapped: Binding<Bool>) {
            _hasTapped = hasTapped
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = arView else { return }
            hasTapped = true  // ✅ Hide overlay on first tap


            let tapLocation = sender.location(in: arView)

            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .vertical)
            guard let raycastResult = results.first else {
                print("No vertical surface found.")
                return
            }

            // Remove previous video
            if let existingAnchor = currentVideoAnchor {
                arView.scene.anchors.remove(existingAnchor)
            }

            // Load and play video
            guard let videoURL = Bundle.main.url(forResource: "LOR-E-P1", withExtension: "mp4") else {
                print("Video not found.")
                return
            }

            let player = AVPlayer(url: videoURL)
            let videoMaterial = VideoMaterial(avPlayer: player)
            videoMaterial.avPlayer?.play()

            let mesh = MeshResource.generatePlane(width: 0.3, height: 0.3)
            let videoEntity = ModelEntity(mesh: mesh, materials: [videoMaterial])

            // Face video outward from wall
            videoEntity.transform.rotation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
            videoEntity.position.z = 0.001

            let anchor = AnchorEntity(world: raycastResult.worldTransform)
            anchor.addChild(videoEntity)
            arView.scene.anchors.append(anchor)
            currentVideoAnchor = anchor

            // Setup audio
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Audio session error: \(error)")
            }

            // Delay spawning fish until after 16 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 16.0) {
                // Start swordfish animation after delay
                self.spawnFishStorm(around: arView)
                self.startFishSwimAnimation()
            }
        }


        func spawnFishStorm(around arView: ARView) {
            guard let fishModel = try? Entity.load(named: "swordfish") else {
                print("Failed to load swordfish model.")
                return
            }

            let centerAnchor = AnchorEntity(world: simd_float4x4(translation: [0, 0, 0]))
            arView.scene.anchors.append(centerAnchor)

            let count = 40
            let radius: Float = 1.5

            for i in 0..<count {
                let angle = Float(i) * (2 * .pi / Float(count))
                let x = cos(angle) * radius
                let z = sin(angle) * radius

                let baseY = Float.random(in: -1.0...1.0) // More vertical spacing
                let y = baseY - 1.5                     // Shift all lower

                let fish = fishModel.clone(recursive: true)
                fish.position = SIMD3<Float>(x, y, z)
                fish.look(at: .zero, from: fish.position, relativeTo: nil)
                fish.setScale(SIMD3<Float>(0.0025, 0.0025, 0.0025), relativeTo: nil)

                fish.name = "\(Float.random(in: 0...2 * .pi))" // wave phase
                centerAnchor.addChild(fish)
                fishEntities.append(fish)
            }
        }

        func startFishSwimAnimation() {
            fishTimer?.invalidate()

            fishTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                let time = Float(CACurrentMediaTime())

                for fish in self.fishEntities {
                    guard let phase = Float(fish.name) else { continue }

                    let amplitude: Float = 0.4
                    let frequency: Float = 1.5
                    let yOffset = sin(time * frequency + phase) * amplitude
                    fish.position.y = yOffset
                }
            }
        }
    }
}

extension simd_float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
    }
}

struct ARViewScreen: View {
    @State private var hasTapped = false

    var body: some View {
        ZStack {
            ARViewContainer(hasTapped: $hasTapped)
                .edgesIgnoringSafeArea(.all)

            if !hasTapped {
                Text("Tap on a wall to start!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: hasTapped)
    }
}


#Preview {
    ARViewScreen()
}
