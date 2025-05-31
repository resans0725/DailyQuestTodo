//
//  WaveShape.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct WaveShape: Shape {
    var phase: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waveHeight: CGFloat = 5
        let yOffset = rect.height / 2

        path.move(to: CGPoint(x: 0, y: yOffset))
        for x in stride(from: 0, to: rect.width, by: 1) {
            let relativeX = x / rect.width
            let sine = sin(Double(relativeX) * 4 * .pi + phase * .pi / 180)
            let y = yOffset + waveHeight * CGFloat(sine)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
