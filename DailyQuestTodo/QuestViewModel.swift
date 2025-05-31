//
//  QuestViewModel.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftData
import Foundation

@MainActor
class QuestViewModel: ObservableObject {
    @Published var quests: [Quest] = []
    @Published var dailyQuests: [Quest] = []
    @Published var level: Int = 1
    @Published var currentExp: Int = 0
    @Published var expToNextLevel: Int = 100
    @Published var showLevelUp: Bool = false

    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        do {
            try fetchQuests()
            checkDailyReset()
        } catch {
            print("初期化中のエラー: \(error.localizedDescription)")
        }
    }

    func fetchQuests() throws {
        let descriptor = FetchDescriptor<Quest>()
        do {
            let fetchedQuests = try modelContext.fetch(descriptor)
            quests = fetchedQuests
            dailyQuests = fetchedQuests.filter { $0.isDaily }
            print("クエストをフェッチしました: \(quests.count)件")
        } catch {
            print("クエストのフェッチに失敗: \(error.localizedDescription)")
            quests = []
            dailyQuests = []
            throw error
        }
    }

    func addQuest(content: String, priority: Int, difficulty: String, details: String) {
        let baseExp = priority * 10
        let expMultiplier: Int
        switch difficulty {
        case "easy":
            expMultiplier = 1
        case "hard":
            expMultiplier = 3
        default: // "normal"
            expMultiplier = 2
        }
        let exp = baseExp * expMultiplier
        let quest = Quest(content: content, priority: priority, difficulty: difficulty, exp: exp, details: details)
        modelContext.insert(quest)
        do {
            try modelContext.save()
            try fetchQuests()
        } catch {
            print("クエスト追加時のエラー: \(error.localizedDescription)")
        }
    }

    func setDailyQuest(_ quest: Quest) {
        if dailyQuests.count < 3 {
            quest.isDaily = true
            do {
                try modelContext.save()
                try fetchQuests()
            } catch {
                print("デイリー設定時のエラー: \(error.localizedDescription)")
            }
        }
    }

    func removeDailyQuest(_ quest: Quest) {
        quest.isDaily = false
        do {
            try modelContext.save()
            try fetchQuests()
        } catch {
            print("デイリー解除時のエラー: \(error.localizedDescription)")
        }
    }

    func completeQuest(_ quest: Quest) {
        quest.isCompleted = true
        currentExp += quest.exp
        if currentExp >= expToNextLevel {
            level += 1
            currentExp -= expToNextLevel
            expToNextLevel += 50
            showLevelUp = true
        }
        do {
            try modelContext.save()
            try fetchQuests()
        } catch {
            print("クエスト完了時のエラー: \(error.localizedDescription)")
        }
    }

    func failQuest(_ quest: Quest) {
        quest.failCount += 1
        do {
            try modelContext.save()
            try fetchQuests()
        } catch {
            print("クエスト失敗時のエラー: \(error.localizedDescription)")
        }
    }

    func deleteQuest(_ quest: Quest) {
        modelContext.delete(quest)
        do {
            try modelContext.save()
            try fetchQuests()
        } catch {
            print("クエスト削除時のエラー: \(error.localizedDescription)")
        }
    }

    func checkDailyReset() {
        let calendar = Calendar.current
        let now = Date()
        if calendar.component(.day, from: now) != calendar.component(.day, from: quests.first?.createdAt ?? now) {
            dailyQuests.forEach { $0.isDaily = false }
            do {
                try modelContext.save()
                try fetchQuests()
            } catch {
                print("デイリーリセット時のエラー: \(error.localizedDescription)")
            }
        }
    }

    func totalCompletedQuests() -> Int {
        quests.filter { $0.isCompleted }.count
    }

    func totalFailedQuests() -> Int {
        quests.map { $0.failCount }.reduce(0, +)
    }

    func totalEarnedExp() -> Int {
        quests.map { $0.isCompleted ? $0.exp : 0 }.reduce(0, +)
    }

    func weeklyCompletedData() -> [(day: String, count: Int)] {
        let calendar = Calendar.current
        let today = Date()
        var data: [(day: String, count: Int)] = []

        let days = ["月", "火", "水", "木", "金", "土", "日"]

        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date) - 2
            let dayIndex = (weekday + 7) % 7
            let dayName = days[dayIndex]

            let completedOnDay = quests.filter { quest in
                guard quest.isCompleted else { return false }
                return calendar.isDate(quest.createdAt, inSameDayAs: date)
            }.count

            data.append((day: dayName, count: completedOnDay))
        }

        return data.reversed()
    }

    func difficultyCompletedData() -> [(difficulty: String, count: Int)] {
        let difficulties = ["easy", "normal", "hard"]
        var data: [(difficulty: String, count: Int)] = []

        for difficulty in difficulties {
            let count = quests.filter { $0.difficulty == difficulty && $0.isCompleted }.count
            data.append((difficulty: difficulty, count: count))
        }

        return data
    }

    func questStatusData() -> [(status: String, count: Int)] {
        let completed = quests.filter { $0.isCompleted }.count
        let failed = totalFailedQuests()
        let incompleted = quests.count - completed

        return [
            (status: "達成済み", count: completed),
            (status: "未達成", count: incompleted),
            (status: "失敗", count: failed)
        ]
    }
}
