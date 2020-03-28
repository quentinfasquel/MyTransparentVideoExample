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
    var player: AVPlayer?
    var isTransparent: Bool = false

    private static var transparentPixelBufferAttributes: [String: Any] {
        [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    }
    
    func makeUIView(context: UIViewRepresentableContext<PlayerView>) -> AVPlayerView {
        return AVPlayerView()
    }

    func updateUIView(_ playerView: AVPlayerView, context: UIViewRepresentableContext<PlayerView>) {
        playerView.player = player

        let pixelBufferAttributes = isTransparent ? Self.transparentPixelBufferAttributes : nil
        playerView.playerLayer.pixelBufferAttributes = pixelBufferAttributes
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
