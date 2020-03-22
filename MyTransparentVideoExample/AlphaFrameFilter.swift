//
//  ChromaKeyFilter.swift
//  MyTransparentVideoExample
//
//  Created by Quentin on 27/10/2017.
//  Copyright © 2017 Quentin Fasquel. All rights reserved.
//

import CoreImage

typealias AlphaFrameFilterError = AlphaFrameFilter.Error

class AlphaFrameFilter: CIFilter {
    private static var kernel: CIColorKernel? = {
        return CIColorKernel(source:"""
kernel vec4 alphaFrame(__sample s, __sample m) {
  return vec4( s.rgb, m.r );
}
""")
    }()

    enum Error: Swift.Error {
        case invalidKernel
        case missingInputImage
        case unknown
    }
    
    var inputImage: CIImage?
    var maskImage: CIImage?
    
    private(set) var outputError: Error?
    
    override var outputImage: CIImage? {
        // Force a fatal error if our kernel source isn't correct
        guard let kernel = AlphaFrameFilter.kernel else {
            outputError = .invalidKernel
            return nil
        }

        // Output is nil if an input image and a mask image aren't provided
        guard let inputImage = inputImage, let maskImage = maskImage else {
            outputError = .missingInputImage
            return nil
        }
        
        outputError = nil
        // Apply our color kernel with the proper parameters
        let args = [inputImage as AnyObject, maskImage as AnyObject]
        return kernel.apply(extent: inputImage.extent, arguments: args)
    }
}
