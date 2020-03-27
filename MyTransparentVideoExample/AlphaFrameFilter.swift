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
        /// This error is thrown  when using renderingMode `builtInFilter` and the filter named *CIBlendWithMask* was not found
        case buildInFilterNotFound
        /// This error is thrown when `inputImage` and `maskImage` have different **extents**
        case incompatibleExtents
        /// This error is thrown when a kernel couldn't be initialized,
        /// which may happen when using renderingMode `colorKernel` or `metalKernel`
        case invalidKernel
        /// This error is thrown when `inputImage` or `maskImage` is missing
        case invalidParameters
        /// This error would be thrown when output image is `nil` in any other case, it typically should not happen
        case unknown
    }
    
    private(set) var inputImage: CIImage?
    private(set) var maskImage: CIImage?
    private(set) var outputError: Swift.Error?

    private let renderingMode: RenderingMode
    
    required init(renderingMode: RenderingMode) {
        self.renderingMode = renderingMode
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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

        return render(using: renderingMode, inputImage: inputImage, maskImage: maskImage)
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
    
    enum RenderingMode {
        case builtInFilter
        case colorKernel
        case metalKernel
    }
    
    private static var colorKernel: CIColorKernel? = {
        // `init(source:)` was deprecated in iOS 12.0: Core Image Kernel Language API deprecated.
        // This warning is silent because of preprocessor macro `CI_SILENCE_GL_DEPRECATION`
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

        case .builtInFilter:
            guard let filter = CIFilter(name: "CIBlendWithMask") else {
                outputError = Error.buildInFilterNotFound
                return nil
            }

            let outputExtent = inputImage.extent
            let backgroundImage = CIImage(color: .clear).cropped(to: outputExtent)
            filter.setValue(backgroundImage, forKey: kCIInputBackgroundImageKey)
            filter.setValue(inputImage, forKey: kCIInputImageKey)
            filter.setValue(maskImage, forKey: kCIInputMaskImageKey)
            return filter.outputImage

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
