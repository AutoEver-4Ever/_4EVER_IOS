//
//  PurchaseOrderHeaderBar.swift
//  Erp4ever-iOS
//
//  헤더: 제목 + 검색 버튼 + 검색 타입 선택이 포함된 확장형 검색바.
//

import SwiftUI

struct PurchaseOrderHeaderBar: View {
    @Binding var isSearchMode: Bool
    @Binding var searchTerm: String
    @Binding var searchType: String // "SupplierCompanyName" | "PurchaseOrderNumber"
    @Binding var showTypePrompt: Bool

    var onSearch: (String, String) -> Void

    @FocusState private var searchFocused: Bool

    private var placeholder: String {
        switch searchType {
        case "PurchaseOrderNumber":
            return "발주서번호로 검색"
        default:
            return "공급사명으로 검색"
        }
    }

    private var typeLabel: String {
        switch searchType {
        case "PurchaseOrderNumber":
            return "발주서번호"
        default:
            return "공급사명"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            if isSearchMode {
                searchField
                    .padding(12)
                    .glassBackground(shape: .rounded(14))
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .onAppear { searchFocused = true }
                    .onChange(of: isSearchMode) { _, newValue in
                        if newValue { searchFocused = true }
                    }

                Button("취소") {
                    withAnimation(Anim.spring) { showTypePrompt = false }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Anim.searchPromptOutDelay) {
                        withAnimation(Anim.spring) {
                            isSearchMode = false
                            searchTerm = ""
                            searchFocused = false
                            onSearch("", searchType)
                        }
                    }
                }
                .font(.body)
                .tint(.blue)
            } else {
                Text("발주서")
                    .font(.title2.bold())
                Spacer()
                Button {
                    withAnimation(Anim.spring) {
                        isSearchMode = true
                        showTypePrompt = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + Anim.searchPromptInDelay) {
                        withAnimation(Anim.spring) { showTypePrompt = true }
                    }
                } label: {
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

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(placeholder, text: $searchTerm)
                .textFieldStyle(.plain)
                .focused($searchFocused)
                .onChange(of: searchTerm) { _, newValue in
                    if !newValue.isEmpty {
                        onSearch(newValue, searchType)
                        withAnimation(.spring()) { showTypePrompt = false }
                    } else {
                        onSearch("", searchType)
                        withAnimation(.spring()) { showTypePrompt = true }
                    }
                }

            if !searchTerm.isEmpty {
                Button {
                    searchTerm = ""
                    onSearch("", searchType)
                    withAnimation(.spring()) { showTypePrompt = true }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Menu {
                Button("공급사명") {
                    searchType = "SupplierCompanyName"
                    if !searchTerm.isEmpty {
                        onSearch(searchTerm, searchType)
                        withAnimation(.spring()) { showTypePrompt = false }
                    }
                }
                Button("발주서번호") {
                    searchType = "PurchaseOrderNumber"
                    if !searchTerm.isEmpty {
                        onSearch(searchTerm, searchType)
                        withAnimation(.spring()) { showTypePrompt = false }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(typeLabel)
                        .font(.caption.weight(.semibold))
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    struct PreviewHost: View {
        @State var isSearchMode = false
        @State var term = ""
        @State var type = "SupplierCompanyName"
        @State var showPrompt = false

        var body: some View {
            PurchaseOrderHeaderBar(
                isSearchMode: $isSearchMode,
                searchTerm: $term,
                searchType: $type,
                showTypePrompt: $showPrompt,
                onSearch: { _, _ in }
            )
        }
    }

    return PreviewHost()
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
}
