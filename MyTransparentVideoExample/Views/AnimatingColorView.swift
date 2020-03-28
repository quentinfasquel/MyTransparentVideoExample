//
//  AnimatingColorView.swift
//  MyTransparentVideoExample
//
//  Created by Quentin Fasquel on 27/03/2020.
//  Copyright © 2020 Quentin Fasquel. All rights reserved.
//

import SwiftUI

struct AnimatingColorView: View {
    private let backgroundColors: [UIColor] = [.purple, .blue, .cyan, .green, .yellow, .orange, .red]
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    private func setNextColor() {
        let colorIndex = backgroundColors.firstIndex(of: currentColor) ?? 0
        let countColors = backgroundColors.count
        currentColor = backgroundColors[(colorIndex + 1) % countColors]
    }
    
    @State private var currentColor: UIColor = .purple

    var body: some View {
        Color(currentColor)
            .animation(.linear(duration: 2))
            .onReceive(timer, perform: { _ in
                self.setNextColor()
            })
    }
}

struct AnimatorColorView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatingColorView()
            .edgesIgnoringSafeArea(.all)
    }
}
