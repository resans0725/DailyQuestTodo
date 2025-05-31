//
//  QuestCardView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct QuestCardView<Content: View>: View {
    let quest: Quest
    let onComplete: (() -> Void)?
    let onFail: (() -> Void)?
    @ViewBuilder let actionContent: () -> Content
    @State private var animate = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // 難易度アイコン
            Image(systemName: difficultyIcon)
                .foregroundColor(difficultyColor)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 4) {
                Text(quest.content)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                Text("優先度: \(priorityDisplayName) | 難易度: \(difficultyDisplayName) | EXP: \(quest.exp)")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
                if quest.failCount > 0 {
                    Text("失敗: \(quest.failCount)回")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.red)
                }
            }
            Spacer()
            VStack {
                if quest.isCompleted {
                    Text("達成済み")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.green)
                } else if onComplete != nil && onFail != nil {
                    HStack(spacing: 8) {
                        Button(action: {
                            withAnimation(.spring()) { onComplete?() }
                        }) {
                            Text("完了")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        Button(action: { onFail?() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                }
                actionContent()
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal)
        .scaleEffect(animate ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: animate)
        .onAppear { animate = true }
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

    private var priorityDisplayName: String {
        switch quest.priority {
        case 3:
            return "高"
        case 2:
            return "中"
        case 1:
            return "低"
        default:
            return "\(quest.priority)"
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
