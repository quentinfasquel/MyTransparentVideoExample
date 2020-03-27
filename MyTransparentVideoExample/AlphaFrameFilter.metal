//
//  AlphaFrameFilter.metal
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 22/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h> // includes CIKernelMetalLib.h

extern "C" {
    namespace coreimage {
        float4 alphaFrame(sampler source, sampler mask) {
            float4 color = source.sample(source.coord());
            float opacity = mask.sample(mask.coord()).r;
            return float4(color.rgb, opacity);
        }
    }
}
