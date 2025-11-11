//
//  SearchView.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/6/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var coordinator: SearchCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                scopeSelector
                if effectiveScope == .purchaseOrder {
                    purchaseOrderFilter
                } else if effectiveScope == .accountReceivable {
                    salesInvoiceFilter
                }
                if trimmedQuery.isEmpty {
                    suggestionSection
                } else {
                    resultSection
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("검색")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard let first = allowedScopes.first, !allowedScopes.contains(coordinator.scope) else { return }
            coordinator.scope = first
        }
        .onSubmit(of: .search) {
            coordinator.performSearch()
        }
        .onChange(of: coordinator.scope) { _ in
            guard !trimmedQuery.isEmpty else { return }
            coordinator.performSearch()
        }
        .onChange(of: coordinator.purchaseOrderSearchType) { _ in
            guard effectiveScope == .purchaseOrder, !trimmedQuery.isEmpty else { return }
            coordinator.performSearch()
        }
        .onChange(of: coordinator.salesInvoiceDateFilter) { _ in
            guard effectiveScope == .accountReceivable, !trimmedQuery.isEmpty else { return }
            coordinator.performSearch()
        }
    }

    // MARK: - Scope Selector

    private var scopeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("검색 범위")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(allowedScopes, id: \.self) { scope in
                    Button {
                        coordinator.scope = scope
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(scope.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(scopeSubtitle(scope))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 14)
                        .background(scopeButtonBackground(scope))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(scopeBorderColor(scope), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var purchaseOrderFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("발주서 검색 기준")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("발주서 검색 기준", selection: purchaseOrderTypeBinding) {
                ForEach(SearchCoordinator.PurchaseOrderSearchType.allCases, id: \.self) { type in
                    Text(type.title).tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var purchaseOrderTypeBinding: Binding<SearchCoordinator.PurchaseOrderSearchType> {
        Binding(
            get: { coordinator.purchaseOrderSearchType },
            set: { coordinator.purchaseOrderSearchType = $0 }
        )
    }

    private var salesInvoiceFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("매출 전표 기간")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("매출 전표 기간", selection: salesInvoiceFilterBinding) {
                ForEach(SearchCoordinator.SalesInvoiceDateFilter.allCases, id: \.self) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var salesInvoiceFilterBinding: Binding<SearchCoordinator.SalesInvoiceDateFilter> {
        Binding(
            get: { coordinator.salesInvoiceDateFilter },
            set: { coordinator.salesInvoiceDateFilter = $0 }
        )
    }

    // MARK: - Suggestion Section (query 없음)

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(effectiveScope.title) 검색을 시작해보세요")
                .font(.headline)
            Text("검색어를 입력하면 \(effectiveScope.title) 결과를 바로 보여드립니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Divider()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Result Section (query 존재)

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            resultHeader
            Group {
                if let error = coordinator.errorMessage {
                    errorCard(error)
                } else if coordinator.isLoading {
                    ProgressView("검색 중입니다...")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if currentResultCount == 0 {
                    Text("검색 결과가 없습니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    resultList(for: effectiveScope)
                }
            }
            .animation(.easeInOut, value: coordinator.isLoading)
        }
    }

    // MARK: - Result Header

    private var resultHeader: some View {
        HStack {
            Text("\(effectiveScope.title) 검색 결과")
                .font(.headline)
            Spacer()
            if let updated = coordinator.lastUpdatedAt {
                Text(updated, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    // - 현재 검색어를 미리 잘라 여러 곳에서 재사용
    private var trimmedQuery: String {
        coordinator.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // - 사용자 타입 문자를 정규화해 이후 분기에서 재사용
    private var normalizedUserType: String {
        (session.currentUser?.userType ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    // - 고객/공급사 조건에 맞춰 노출할 스코프를 한정
    private var allowedScopes: [SearchCoordinator.Scope] {
        switch normalizedUserType {
        case "CUSTOMER": return [.quote, .accountPayable]
        case "SUPPLIER": return [.purchaseOrder, .accountReceivable]
        default: return [.all]
        }
    }

    private var effectiveScope: SearchCoordinator.Scope {
        if allowedScopes.contains(coordinator.scope) {
            return coordinator.scope
        }
        return allowedScopes.first ?? .all
    }

    // - 현재 선택된 스코프에 따라 결과 개수를 계산
    private var currentResultCount: Int {
        switch effectiveScope {
        case .purchaseOrder: return coordinator.resultsPO.count
        case .quote: return coordinator.resultsQuote.count
        case .accountReceivable: return coordinator.resultsAR.count
        case .accountPayable: return coordinator.resultsAP.count
        default: return 0
        }
    }

    private func scopeSubtitle(_ scope: SearchCoordinator.Scope) -> String {
        switch scope {
        case .purchaseOrder: return "발주서 검색"
        case .accountReceivable: return "매출 전표 검색"
        case .quote: return "견적서 검색"
        case .accountPayable: return "매입 전표 검색"
        case .home, .profile, .all: return "전체 통합 검색"
        }
    }

    private func scopeButtonBackground(_ scope: SearchCoordinator.Scope) -> some View {
        let isSelected = effectiveScope == scope
        return RoundedRectangle(cornerRadius: 12)
            .fill(isSelected ? Color.blue.opacity(0.12) : Color(.systemBackground))
    }

    private func scopeBorderColor(_ scope: SearchCoordinator.Scope) -> Color {
        effectiveScope == scope ? .blue : Color.gray.opacity(0.2)
    }

    // - 에러가 발생했을 때 보여줄 공통 카드
    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("검색에 실패했습니다.")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button {
                coordinator.performSearch()
            } label: {
                Text("다시 시도")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Result Lists

    @ViewBuilder
    // - 스코프별 결과 리스트
    private func resultList(for scope: SearchCoordinator.Scope) -> some View {
        switch scope {
        case .purchaseOrder:
            LazyVStack(spacing: 12) {
                ForEach(coordinator.resultsPO, id: \.purchaseOrderId) { item in
                    NavigationLink(destination: PurchaseOrderDetailView(id: item.purchaseOrderId)) {
                        PurchaseOrderResultRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        case .quote:
            LazyVStack(spacing: 12) {
                ForEach(coordinator.resultsQuote, id: \.quotationId) { item in
                    NavigationLink(destination: QuoteDetailView(id: item.quotationId)) {
                        QuoteResultRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        case .accountReceivable:
            LazyVStack(spacing: 12) {
                ForEach(coordinator.resultsAR) { item in
                    NavigationLink(destination: SupplierInvoiceDetailView(id: item.invoiceId)) {
                        SalesInvoiceResultRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        case .accountPayable:
            LazyVStack(spacing: 12) {
                ForEach(coordinator.resultsAP) { item in
                    NavigationLink(destination: PurchaseInvoiceDetailView(id: item.invoiceId)) {
                        PurchaseInvoiceResultRow(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        default:
            Text("선택된 영역이 없습니다.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Result Rows

private struct PurchaseOrderResultRow: View {
    let item: PurchaseOrderListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.purchaseOrderNumber)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(item.statusCode)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            Text(item.supplierName ?? "-")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(item.orderDate.prefix(10))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

private struct QuoteResultRow: View {
    let item: QuotationListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.quotationNumber)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(item.statusCode)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            Text(item.customerName)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(item.dueDate)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

private struct SalesInvoiceResultRow: View {
    let item: SalesInvoiceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.invoiceNumber)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(item.statusCode)
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            Text(item.supply.supplierName ?? "-")
                .font(.footnote)
                .foregroundStyle(.secondary)
            if let issue = item.issueDate {
                Text(issue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

private struct PurchaseInvoiceResultRow: View {
    let item: PurchaseInvoiceListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.invoiceNumber)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(item.statusCode)
                    .font(.caption)
                    .foregroundStyle(.purple)
            }
            Text(item.supply.supplierName)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(item.issueDate)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchView()
                .environmentObject(SessionManager())
                .environmentObject(SearchCoordinator())
        }
    }
}
