//
//  CIKernelExtension.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 22/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import CoreImage
import Metal

private func defaultMetalLibrary() throws -> Data {
    let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
    return try Data(contentsOf: url)
}

extension CIKernel {
    /// Init CI kernel with just a `functionName` directly from default metal library
    convenience init(functionName: String) throws {
        let metalLibrary = try defaultMetalLibrary()
        try self.init(functionName: functionName, fromMetalLibraryData: metalLibrary)
    }
}
