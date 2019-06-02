//
//  AVPlayerView.swift
//  MyTransparentVideoExample
//
//  Created by Quentin on 27/10/2017.
//  Copyright © 2017 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import UIKit

class AVPlayerView: UIView {

  deinit {
    self.playerItem = nil
  }
  
  override class var layerClass: AnyClass {
    return AVPlayerLayer.self
  }
  
  var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
  var player: AVPlayer? {
    set { playerLayer.player = newValue }
    get { return playerLayer.player }
  }
  
  var playerItem: AVPlayerItem? = nil {
    willSet { playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status)) }
    didSet {
      //
      playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
      // If `isLoopingEnabled` is called before the AVPlayer was set
      setupLooping()
    }
  }
  
  var onReadyCallback: ((AVPlayer?, Error?) -> Void)? = nil

  func loadVideo(_ playerItem: AVPlayerItem, onReady: ((AVPlayer?, Error?) -> Void)? = nil) {
    self.onReadyCallback = onReady
    self.player = AVPlayer(playerItem: playerItem)
    self.playerItem = playerItem
  }

  // MARK: - Looping Handler

  /// When set to `true`, the player view automatically adds an observer on its AVPlayer,
  /// and it will play again from start every time playback ends.
  /// * Warning: This will not result in a smooth video loop.
  public var isLoopingEnabled: Bool = false {
    didSet { setupLooping() }
  }

  private var didPlayToEndTimeObsever: NSObjectProtocol? = nil {
    willSet(newObserver) {
      // When updating didPlayToEndTimeObserver,
      // automatically remove its previous value from the Notification Center
      if let observer = didPlayToEndTimeObsever, didPlayToEndTimeObsever !== newObserver {
        NotificationCenter.default.removeObserver(observer)
      }
    }
  }

  private func setupLooping() {
    guard let playerItem = self.playerItem, let player = self.player else {
      return
    }

    guard isLoopingEnabled else {
      didPlayToEndTimeObsever = nil
      return
    }

    didPlayToEndTimeObsever = NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil, using: { _ in
        player.seek(to: CMTime.zero) { _ in
          player.play()
        }
    })
  }

  // MARK: Key Value Observing

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let playerItem = object as? AVPlayerItem, playerItem === self.playerItem else {
      return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }

    switch playerItem.status {
    case .readyToPlay:
      onReadyCallback?(player, nil)
    case .failed:
      onReadyCallback?(player, playerItem.error)
    default: break
    }
    
    // Unregister our callback
    onReadyCallback = nil
  }
}
