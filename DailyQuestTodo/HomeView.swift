//
//  HomeView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: QuestViewModel
    @State private var animateLevel = false
    @State private var animateGauge = false
    @State private var animateMissions = false
    @State private var showLevelUpEffect = false
    @State private var animateEmptyView = false

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
                                .rotation3DEffect(.degrees(animateLevel ? 0 : 360), axis: (x: 0, y: 1, z: 0))
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

                        SectionView(title: "今日のデイリーミッション (\(viewModel.dailyQuests.count)/3)") {
                            if viewModel.dailyQuests.isEmpty {
                                // エンプティービュー
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
                                .padding(.top)
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
}
