//
//  ContentView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: QuestViewModel

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: QuestViewModel(modelContext: modelContext))
    }

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.1), .green.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            TabView {
                HomeView(viewModel: viewModel)
                    .tabItem {
                        Label("ホーム", systemImage: "house.fill")
                    }
                QuestListView(viewModel: viewModel)
                    .tabItem {
                        Label("クエスト", systemImage: "list.star")
                    }
                DashboardView(viewModel: viewModel)
                    .tabItem {
                        Label("ダッシュボード", systemImage: "chart.xyaxis.line")
                    }
            }
            .tint(.green)
            .onAppear {
                UITabBar.appearance().backgroundColor = .systemBackground.withAlphaComponent(0.95)
            }
        }
    }
}

// 説明: ContentView.swift
// - タブバーをモダンに。背景に薄いグラデーション（青〜緑）を追加し、ゲームっぽい雰囲気。
// - タブアイコンをゲーム風に（例: `list.star`, `chart.xyaxis.line`）。
// - タブバーの背景を半透明にし、モダンで軽やかな印象に。
// - Dynamic Type対応で、フォントサイズがユーザーの設定に適応。
