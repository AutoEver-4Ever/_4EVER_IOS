//
//  PurchaseInvoiceListView.swift
//  Erp4ever-iOS
//
//  AR invoice list shown as Purchase in UI.
//

import SwiftUI

struct PurchaseInvoiceListView: View {
    @StateObject private var vm = PurchaseInvoiceListViewModel()
    @State private var company: String = ""
    @State private var isSearchMode: Bool = false
    @State private var showDateSheet: Bool = false
    @State private var startDate: Date? = nil
    @State private var endDate: Date? = nil

    private func formatKRW(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let f = NumberFormatter(); f.numberStyle = .decimal
        return "\(f.string(from: number) ?? "0")원"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                InvoiceHeaderBar(isSearchMode: $isSearchMode, searchText: $company) { text in
                    vm.applyCompany(text)
                }

                // 기간 필터 바
                HStack(spacing: 8) {
                    Button {
                        showDateSheet = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                            Text(dateRangeLabel())
                                .font(.caption)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    }
                    .buttonStyle(.plain)

                    if startDate != nil || endDate != nil {
                        Button("지우기") {
                            startDate = nil; endDate = nil
                            vm.applyDateRange(start: nil, end: nil)
                        }
                        .font(.caption)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                ScrollView {
                    if vm.isLoading && vm.items.isEmpty {
                        ProgressView().padding(.top, 40)
                    } else if let err = vm.error, vm.items.isEmpty {
                        ErrorStateCard(title: "전표 목록을 불러오지 못했습니다.", message: err) { vm.loadInitial() }
                            .padding(.horizontal)
                            .padding(.top, 40)
                    } else if vm.items.isEmpty {
                        EmptyStateCard(message: "목록이 비어 있습니다.")
                            .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(vm.items.enumerated()), id: \.offset) { idx, item in
                                NavigationLink(destination: PurchaseInvoiceDetailView(id: item.invoiceId)) {
                                    Card {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(item.invoiceNumber)
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.blue)
                                                Spacer()
                                                StatusLabel(statusCode: invoiceStatusLabel(from: item.statusCode))
                                            }
                                            Group {
                                                HStack { Text("거래처").foregroundColor(.secondary); Spacer(); Text(item.supply.supplierName) }
                                                HStack { Text("발행일").foregroundColor(.secondary); Spacer(); Text(item.issueDate) }
                                                HStack { Text("납기일").foregroundColor(.secondary); Spacer(); Text(item.dueDate) }
                                                HStack { Text("금액").foregroundColor(.secondary); Spacer(); Text(formatKRW(item.totalAmount)).foregroundColor(.blue).bold() }
                                            }
                                            .font(.footnote)
                                        }
                                    }
                                }
                                .onAppear { if idx == vm.items.count - 1 { vm.loadNextPage() } }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                        if vm.isLoading { ProgressView().padding(.bottom, 16) }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .sheet(isPresented: $showDateSheet) {
                    DateRangeSheet(
                        startDate: $startDate,
                        endDate: $endDate,
                        onApply: {
                            vm.applyDateRange(start: startDate.map(formatDate), end: endDate.map(formatDate))
                            showDateSheet = false
                        },
                        onCancel: { showDateSheet = false }
                    )
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onAppear { if vm.items.isEmpty { vm.loadInitial() } }
        }
    }

    private func formatDate(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = .init(identifier: "ko_KR")
        return f.string(from: d)
    }

    private func dateRangeLabel() -> String {
        switch (startDate, endDate) {
        case (nil, nil): return "전체 기간"
        case let (s?, nil): return "\(formatDate(s)) ~"
        case let (nil, e?): return "~ \(formatDate(e))"
        case let (s?, e?): return "\(formatDate(s)) ~ \(formatDate(e))"
        }
    }
}

#Preview { PurchaseInvoiceListView() }
