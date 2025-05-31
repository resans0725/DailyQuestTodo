//
//  StatCard.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// 説明: StatCard.swift
// - カードにカスタムカラーを追加し、統計ごとに異なる色で視認性アップ。
// - 角丸とシャドウで立体感、透明感のある背景で今風に。
