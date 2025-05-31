//
//  Quest.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftData
import Foundation

@Model
class Quest {
    var id: UUID
    var content: String
    var priority: Int
    var difficulty: String // 難易度: easy/normal/hard
    var exp: Int
    var failCount: Int
    var isDaily: Bool
    var createdAt: Date
    var isCompleted: Bool
    var details: String

    init(content: String, priority: Int, difficulty: String, exp: Int, failCount: Int = 0, isDaily: Bool = false, details: String = "") {
        self.id = UUID()
        self.content = content
        self.priority = priority
        self.difficulty = difficulty
        self.exp = exp
        self.failCount = failCount
        self.isDaily = isDaily
        self.createdAt = Date()
        self.isCompleted = false
        self.details = details
    }
}
// 説明: Quest.swift
// - SwiftDataのモデル。クエストのデータを定義。
// - 属性: ID、内容、優先度（1〜3）、難易度（通常/緊急）、経験値、失敗回数、デイリー指定、作成日、完了状態。
// - コンストラクタで初期値を設定。デフォルトで失敗回数は0、デイリー指定はfalse。
// - 新規追加: `details` プロパティを追加（デフォルトは空文字列）。
// - 200文字制限はビュー側（`QuestCreateView`）で実装。
