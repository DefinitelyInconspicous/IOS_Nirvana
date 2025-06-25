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
    
    func FindVideo(language: String, Part: Int) -> String {
        print(language)
        return "LOR-" + language + "-P"  + String(Part)
    }
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url:  Bundle.main.url(forResource: FindVideo(language: String((language.split(separator: ""))[0]), Part: 1), withExtension: "mp4")!))
            .ignoresSafeArea()
            .onAppear() {
                var player = AVPlayer(url:  Bundle.main.url(forResource: FindVideo(language: String((language.split(separator: ""))[0]), Part: 1), withExtension: "mp4")!)
                player.play()
            }
        
        
    }
    
}

#Preview {
    VideoView(language: .constant("English"))
}
