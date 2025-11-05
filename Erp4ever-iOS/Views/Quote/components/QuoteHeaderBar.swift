//
//  QuoteHeaderBar.swift
//  Erp4ever-iOS
//
//  Header with title, circular glass search button, and expandable search bar.
//

import SwiftUI

struct QuoteHeaderBar: View {
    @Binding var isSearchMode: Bool
    @Binding var searchTerm: String
    @Binding var searchType: String
    @Binding var showTypePrompt: Bool
    var onSearch: (String, String) -> Void

    @FocusState private var searchFocused: Bool

    private var placeholder: String {
        switch searchType {
        case "quotationNumber": return "견적번호로 검색"
        case "customerName": return "고객명으로 검색"
        case "managerName": return "담당자로 검색"
        default: return "검색"
        }
    }

    private var typeLabel: String {
        switch searchType {
        case "quotationNumber": return "견적번호"
        case "customerName": return "고객명"
        case "managerName": return "담당자"
        default: return "타입"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            if isSearchMode {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField(
                        placeholder,
                        text: $searchTerm
                    )
                    .focused($searchFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchTerm) { _, newValue in
                        if !newValue.isEmpty, !searchType.isEmpty {
                            onSearch(newValue, searchType)
                            withAnimation(.spring()) { showTypePrompt = false }
                        } else {
                            withAnimation(.spring()) { showTypePrompt = true }
                        }
                    }
                    if !searchTerm.isEmpty {
                        Button(action: { searchTerm = ""; withAnimation(.spring()) { showTypePrompt = true } }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Menu {
                        Button("견적번호") { searchType = "quotationNumber"; if !searchTerm.isEmpty { onSearch(searchTerm, searchType); withAnimation(.spring()) { showTypePrompt = false } } }
                        Button("고객명") { searchType = "customerName"; if !searchTerm.isEmpty { onSearch(searchTerm, searchType); withAnimation(.spring()) { showTypePrompt = false } } }
                        Button("담당자") { searchType = "managerName"; if !searchTerm.isEmpty { onSearch(searchTerm, searchType); withAnimation(.spring()) { showTypePrompt = false } } }
                    } label: {
                        HStack(spacing: 4) {
                            Text(typeLabel)
                                .font(.caption.weight(.semibold))
                            Image(systemName: "chevron.up.chevron.down").font(.caption2)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(12)
                .glassBackground(shape: .rounded(14))
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .onAppear { searchFocused = true }
                .onChange(of: isSearchMode) { _, newValue in
                    if newValue { searchFocused = true }
                }

                Button("취소") {
                    withAnimation(Anim.spring) {
                        // 프롬프트 먼저 아래로 내려가게 하고 검색 모드 종료는 상위에서 관리 가능
                        showTypePrompt = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Anim.searchPromptOutDelay) {
                        withAnimation(Anim.spring) {
                            isSearchMode = false
                            searchTerm = ""
                            searchFocused = false
                        }
                    }
                }
                .font(.body)
                .tint(.blue)
            } else {
                Text("견적 관리")
                    .font(.title2.bold())
                Spacer()
                Button(action: {
                    withAnimation(Anim.spring) {
                        isSearchMode = true
                        // 검색바 먼저 펼치고, 프롬프트는 약간 지연 후 아래에서 등장 (상위에서 showTypePrompt 제어 권장)
                        showTypePrompt = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Anim.searchPromptInDelay) {
                        withAnimation(Anim.spring) { showTypePrompt = true }
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(10)
                        .glassBackground(shape: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("검색")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}
