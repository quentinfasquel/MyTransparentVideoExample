//
//  AVPlayerView.swift
//  MyTransparentVideoExample
//
//  Created by Quentin on 27/10/2017.
//  Copyright © 2017 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import UIKit

public class AVPlayerView: UIView {
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    public var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    public var player: AVPlayer? {
        set { playerLayer.player = newValue }
        get { return playerLayer.player }
    }
}
