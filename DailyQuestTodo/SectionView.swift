//
//  SectionView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal)
            content()
        }
        .padding(.vertical, 10)
    }
}
