//
//  TransparentVideo.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 27/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import AVFoundation
import os.log

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
    let filter = AlphaFrameFilter(renderingMode: .builtInFilter)
    let composition = AVMutableVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
        do {
            let (inputImage, maskImage) = request.sourceImage.verticalSplit()
            let outputImage = try filter.process(inputImage, mask: maskImage)
            return request.finish(with: outputImage, context: nil)
        } catch {
            os_log("Video composition error: %s", String(describing: error))
            return request.finish(with: error)
        }
    })

    composition.renderSize = asset.videoSize.applying(CGAffineTransform(scaleX: 1.0, y: 0.5))
    return composition
}
