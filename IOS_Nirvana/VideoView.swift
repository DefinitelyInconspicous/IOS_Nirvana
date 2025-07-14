//
//  VideoView.swift
//  IOS_Nirvana
//
//  Created by Avyan Mehra on 25/6/25.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @Binding var language: String
    @Binding var part: Int
    @State private var navigateToGame = false
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var navigateToEnd = false

    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: playerItem,
                            queue: .main
                        ) { _ in
                            if part == 1 {
                                navigateToGame = true
                            } else {
                                navigateToEnd = true
                            }
                        }
                    }
                    .onDisappear {
                        NotificationCenter.default.removeObserver(
                            self,
                            name: .AVPlayerItemDidPlayToEndTime,
                            object: playerItem
                        )
                    }
            } else {
                ProgressView("Loading video...")
                    .onAppear {
                        let videoName = "LOR-" + String(language.prefix(1)) + "-P" + String(part)
                        if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                            let item = AVPlayerItem(url: url)
                            playerItem = item
                            player = AVPlayer(playerItem: item)
                        } else {
                            print("Video file not found: \(videoName).mp4")
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $navigateToGame) {
            Game1view(language: .constant(language))
        }
    }
}

#Preview {
    VideoView(language: .constant("English"), part: .constant(1))
}
