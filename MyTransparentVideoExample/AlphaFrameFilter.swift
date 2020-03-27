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

    enum Error: Swift.Error {
        case incompatibleExtents
        case invalidKernel
        case invalidParameters
        case unknown
    }
    
    private(set) var inputImage: CIImage?
    private(set) var maskImage: CIImage?
    private(set) var outputError: Swift.Error?
    
    override var outputImage: CIImage? {
        // Output is nil if an input image and a mask image aren't provided
        guard let inputImage = inputImage, let maskImage = maskImage else {
            outputError = Error.invalidParameters
            return nil
        }

        // Input image & mask image should have the same extent
        guard inputImage.extent == maskImage.extent else {
            outputError = Error.incompatibleExtents
            return nil
        }

        outputError = nil

        return render(using: .metalKernel, inputImage: inputImage, maskImage: maskImage)
    }
    
    func process(_ inputImage: CIImage, mask maskImage: CIImage) throws -> CIImage {
        self.inputImage = inputImage
        self.maskImage = maskImage
        
        guard let outputImage = self.outputImage else {
            throw outputError ?? Error.unknown
        }

        return outputImage
    }
    
    // MARK: - Rendering
    
    private enum RenderingMode {
        case colorKernel
        case metalKernel
    }
    
    private static var colorKernel: CIColorKernel? = {
        return CIColorKernel(source: """
kernel vec4 alphaFrame(__sample s, __sample m) {
    return vec4( s.rgb, m.r );
}
""")
    }()
    
    private static var metalKernelError: Swift.Error?
    private static var metalKernel: CIKernel? = {
        do { return try CIKernel(functionName: "alphaFrame") }
        catch { metalKernelError = error; return nil }
    }()

    private func render(using renderingMode: RenderingMode, inputImage: CIImage, maskImage: CIImage) -> CIImage? {
        switch renderingMode {
        case .colorKernel:
            // Force a fatal error if our kernel source isn't correct
            guard let colorKernel = Self.colorKernel else {
                outputError = Error.invalidKernel
                return nil
            }

            // Apply our color kernel with the proper parameters
            let outputExtent = inputImage.extent
            let arguments = [inputImage, maskImage]
            return colorKernel.apply(extent: outputExtent, arguments: arguments)

        case .metalKernel:
            guard let metalKernel = Self.metalKernel else {
                outputError = Self.metalKernelError ?? Error.invalidKernel
                return nil
            }

            let outputExtent = inputImage.extent
            let roiCallback: CIKernelROICallback = { _, rect in rect }
            let arguments = [inputImage, maskImage]
            return metalKernel.apply(extent: outputExtent, roiCallback: roiCallback, arguments: arguments)
        }
    }
}
