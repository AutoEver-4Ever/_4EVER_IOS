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
                // 헤더
                HStack {
                    Text("견적 관리")
                        .font(.title2.bold())
                    Spacer()
                }
                .padding()

                // 검색 + 상태 필터
                VStack(spacing: 8) {
                    SearchGlassBar(text: $searchTerm, type: $searchType) { text, type in
                        vm.applySearch(text, type: type)
                    }

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

                // 리스트
                ScrollView {
                    if vm.isLoading && vm.items.isEmpty {
                        ProgressView().padding(.top, 40)
                    } else if let err = vm.error, vm.items.isEmpty {
                        ErrorStateCard(title: "견적 목록을 불러오지 못했습니다.", message: err) { vm.loadInitial() }
                        .padding(.horizontal)
                        .padding(.top, 40)
                    } else if vm.items.isEmpty {
                        EmptyStateCard(message: "목록이 비어 있습니다.")
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(vm.items.enumerated()), id: \.offset) { idx, item in
                                NavigationLink(destination: QuoteDetailView(id: item.quotationNumber)) {
                                    QuotationListItemCard(item: item)
                                }
                                .onAppear {
                                    if idx == vm.items.count - 1 { vm.loadNextPage() }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                        if vm.isLoading { ProgressView().padding(.bottom, 16) }
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
