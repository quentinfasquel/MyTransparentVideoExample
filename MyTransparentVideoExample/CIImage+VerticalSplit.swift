//
//  CIImage+Split.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 27/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import CoreImage

extension CIImage {

    typealias VerticalSplit = (topImage: CIImage, bottomImage: CIImage)

    func verticalSplit() -> VerticalSplit {
        let outputExtent = self.extent.applying(CGAffineTransform(scaleX: 1.0, y: 0.5))

        // Get the top region according to Core Image coordinate system, (0,0) being bottom left
        let translate = CGAffineTransform(translationX: 0, y: outputExtent.height)
        let topRegion = outputExtent.applying(translate)
        var topImage = self.cropped(to: topRegion)
        // Translate topImage back to origin
        topImage = topImage.transformed(by: translate.inverted())

        let bottomRegion = outputExtent
        let bottomImage = self.cropped(to: bottomRegion)

        return (topImage, bottomImage)
    }
}
