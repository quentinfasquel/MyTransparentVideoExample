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

    @State var isTransparencyEnabled: Bool = false
    
    func toggleTransparency() {
        isTransparencyEnabled = !isTransparencyEnabled
    }

    func getToggleButton() -> some View {
        Button(action: toggleTransparency) {
            Text("Toggle Transparency")
                .padding(10)
                .font(Font.callout.bold())
                .foregroundColor(.white)
                .background(Color.white.opacity(0.5))
                .cornerRadius(10)
        }
    }

    var body: some View {
        ZStack {
            AnimatingColorView()
                .edgesIgnoringSafeArea(.all)
            VStack {
                if isTransparencyEnabled {
                    PlayerView(player: player, isTransparent: true)
                    .frame(width: 300, height: 187, alignment: .center)
                    .onAppear { self.player.play() }
                } else {
                    PlayerView(player: player, isTransparent: false)
                    .frame(width: 300, height: 187, alignment: .center)
                    .onAppear { self.player.play() }
                }
                getToggleButton()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
