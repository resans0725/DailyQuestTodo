//
//  QuestCreateView.swift
//  DailyQuestTodo
//
//  Created by 永井涼 on 2025/05/31.
//
import SwiftUI

struct QuestCreateView: View {
    @ObservedObject var viewModel: QuestViewModel
    @Environment(\.dismiss) var dismiss
    @State private var content: String = ""
    @State private var priority: Int = 1
    @State private var difficulty: String = "normal"
    @State private var details: String = ""
    private let detailsMaxLength = 200

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.2), .green.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 15) {
                        TextField("クエスト内容", text: $content)
                            .font(.system(size: 16, design: .rounded))
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

                        VStack(alignment: .leading, spacing: 5) {
                            Text("詳細（最大\(detailsMaxLength)文字）")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            TextEditor(text: $details)
                                .font(.system(size: 16, design: .rounded))
                                .frame(height: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                                .onChange(of: details) { newValue in
                                    if newValue.count > detailsMaxLength {
                                        details = String(newValue.prefix(detailsMaxLength))
                                    }
                                }
                            Text("文字数: \(details.count)/\(detailsMaxLength)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(details.count >= detailsMaxLength ? .red : .gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        VStack(alignment: .leading, spacing: 5) {
                            Text("優先度")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.gray)
                            Picker("優先度: 低/中/高", selection: $priority) {
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
                            Picker("難易度: イージー/ノーマル/ハード", selection: $difficulty) {
                                Text("イージー").tag("easy")
                                Text("ノーマル").tag("normal")
                                Text("ハード").tag("hard")
                            }
                            .pickerStyle(.segmented)
                        }

                        Button(action: {
                            if !content.isEmpty {
                                withAnimation {
                                    viewModel.addQuest(content: content, priority: priority, difficulty: difficulty, details: details)
                                    dismiss()
                                }
                            }
                        }) {
                            Text("作成")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .disabled(content.isEmpty)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding()
                }
            }
            .navigationTitle("クエスト作成")
        }
    }
}
