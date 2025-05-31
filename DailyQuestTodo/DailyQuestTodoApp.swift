//
//  DailyQuestTodoApp.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI
import SwiftData

@main
struct DailyQuestTodoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([Quest.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("データベースパス: \(modelConfiguration.url.path)")
            return container
        } catch {
            fatalError("モデルコンテナの初期化に失敗: \(error.localizedDescription)")
        }
    }()
}

// 説明: DailyQuestTodoApp.swift
// - アプリ名を `DailyQuestApp` から `DailyQuestTodoApp` に変更。
// - SwiftDataのモデルコンテナをセットアップ。`Quest` をスキーマに登録。
// - `isStoredInMemoryOnly: false` で永続保存。
// - デバッグ用にデータベースパスをログ出力（クラッシュ原因の特定に役立つ）。
// - 初期化エラー時に `fatalError` で詳細を表示。
