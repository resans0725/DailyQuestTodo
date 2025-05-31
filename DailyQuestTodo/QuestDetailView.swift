//
//  QuestDetailView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct QuestDetailView: View {
    @ObservedObject var viewModel: QuestViewModel
    @State var quest: Quest
    @Environment(\.dismiss) var dismiss
    @State private var isEditing: Bool = false
    @State private var editedContent: String
    @State private var editedPriority: Int
    @State private var editedDifficulty: String
    @State private var editedDetails: String
    @State private var showDeleteConfirmation: Bool = false
    private let detailsMaxLength = 200

    init(viewModel: QuestViewModel, quest: Quest) {
        self.viewModel = viewModel
        self._quest = State(initialValue: quest)
        self._editedContent = State(initialValue: quest.content)
        self._editedPriority = State(initialValue: quest.priority)
        self._editedDifficulty = State(initialValue: quest.difficulty)
        self._editedDetails = State(initialValue: quest.details)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 15) {
                        if isEditing {
                            TextField("クエスト内容", text: $editedContent)
                                .font(.system(size: 16, design: .rounded))
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                            VStack(alignment: .leading, spacing: 5) {
                                Text("詳細（最大\(detailsMaxLength)文字）")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                TextEditor(text: $editedDetails)
                                    .font(.system(size: 16, design: .rounded))
                                    .frame(height: 100)
                                    .padding(8)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                                    .onChange(of: editedDetails) { newValue in
                                        if newValue.count > detailsMaxLength {
                                            editedDetails = String(newValue.prefix(detailsMaxLength))
                                        }
                                    }
                                Text("文字数: \(editedDetails.count)/\(detailsMaxLength)")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(editedDetails.count >= detailsMaxLength ? .red : .gray)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("優先度")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                Picker("優先度: 低/中/高", selection: $editedPriority) {
                                    Text("低").tag(1)
                                    Text("中").tag(2)
                                    Text("高").tag(3)
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("難易度")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                Picker("難易度: イージー/ノーマル/ハード", selection: $editedDifficulty) {
                                    Text("イージー").tag("easy")
                                    Text("ノーマル").tag("normal")
                                    Text("ハード").tag("hard")
                                }
                                .pickerStyle(.segmented)
                            }

                            Button(action: saveQuest) {
                                Text("保存")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                            .disabled(editedContent.isEmpty)
                        } else {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("クエスト内容")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(width: 100, alignment: .leading)
                                    Text(quest.content)
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().background(Color.gray.opacity(0.3))

                                HStack(alignment: .top) {
                                    Text("詳細")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(width: 100, alignment: .leading)
                                    Text(quest.details.isEmpty ? "詳細なし" : quest.details)
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(quest.details.isEmpty ? .gray : .primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().background(Color.gray.opacity(0.3))

                                HStack {
                                    Text("優先度")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(width: 100, alignment: .leading)
                                    Text(priorityDisplayName)
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().background(Color.gray.opacity(0.3))

                                HStack {
                                    Text("難易度")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(width: 100, alignment: .leading)
                                    Text(difficultyDisplayName)
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider().background(Color.gray.opacity(0.3))

                                HStack {
                                    Text("状態")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                        .frame(width: 100, alignment: .leading)
                                    Text(quest.isCompleted ? "達成済み" : "未対応")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(quest.isCompleted ? .green : .gray)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                if quest.failCount > 0 {
                                    Divider().background(Color.gray.opacity(0.3))
                                    HStack {
                                        Text("失敗回数")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                            .frame(width: 100, alignment: .leading)
                                        Text("\(quest.failCount)回")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                if quest.isDaily {
                                    Divider().background(Color.gray.opacity(0.3))
                                    HStack {
                                        Text("デイリー")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(.gray)
                                            .frame(width: 100, alignment: .leading)
                                        Text("設定済み")
                                            .font(.system(size: 16, design: .rounded))
                                            .foregroundColor(.blue)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.white.opacity(0.9), .white.opacity(0.95)]), startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.horizontal)

                            // デイリーミッション解除ボタン
                            if quest.isDaily {
                                Button(action: {
                                    viewModel.removeDailyQuest(quest)
                                }) {
                                    Text("デイリーミッションから解除")
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.red)
                                        .cornerRadius(15)
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("クエスト詳細")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isEditing.toggle() }) {
                        Text(isEditing ? "キャンセル" : "編集")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showDeleteConfirmation = true }) {
                        Text("削除")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
            }
            .actionSheet(isPresented: $showDeleteConfirmation) {
                ActionSheet(
                    title: Text("クエストの削除"),
                    message: Text("このクエストを削除しますか？\nこの操作は元に戻せません。"),
                    buttons: [
                        .destructive(Text("削除")) {
                            viewModel.deleteQuest(quest)
                            dismiss()
                        },
                        .cancel(Text("キャンセル"))
                    ]
                )
            }
        }
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

    private func saveQuest() {
        quest.content = editedContent
        quest.priority = editedPriority
        quest.difficulty = editedDifficulty
        quest.details = editedDetails
        do {
            try viewModel.modelContext.save()
            try viewModel.fetchQuests()
            isEditing = false
        } catch {
            print("クエスト編集時のエラー: \(error.localizedDescription)")
        }
    }
}
