//
//  CustomButtonStyle.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 28/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import SwiftUI

struct CustomButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .foregroundColor(.black)
            .background(Color.white.opacity(0.6))
            .cornerRadius(10)
            .shadow(radius: 20)
    }
}

extension View {
    func customButtonStyle() -> some View {
        self.modifier(CustomButtonStyle())
    }
}
