//
//  PlaybackControlView.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 28/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import SwiftUI

struct PlaybackControlView: View {

    @Binding var isPlaying: Bool
    @State var playing: Bool = false

    // MARK: Components
        
    var body: some View {
        HStack {
            playPauseButton()
        }
    }
    
    private func playPauseButton() -> some View {
        func togglePlayPause() {
            isPlaying.toggle()
            playing = isPlaying
        }

        return Button(action: togglePlayPause) {
            Image(systemName: playing ? "pause.fill" : "play.fill")
        }.frame(width: 20, height: 20)
    }
}
