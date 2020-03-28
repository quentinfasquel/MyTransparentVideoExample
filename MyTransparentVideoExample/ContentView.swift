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

    init() {
        let url = Bundle.main.url(forResource: "playdoh-bat", withExtension: "mp4")!
        let playerItem = createTransparentItem(url: url)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        player = queuePlayer
    }

    var body: some View {
        ZStack {
            AnimatingColorView()
                .edgesIgnoringSafeArea(.all)
            PlayerView(player: player, isTransparent: true)
                .frame(width: 300, height: 187, alignment: .center)
                .onAppear { self.player.play() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
