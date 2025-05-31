//
//  QuestListView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct QuestListView: View {
    @ObservedObject var viewModel: QuestViewModel
    @State private var filterPriority: Int? = nil
    @State private var filterStatus: String? = nil
    @State private var filterDifficulty: String? = nil
    @State private var animateEmptyView = false // エンプティービュー用アニメーション

    var filteredQuests: [Quest] {
        var quests = viewModel.quests

        if let priority = filterPriority {
            quests = quests.filter { $0.priority == priority }
        }

        if let status = filterStatus {
            switch status {
            case "incompleted":
                quests = quests.filter { !$0.isCompleted }
            case "completed":
                quests = quests.filter { $0.isCompleted }
            case "failed":
                quests = quests.filter { $0.failCount > 0 }
            default:
                break
            }
        }

        if let difficulty = filterDifficulty {
            quests = quests.filter { $0.difficulty == difficulty }
        }

        return quests
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        SectionView(title: "フィルター") {
                            VStack(spacing: 10) {
                                Picker("状態で絞り込み", selection: $filterStatus) {
                                    Text("すべて").tag(nil as String?)
                                    Text("未対応").tag("incompleted" as String?)
                                    Text("達成済み").tag("completed" as String?)
                                    Text("失敗").tag("failed" as String?)
                                }
                                .pickerStyle(.segmented)

                                Picker("優先度で絞り込み", selection: $filterPriority) {
                                    Text("すべて").tag(nil as Int?)
                                    Text("高").tag(3)
                                    Text("中").tag(2)
                                    Text("低").tag(1)
                                }
                                .pickerStyle(.segmented)

                                Picker("難易度で絞り込み", selection: $filterDifficulty) {
                                    Text("すべて").tag(nil as String?)
                                    Text("イージー").tag("easy" as String?)
                                    Text("ノーマル").tag("normal" as String?)
                                    Text("ハード").tag("hard" as String?)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        }

                        SectionView(title: "クエスト一覧 (\(filteredQuests.count)件)") {
                            if filteredQuests.isEmpty {
                                // エンプティービュー
                                VStack(spacing: 15) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                        .scaleEffect(animateEmptyView ? 1.0 : 0.8)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateEmptyView)

                                    Text("クエストがありません")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.gray)

                                    Text("右上の追加ボタンからクエストを入力して追加しましょう！")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)

                                    NavigationLink(destination: QuestCreateView(viewModel: viewModel)) {
                                        Text("クエスト追加")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 20)
                                            .background(LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .leading, endPoint: .trailing))
                                            .foregroundColor(.white)
                                            .cornerRadius(15)
                                            .shadow(radius: 5)
                                            .scaleEffect(animateEmptyView ? 1.0 : 0.9)
                                            .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateEmptyView)
                                    }
                                }
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.95)]), startPoint: .top, endPoint: .bottom)
                                )
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                                .opacity(animateEmptyView ? 1 : 0)
                                .offset(y: animateEmptyView ? 0 : 20)
                                .animation(.easeInOut(duration: 0.5).delay(0.6), value: animateEmptyView)
                            } else {
                                ForEach(filteredQuests, id: \.id) { quest in
                                    QuestCardView(quest: quest, onComplete: nil, onFail: nil) {
                                        VStack(spacing: 8) {
                                            if !quest.isDaily && viewModel.dailyQuests.count < 3 && !quest.isCompleted {
                                                Button(action: {
                                                    withAnimation { viewModel.setDailyQuest(quest) }
                                                }) {
                                                    Text("デイリーに設定")
                                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                                        .frame(width: 75, height: 20)
                                                        .padding(.vertical, 8)
                                                        .padding(.horizontal, 16)
                                                        .background(Color.blue.opacity(0.8))
                                                        .foregroundColor(.white)
                                                        .clipShape(Capsule())
                                                }
                                            }
                                            NavigationLink(destination: QuestDetailView(viewModel: viewModel, quest: quest)) {
                                                Text("詳細")
                                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                                    .frame(width: 75, height: 20)
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 16)
                                                    .background(Color.gray.opacity(0.3))
                                                    .foregroundColor(.black)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("クエスト一覧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: QuestCreateView(viewModel: viewModel)) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                }
            }
        }
        .onAppear {
            animateEmptyView = true
        }
    }
}

