//
//  SupplierInvoiceHeaderBar.swift
//  Erp4ever-iOS
//
//  매출 전표 목록 상단 헤더(제목 + 검색).
//

import SwiftUI

struct SupplierInvoiceHeaderBar: View {
    @Binding var isSearchMode: Bool
    @Binding var searchText: String

    @FocusState private var focused: Bool

    var onSearch: (String) -> Void

    var body: some View {
        HStack(spacing: 8) {
            if isSearchMode {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("회사명으로 검색", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($focused)
                        .onChange(of: searchText) { _, newValue in
                            onSearch(newValue)
                        }
                    if !searchText.isEmpty {
                        Button { searchText = ""; onSearch("") } label: {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
                .glassBackground(shape: .rounded(14))
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .onAppear { focused = true }

                Button("취소") {
                    withAnimation(Anim.spring) { isSearchMode = false }
                    searchText = ""; onSearch(""); focused = false
                }
                .font(.body)
                .tint(.blue)
            } else {
                Text("매출 전표")
                    .font(.title2.bold())
                Spacer()
                Button {
                    withAnimation(Anim.spring) { isSearchMode = true }
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
}

