//
//  PurchaseOrderListView.swift
//  Erp4ever-iOS
//
//  공급사용 발주서 목록. 견적 검색 디자인을 참고한 검색/필터 UI.
//

import SwiftUI

struct PurchaseOrderListView: View {
    @StateObject private var vm = PurchaseOrderListViewModel()
    @State private var isSearchMode: Bool = false
    @State private var keyword: String = ""
    @State private var searchType: String = "SupplierCompanyName" // SupplierCompanyName | PurchaseOrderNumber
    @State private var statusSelection: String = "ALL"
    @State private var showDateSheet: Bool = false
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil

    private func formatKRW(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let f = NumberFormatter(); f.numberStyle = .decimal
        return "\(f.string(from: number) ?? "0")원"
    }

    private func formatDate(_ d: Date) -> String { let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d) }
    private func dateRangeLabel() -> String {
        switch (startDate, endDate) {
        case (nil, nil): return "전체 기간"
        case let (s?, nil): return "\(formatDate(s)) ~"
        case let (nil, e?): return "~ \(formatDate(e))"
        case let (s?, e?): return "\(formatDate(s)) ~ \(formatDate(e))"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 공통 헤더(리퀴드 글래스 검색)
                InvoiceHeaderBar(isSearchMode: $isSearchMode, searchText: $keyword) { text in
                    vm.applySearch(type: searchType, keyword: text)
                }

                // 상태/검색 타입/기간 필터 바
                HStack(spacing: 8) {
                    Picker("상태", selection: $statusSelection) {
                        Text("전체").tag("ALL"); Text("승인").tag("APPROVAL"); Text("대기").tag("PENDING"); Text("반려").tag("REJECTED"); Text("배송중").tag("DELIVERING"); Text("완료").tag("DELIVERED")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: statusSelection) { _, newValue in vm.applyStatus(newValue) }

                    // 검색 타입 선택(공급사명/발주서번호)
                    Menu {
                        Button("공급사명") { searchType = "SupplierCompanyName"; if !keyword.isEmpty { vm.applySearch(type: searchType, keyword: keyword) } }
                        Button("발주서번호") { searchType = "PurchaseOrderNumber"; if !keyword.isEmpty { vm.applySearch(type: searchType, keyword: keyword) } }
                    } label: {
                        HStack(spacing: 4) {
                            Text(searchType == "SupplierCompanyName" ? "공급사명" : "발주서번호").font(.caption.weight(.semibold))
                            Image(systemName: "chevron.up.chevron.down").font(.caption2)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    }

                    Spacer()
                    Button { showDateSheet = true } label: {
                        HStack(spacing: 6) { Image(systemName: "calendar"); Text(dateRangeLabel()).font(.caption) }
                            .padding(.horizontal, 10).padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    }.buttonStyle(.plain)

                    if startDate != nil || endDate != nil {
                        Button("지우기") { startDate = nil; endDate = nil; vm.applyDateRange(start: nil, end: nil) }.font(.caption)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // 목록
                ScrollView {
                    if vm.isLoading && vm.items.isEmpty { ProgressView().padding(.top, 40) }
                    else if let err = vm.error, vm.items.isEmpty {
                        ErrorStateCard(title: "발주서 목록을 불러오지 못했습니다.", message: err) { vm.loadInitial() }
                            .padding(.horizontal).padding(.top, 40)
                    } else if vm.items.isEmpty {
                        EmptyStateCard(message: "목록이 비어 있습니다.").padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(vm.items.enumerated()), id: \.offset) { idx, item in
                                NavigationLink(destination: PurchaseOrderDetailView(id: item.purchaseOrderId)) {
                                    Card {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack { Text(item.purchaseOrderNumber).font(.subheadline.bold()).foregroundColor(.blue); Spacer(); StatusLabel(statusCode: invoiceStatusLabel(from: item.statusCode)) }
                                            Group {
                                            HStack { Text("공급사").foregroundColor(.secondary); Spacer(); Text(item.supplierName ?? "-") }
                                                HStack { Text("발행일").foregroundColor(.secondary); Spacer(); Text(String(item.orderDate.prefix(10))) }
                                                HStack { Text("납기일").foregroundColor(.secondary); Spacer(); Text(String(item.dueDate.prefix(10))) }
                                                HStack { Text("금액").foregroundColor(.secondary); Spacer(); Text(formatKRW(item.totalAmount)).foregroundColor(.blue).bold() }
                                            }.font(.footnote)
                                        }
                                    }
                                }
                                .onAppear { if idx == vm.items.count - 1 { vm.loadNextPage() } }
                            }
                        }
                        .padding(.horizontal).padding(.top, 12).padding(.bottom, 16)
                        if vm.isLoading { ProgressView().padding(.bottom, 16) }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .sheet(isPresented: $showDateSheet) {
                    DateRangeSheet(startDate: $startDate, endDate: $endDate, onApply: {
                        vm.applyDateRange(start: startDate.map(formatDate), end: endDate.map(formatDate)); showDateSheet = false
                    }, onCancel: { showDateSheet = false })
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onAppear { if vm.items.isEmpty { vm.loadInitial() } }
        }
    }
}

#Preview { PurchaseOrderListView() }
