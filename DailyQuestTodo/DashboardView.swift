//
//  DashboardView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @ObservedObject var viewModel: QuestViewModel

    // グラフデータを事前計算
    private var weeklyData: [(day: String, count: Int)] {
        viewModel.weeklyCompletedData()
    }
    private var difficultyData: [(difficulty: String, count: Int)] {
        viewModel.difficultyCompletedData()
    }
    private var statusData: [(status: String, count: Int)] {
        viewModel.questStatusData()
    }
    private var weeklyMax: Int {
        max(5, (weeklyData.map { $0.count }.max() ?? 0) + 1)
    }
    private var difficultyMax: Int {
        max(5, (difficultyData.map { $0.count }.max() ?? 0) + 1)
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                            GridRow {
                                StatCard(title: "達成クエスト", value: "\(viewModel.totalCompletedQuests())", color: .green)
                                StatCard(title: "失敗回数", value: "\(viewModel.totalFailedQuests())", color: .red)
                            }
                            GridRow {
                                StatCard(title: "現在のレベル", value: "\(viewModel.level)", color: .blue)
                                StatCard(title: "総経験値", value: "\(viewModel.totalEarnedExp())", color: .purple)
                            }
                        }
                        .padding()

                        // 週ごとの達成数（棒グラフ）
                        SectionView(title: "週ごとの達成数") {
                            Chart(weeklyData, id: \.day) { item in
                                BarMark(
                                    x: .value("曜日", item.day),
                                    y: .value("達成数", item.count)
                                )
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .top, endPoint: .bottom))
                                .cornerRadius(8)
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .chartYScale(domain: 0...weeklyMax)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.quests)
                        }
                        
                        // クエストの状態割合（円グラフ）
                        SectionView(title: "クエストの状態割合") {
                            Chart(statusData, id: \.status) { item in
                                SectorMark(
                                    angle: .value("割合", item.count),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(by: .value("状態", item.status))
                                .foregroundStyle(
                                    item.status == "達成済み" ? .green :
                                    item.status == "未達成" ? .gray : .red
                                )
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.quests)
                        }

                        // 直近7日間の達成数推移（折れ線グラフ）
                        SectionView(title: "直近7日間の達成数推移") {
                            Chart(weeklyData, id: \.day) { item in
                                LineMark(
                                    x: .value("曜日", item.day),
                                    y: .value("達成数", item.count)
                                )
                                .foregroundStyle(.blue)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .interpolationMethod(.catmullRom)
                                .symbol {
                                    Circle()
                                        .fill(.white)
                                        .strokeBorder(.blue, lineWidth: 2)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .chartYScale(domain: 0...weeklyMax)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.quests)
                        }

                        // 難易度ごとの達成数（エリアグラフ）
                        SectionView(title: "難易度ごとの達成数") {
                            Chart(difficultyData, id: \.difficulty) { item in
                                AreaMark(
                                    x: .value("難易度", item.difficulty),
                                    y: .value("達成数", item.count)
                                )
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.green.opacity(0.5), .blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
                            }
                            .frame(height: 200)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .chartYScale(domain: 0...difficultyMax)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.quests)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("ダッシュボード")
        }
    }
}

// 説明: DashboardView.swift
// - 修正: 折れ線グラフ（`LineMark`）の `.symbol` を修正。
//   - `.symbol(Circle().strokeBorder(.blue, lineWidth: 2).frame(width: 8, height: 8))` を `.symbol { ... }` に変更。
//   - `Circle()` を `Shape` として正しく使い、`.fill(.white)` と `.strokeBorder(.blue, lineWidth: 2)` で白い円に青い枠を描画。
// - その他のグラフ（棒、エリア、円）は変更なし。
// - モダンなデザイン（グラデーション、角丸、シャドウ、アニメーション）を維持。
