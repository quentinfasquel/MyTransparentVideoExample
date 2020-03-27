//
//  ChromaKeyFilter.swift
//  MyTransparentVideoExample
//
//  Created by Quentin on 27/10/2017.
//  Copyright © 2017 Quentin Fasquel. All rights reserved.
//

import CoreImage

typealias AlphaFrameFilterError = AlphaFrameFilter.Error

final class AlphaFrameFilter: CIFilter {
        
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
        case incompatibleExtents
        case unknown
    }
    
    private(set) var inputImage: CIImage?
    private(set) var maskImage: CIImage?
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

        // Input image & mask image should have the same extent
        guard inputImage.extent == maskImage.extent else {
            outputError = .incompatibleExtents
            return nil
        }

        outputError = nil

        // Apply our color kernel with the proper parameters
        let outputExtent = inputImage.extent
        let arguments = [inputImage, maskImage]
        return kernel.apply(extent: outputExtent, arguments: arguments)
    }
    
    func process(_ inputImage: CIImage, mask maskImage: CIImage) throws -> CIImage {
        self.inputImage = inputImage
        self.maskImage = maskImage
        
        guard let outputImage = self.outputImage else {
            throw outputError ?? .unknown
        }

        return outputImage
    }
}
