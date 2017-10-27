//
//  ChromaKeyFilter.swift
//  MyTransparentVideoExample
//
//  Created by Quentin on 27/10/2017.
//  Copyright © 2017 Quentin Fasquel. All rights reserved.
//

import CoreImage

class AlphaFrameFilter: CIFilter {
  static var kernel: CIColorKernel? = {
    return CIColorKernel(source: """
kernel vec4 alphaFrame(__sample s, __sample m) {
  return vec4( s.rgb, m.r );
}
""")
  }()

  var inputImage: CIImage?
  var maskImage: CIImage?
  
  override var outputImage: CIImage? {
    // Force a fatal error if our kernel source isn't correct
    let kernel = AlphaFrameFilter.kernel!
    // Output is nil if an input image and a mask image aren't provided
    guard let inputImage = inputImage, let maskImage = maskImage else {
      return nil
    }
    // Apply our color kernel with the proper parameters
    let args = [inputImage as AnyObject, maskImage as AnyObject]
    return kernel.apply(extent: inputImage.extent, arguments: args)
  }
}
