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
    @State private var searchScope: QuoteSearchType = .quotationNumber
    @State private var isSearchPresented: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    statusFilter
                        .padding(.top, 8)

                    QuoteListSection(
                        items: vm.items,
                        isLoading: vm.isLoading,
                        error: vm.error,
                        onRetry: { vm.loadInitial() },
                        onReachEnd: { vm.loadNextPage() }
                    )
                }
                .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("견적 관리")
            .navigationBarTitleDisplayMode(.large)
        }
        .searchScopes($searchScope) {
            ForEach(QuoteSearchType.allCases) { scope in
                Text(scope.label).tag(scope)
            }
        }
        .onSubmit(of: .search) { triggerSearch() }
        .onChange(of: searchTerm) { _, _ in triggerSearch() }
        .onChange(of: searchScope) { _, _ in triggerSearch() }
        .onChange(of: isSearchPresented) { _, presented in
            if !presented {
                searchTerm = ""
                vm.applySearch("", type: searchScope.rawValue)
            }
        }
        .onAppear {
            if vm.items.isEmpty { vm.loadInitial() }
        }
    }

    private var statusFilter: some View {
        VStack(spacing: 8) {
            Picker("상태", selection: $statusSelection) {
                Text("전체").tag("ALL")
                Text("대기").tag("PENDING")
                Text("검토중").tag("REVIEW")
            }
            .pickerStyle(.segmented)
            .onChange(of: statusSelection) { _, newValue in
                vm.applyStatus(newValue == "ALL" ? nil : newValue)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    private func triggerSearch() {
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        vm.applySearch(trimmed, type: searchScope.rawValue)
    }
}


// MARK: - Supporting Types

private enum QuoteSearchType: String, CaseIterable, Identifiable {
    case quotationNumber
    case customerName
    case managerName

    var id: String { rawValue }

    var label: String {
        switch self {
        case .quotationNumber: return "견적번호"
        case .customerName: return "고객명"
        case .managerName: return "담당자"
        }
    }

    var placeholder: String {
        switch self {
        case .quotationNumber: return "견적번호로 검색"
        case .customerName: return "고객명으로 검색"
        case .managerName: return "담당자로 검색"
        }
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

