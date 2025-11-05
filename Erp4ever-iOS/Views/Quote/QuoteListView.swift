//
//  QuoteListView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct QuoteListView: View {
    @StateObject private var vm: QuoteListViewModel
    @State private var searchTerm: String = ""
    @State private var statusSelection: String = "ALL" // ALL, PENDING, REVIEW
    @State private var searchType: String = "quotationNumber" // quotationNumber | customerName | managerName
    @State private var isSearchMode: Bool = false
    @State private var showTypePrompt: Bool = true
    @FocusState private var searchFocused: Bool

    private var searchPlaceholder: String {
        switch searchType {
        case "quotationNumber": return "견적번호로 검색"
        case "customerName": return "고객명으로 검색"
        case "managerName": return "담당자로 검색"
        default: return "검색"
        }
    }

    private var searchTypeLabel: String {
        switch searchType {
        case "quotationNumber": return "견적번호"
        case "customerName": return "고객명"
        case "managerName": return "담당자"
        default: return "타입"
        }
    }

    private func mapStatusLabel(_ code: String) -> String {
        switch code.uppercased() {
        case "REVIEW": return "검토중"
        case "APPROVAL": return "승인됨"
        case "REJECTED": return "거절됨"
        case "PENDING": return "대기"
        default: return "대기"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                QuoteHeaderBar(
                    isSearchMode: $isSearchMode,
                    searchTerm: $searchTerm,
                    searchType: $searchType,
                    showTypePrompt: $showTypePrompt,
                    onSearch: { text, type in
                        vm.applySearch(text, type: type)
                    }
                )

                // 상태 필터 (검색 모드 아닐 때만 표시)
                if !isSearchMode {
                    VStack(spacing: 8) {
                        // 간단한 상태 필터 Segmented
                        Picker("상태", selection: $statusSelection) {
                        Text("전체").tag("ALL")
                        Text("대기").tag("PENDING")
                        Text("검토중").tag("REVIEW")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: statusSelection) { oldValue, newValue in
                        vm.applyStatus(newValue == "ALL" ? nil : newValue)
                    }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // 리스트 또는 타입 선택 프롬프트
                ScrollView {
                    if isSearchMode && showTypePrompt {
                        QuoteTypePromptView(selectedType: $searchType)
                    }
                    if !(isSearchMode && showTypePrompt) {
                        QuoteListSection(
                            items: vm.items,
                            isLoading: vm.isLoading,
                            error: vm.error,
                            onRetry: { vm.loadInitial() },
                            onReachEnd: { vm.loadNextPage() }
                        )
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                if vm.items.isEmpty { vm.loadInitial() }
            }
        }
    }
}

// Moved to Views/Quote/components/QuoteHeaderBar.swift
private struct HeaderBar: View {
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
                        Button(action: { searchTerm = ""; showTypePrompt = true }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }

                    Menu {
                        Button("견적번호") { searchType = "quotationNumber"; if !searchTerm.isEmpty { onSearch(searchTerm, searchType); showTypePrompt = false } }
                        Button("고객명") { searchType = "customerName"; if !searchTerm.isEmpty { onSearch(searchTerm, searchType); showTypePrompt = false } }
                        Button("담당자") { searchType = "managerName"; if !searchTerm.isEmpty { onSearch(searchTerm, searchType); showTypePrompt = false } }
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
                .background(
                    Group {
                        if #available(iOS 15.0, *) {
                            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.ultraThinMaterial)
                        } else {
                            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.white.opacity(0.6))
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .onAppear { searchFocused = true }
                .onChange(of: isSearchMode) { _, newValue in
                    if newValue { searchFocused = true }
                }

                Button("취소") {
                    withAnimation(.spring()) {
                        // 프롬프트 먼저 아래로 내려가게 하고 검색 모드 종료
                        showTypePrompt = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        withAnimation(.spring()) {
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
                    .font(.title.bold())
                    .padding(.bottom, 20)
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        isSearchMode = true
                        // 검색바 먼저 펼치고, 프롬프트는 약간 지연 후 아래에서 등장
                        showTypePrompt = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.spring()) { showTypePrompt = true }
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(
                            Group {
                                if #available(iOS 15.0, *) {
                                    Circle().fill(.ultraThinMaterial)
                                } else {
                                    Circle().fill(Color.white.opacity(0.6))
                                }
                            }
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("검색")
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - 의존성
extension QuoteListView {
    init(vm: QuoteListViewModel = QuoteListViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }
}

// MARK: - Preview with mock data
#Preview("QuoteListView – Mock Data") {
    let mockVM = QuoteListViewModel()
    mockVM.items = [
        QuotationListItem(
            quotationId: "018f2c1a-aaaa-bbbb-cccc-000000000001",
            quotationNumber: "Q2024-001",
            customerName: "현대자동차",
            productId: "PROD-001",
            dueDate: "2024-02-15",
            quantity: 10,
            uomName: "EA",
            statusCode: "REVIEW"
        ),
        QuotationListItem(
            quotationId: "018f2c1a-aaaa-bbbb-cccc-000000000002",
            quotationNumber: "Q2024-002",
            customerName: "기아자동차",
            productId: "PROD-002",
            dueDate: "2024-03-01",
            quantity: 5,
            uomName: "EA",
            statusCode: "APPROVAL"
        ),
        QuotationListItem(
            quotationId: "018f2c1a-aaaa-bbbb-cccc-000000000003",
            quotationNumber: "Q2024-003",
            customerName: "쌍용자동차",
            productId: nil,
            dueDate: "2024-02-05",
            quantity: nil,
            uomName: nil,
            statusCode: "PENDING"
        )
    ]
    mockVM.hasNext = false
    return QuoteListView(vm: mockVM)
}
