//
//  HomeView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: QuestViewModel
    @State private var animateLevel = false
    @State private var animateGauge = false
    @State private var animateMissions = false
    @State private var showLevelUpEffect = false
    @State private var animateEmptyView = false
    @State private var characterPosition: CGFloat = 0
    @State private var backgroundOffset: CGFloat = 0
    @State private var characterJump = false
    @State private var currentStage = 0 // 現在のステージ（0: 森, 1: 山, 2: 海, 3: 城）TODO: UserDefaultsで保存
    @State private var stageTransition = false // ステージ遷移時のエフェクト

    private let stages = [
        (name: "森", background: Gradient(colors: [.green.opacity(0.5), .blue.opacity(0.3)]), icon: "leaf.fill", iconColor: Color.green.opacity(0.7)),
        (name: "山", background: Gradient(colors: [.gray.opacity(0.5), .blue.opacity(0.3)]), icon: "mountain.2.fill", iconColor: Color.gray.opacity(0.7)),
        (name: "海", background: Gradient(colors: [.blue.opacity(0.5), .cyan.opacity(0.3)]), icon: "drop.fill", iconColor: Color.blue.opacity(0.7)),
        (name: "城", background: Gradient(colors: [.purple.opacity(0.5), .gray.opacity(0.3)]), icon: "building.2.fill", iconColor: Color.purple.opacity(0.7))
    ]

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                if showLevelUpEffect {
                    ZStack {
                        ForEach(0..<10) { _ in
                            Image(systemName: "sparkle")
                                .foregroundColor(.yellow)
                                .font(.system(size: 20))
                                .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -100...100))
                                .opacity(animateLevel ? 1 : 0)
                                .animation(.easeOut(duration: 1).repeatCount(3, autoreverses: true), value: animateLevel)
                        }
                    }
                }

                ScrollView {
                    VStack(spacing: 20) {
                        // レベル表示とゲージ
                        VStack(spacing: 10) {
                            Text("レベル \(viewModel.level)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .scaleEffect(animateLevel ? 1.0 : 0.8)
                                .opacity(animateLevel ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: animateLevel)

                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 20)
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
                                    .frame(width: gaugeWidth, height: 20)
                                    .animation(.easeInOut(duration: 1).delay(0.4), value: animateGauge)
                                Text("\(viewModel.currentExp)/\(viewModel.expToNextLevel) EXP")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .padding(.horizontal)
                            .opacity(animateGauge ? 1 : 0)
                            .offset(y: animateGauge ? 0 : 20)
                            .animation(.easeInOut(duration: 0.5).delay(0.4), value: animateGauge)
                        }
                        .padding(.top)

                        // 冒険の旅セクション
                        SectionView(title: "冒険の旅 - ステージ: \(stages[currentStage].name)") {
                            ZStack(alignment: .bottomLeading) {
                                // 背景（ステージごとの変化）
                                ZStack {
                                    Rectangle()
                                        .fill(LinearGradient(gradient: stages[currentStage].background, startPoint: .top, endPoint: .bottom))
                                        .frame(height: 120)
                                    ForEach(0..<5) { i in
                                        Image(systemName: stages[currentStage].icon)
                                            .foregroundColor(stages[currentStage].iconColor)
                                            .font(.system(size: 20))
                                            .offset(x: CGFloat(i) * 80 + backgroundOffset, y: -40)
                                    }
                                }
                                .frame(height: 120)
                                .clipped()
                                .opacity(stageTransition ? 0 : 1)
                                .animation(.easeInOut(duration: 0.5), value: stageTransition)

                                // 道
                                Rectangle()
                                    .fill(Color.brown.opacity(0.5))
                                    .frame(height: 20)

                                // マイルストーン（無限に生成）
                                ForEach(1..<maxLevelToShow(), id: \.self) { level in
                                    if level % 5 == 0 {
                                        Image(systemName: level % 10 == 0 ? "flame.fill" : "star.fill")
                                            .foregroundColor(level % 10 == 0 ? .red : .yellow)
                                            .font(.system(size: 20))
                                            .offset(x: milestonePosition(level: level), y: -30)
                                            .overlay(
                                                Group {
                                                    if characterPosition >= milestonePosition(level: level) - 10 && characterPosition <= milestonePosition(level: level) + 10 {
                                                        ForEach(0..<5) { _ in
                                                            Image(systemName: "sparkle")
                                                                .foregroundColor(.yellow)
                                                                .font(.system(size: 10))
                                                                .offset(x: CGFloat.random(in: -10...10), y: CGFloat.random(in: -10...10))
                                                                .opacity(characterJump ? 1 : 0)
                                                                .animation(.easeInOut(duration: 1).repeatCount(3, autoreverses: true), value: characterJump)
                                                        }
                                                    }
                                                }
                                            )
                                    }
                                }

                                // 棒人間
                                VStack {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(.black)
                                        .font(.system(size: 30))
                                        .scaleEffect(characterJump ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: characterJump)
                                    Circle()
                                        .fill(Color.black)
                                        .frame(width: 10, height: 10)
                                        .offset(y: -10)
                                }
                                .offset(x: characterPosition + 50)
                                .animation(.easeInOut(duration: 1), value: characterPosition)
                            }
                            .frame(height: 120)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        }

                        // 今日のデイリーミッション
                        SectionView(title: "今日のデイリーミッション (\(viewModel.dailyQuests.count)/3)") {
                            if viewModel.dailyQuests.isEmpty {
                                VStack(spacing: 15) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                        .scaleEffect(animateEmptyView ? 1.0 : 0.8)
                                        .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateEmptyView)

                                    Text("デイリーミッションがありません")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.gray)

                                    Text("クエストタブからクエストを追加して、\nデイリーミッションを設定しましょう！")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
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
                                ForEach(viewModel.dailyQuests.indices, id: \.self) { index in
                                    let quest = viewModel.dailyQuests[index]
                                    NavigationLink(destination: QuestDetailView(viewModel: viewModel, quest: quest)) {
                                        DailyMissionCard(quest: quest, onComplete: {
                                            withAnimation { viewModel.completeQuest(quest) }
                                        })
                                    }
                                    .opacity(animateMissions ? 1 : 0)
                                    .offset(x: animateMissions ? 0 : -50)
                                    .animation(.easeInOut(duration: 0.5).delay(Double(index) * 0.2 + 0.6), value: animateMissions)
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("ホーム")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
            }
        }
        .onAppear {
            animateLevel = true
            animateGauge = true
            animateMissions = true
            animateEmptyView = true
            updateAdventureProgress()
        }
        .onChange(of: viewModel.level) { newLevel in
            updateAdventureProgress()
            characterJump = true
        }
        .onChange(of: viewModel.showLevelUp) { newValue in
            if newValue {
                showLevelUpEffect = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showLevelUpEffect = false
                    viewModel.showLevelUp = false
                }
            }
        }
    }

    private var gaugeWidth: CGFloat {
        let progress = CGFloat(viewModel.currentExp) / CGFloat(viewModel.expToNextLevel)
        return min(max(progress * (UIScreen.main.bounds.width - 40), 0), UIScreen.main.bounds.width - 40)
    }

    private func milestonePosition(level: Int) -> CGFloat {
        let cycleLength = UIScreen.main.bounds.width - 100
        return CGFloat(level * 50) - (CGFloat(currentStage) * cycleLength)
    }

    private func maxLevelToShow() -> Int {
        return viewModel.level + 10 // 現在のレベルより10先まで表示
    }

    private func updateAdventureProgress() {
        let cycleLength = UIScreen.main.bounds.width - 100
        let rawPosition = CGFloat(viewModel.level) * 50
        let cycleCount = Int(rawPosition / cycleLength)
        characterPosition = rawPosition.truncatingRemainder(dividingBy: cycleLength)

        // ステージの更新
        let newStage = cycleCount % stages.count
        if newStage != currentStage {
            stageTransition = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                stageTransition = false
            }
        }
        currentStage = newStage

        // 背景のスクロール（ステージごとにリセット）
        backgroundOffset = -(characterPosition / 2)
    }
}
