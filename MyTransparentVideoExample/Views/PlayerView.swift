//
//  PlayerView.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 27/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import SwiftUI

struct PlayerView: UIViewRepresentable {
    @State var player: AVPlayer?
    @State var isTransparent: Bool = false

    private static var transparentPixelBufferAttributes: [String: Any] {
        [kCVPixelBufferPixelFormatTypeKey as String: kCMPixelFormat_32BGRA]
    }
    
    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> AVPlayerView {
        return AVPlayerView()
    }

    func updateUIView(_ playerView: AVPlayerView, context: UIViewRepresentableContext<PlayerView>) {
        if let player = self.player {
            playerView.setPlayer(player)
        } else {
            playerView.removePlayer()
        }

        let playerLayer = playerView.playerLayer
        playerLayer.pixelBufferAttributes = isTransparent
            ? Self.transparentPixelBufferAttributes : nil
        
        if let rate = player?.rate, rate > 0 {
            player?.pause()
            player?.play()
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
