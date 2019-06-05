//
//  ViewController.swift
//  MyTransparentVideoExample
//
//  Created by Quentin on 27/10/2017.
//  Copyright © 2017 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let videoSize = CGSize(width: 300, height: 300)
        let playerView = AVPlayerView(frame: CGRect(origin: .zero, size: videoSize))
        view.addSubview(playerView)
        
        // Use Auto Layout anchors to center our playerView
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.widthAnchor.constraint(equalToConstant: videoSize.width).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: videoSize.height).isActive = true
        playerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        // Setup our playerLayer to hold a pixel buffer format with "alpha"
        let playerLayer: AVPlayerLayer = playerView.playerLayer
        playerLayer.pixelBufferAttributes = [
            (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        
        // Our AVPlayerLayer has a default backgroundColor to nil
        // Set a backgroundColor the viewController's view
        view.backgroundColor = .gray
        
        // Setup looping on our video
        playerView.isLoopingEnabled = true
        
        // Load our player item
        let itemUrl: URL = Bundle.main.url(forResource: "playdoh-bat", withExtension: "mp4")!
        let playerItem = createTransparentItem(url: itemUrl)
        
        playerView.loadVideo(playerItem) { [weak self] player, error in
            guard let player = player, error == nil else {
                return print("Something went wrong when loading our video", error!)
            }
            
            // Finally, we can start playing
            player.play()
            
            self?.animateBackgroundColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Player Item Configuration
    
    func createTransparentItem(url: URL) -> AVPlayerItem {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        // Set the video so that seeking also renders with transparency
        playerItem.seekingWaitsForVideoCompositionRendering = true
        // Apply a video composition (which applies our custom filter)
        playerItem.videoComposition = createVideoComposition(for: asset)
        return playerItem
    }
    
    func createVideoComposition(for asset: AVAsset) -> AVVideoComposition {
        let videoTrack = asset.tracks(withMediaType: .video).first!
        let videoSize = videoTrack.naturalSize.applying(CGAffineTransform(scaleX: 1.0, y: 0.5))
        let composition = AVMutableVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            let sourceRect = CGRect(origin: .zero, size: videoSize)
            let alphaRect = sourceRect.offsetBy(dx: 0, dy: sourceRect.height)
            let filter = AlphaFrameFilter()
            filter.inputImage = request.sourceImage
                .cropped(to: alphaRect)
                .transformed(by: CGAffineTransform(translationX: 0, y: -sourceRect.height))
            filter.maskImage = request.sourceImage.cropped(to: sourceRect)
            return request.finish(with: filter.outputImage!, context: nil)
        })

        composition.renderSize = videoSize
        return composition
    }
    
    // MARK: - Background Color
    
    func animateBackgroundColor() {
        let backgroundColors: [UIColor] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red]

        let animator = UIViewPropertyAnimator(duration: 2.0, curve: .linear) {
            let colorIndex = backgroundColors.firstIndex(of: self.view.backgroundColor!) ?? 0
            let countColors = backgroundColors.count
            self.view.backgroundColor = backgroundColors[(colorIndex + 1) % countColors]
        }

        animator.addCompletion { _ in
            // Infinite animation
            self.animateBackgroundColor()
        }

        animator.startAnimation()
    }
}
