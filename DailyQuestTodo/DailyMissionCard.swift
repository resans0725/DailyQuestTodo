//
//  DailyMissionCard.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct DailyMissionCard: View {
    let quest: Quest
    let onComplete: () -> Void
    @State private var animate = false

    var body: some View {
        HStack {
            Image(systemName: difficultyIcon)
                .foregroundColor(difficultyColor)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 4) {
                Text(quest.content)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Text("難易度: \(difficultyDisplayName) | EXP: \(quest.exp)")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            Spacer()
            if quest.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
            } else {
                Button(action: onComplete) {
                    Text("完了")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .scaleEffect(animate ? 1.0 : 0.9)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animate)
                }
                .onAppear { animate = true }
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.95)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
    }

    private var difficultyDisplayName: String {
        switch quest.difficulty {
        case "easy":
            return "イージー"
        case "normal":
            return "ノーマル"
        case "hard":
            return "ハード"
        default:
            return quest.difficulty
        }
    }

    private var difficultyIcon: String {
        switch quest.difficulty {
        case "easy":
            return "circle.fill"
        case "normal":
            return "diamond.fill"
        case "hard":
            return "exclamationmark.triangle.fill"
        default:
            return "questionmark"
        }
    }

    private var difficultyColor: Color {
        switch quest.difficulty {
        case "easy":
            return .green
        case "normal":
            return .yellow
        case "hard":
            return .red
        default:
            return .gray
        }
    }
}
