//
//  ContentView.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 25/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import SwiftUI

struct ContentView: View {
    let player: AVPlayer
    let playerLooper: AVPlayerLooper

    @ObservedObject var playback: PlaybackControl
    
    init() {
        let url = Bundle.main.url(forResource: "playdoh-bat", withExtension: "mp4")!
        let playerItem = createTransparentItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer
        playback = PlaybackControl(player: player)
    }

    @State var enablesTransparentVideo: Bool = false
    @State var isPlaying: Bool = false {
        didSet { print("didset") }//isPlaying ? player.play() : player.pause() }
    }
    
    var body: some View {
        ZStack {
            AnimatingColorView()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                PlayerView(player: player, isTransparent: enablesTransparentVideo)
                    .frame(width: 300, height: 187, alignment: .center)

                PlaybackControlView(isPlaying: $playback.isPlaying)
                    .customButtonStyle()
                
                transparentVideoButton()
            }
        }
    }

    // MARK: - Private Methods
    
    private func transparentVideoButton() -> some View {
        func toggleTransparentVideo() {
            enablesTransparentVideo.toggle()
        }

        return Button(action: toggleTransparentVideo) {
            Text("\(enablesTransparentVideo ? "Disable" : "Enable") Transparency")
                .font(Font.callout.bold())
                .customButtonStyle()
        }
    }
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// MARK: - Playback View Model

final class PlaybackControl: ObservableObject {
    private weak var player: AVPlayer!

    var isPlaying: Bool = false {
        didSet { isPlaying ? player.play() : player.pause() }
    }

    init(player: AVPlayer) {
        self.player = player
    }
}
