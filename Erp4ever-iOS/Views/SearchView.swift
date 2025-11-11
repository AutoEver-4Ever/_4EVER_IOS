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

    // MARK: - Suggestion Section (query 없음)

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(suggestionTitle(effectiveScope))
                .font(.headline)
            Text(suggestionDescription(effectiveScope))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            suggestionTiles(for: effectiveScope)
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

    // MARK: - Suggestions

    @ViewBuilder
    // - 스코프별 추천 타일을 노출해 검색을 유도
    private func suggestionTiles(for scope: SearchCoordinator.Scope) -> some View {
        switch scope {
        case .purchaseOrder:
            suggestionCard(
                title: "최근 발주서",
                description: "자주 확인한 발주서를 모아 보여드립니다.",
                icon: "doc.text"
            )
        case .accountReceivable:
            suggestionCard(
                title: "매출 전표 요약",
                description: "최근 발행된 매출 전표 상태를 빠르게 확인하세요.",
                icon: "list.bullet"
            )
        case .quote:
            suggestionCard(
                title: "견적서 즐겨찾기",
                description: "고객사와 주고받은 최신 견적서를 찾아보세요.",
                icon: "magnifyingglass.circle"
            )
        case .accountPayable:
            suggestionCard(
                title: "매입 전표 일정",
                description: "다가오는 납기일 기준으로 매입 전표를 정리합니다.",
                icon: "calendar"
            )
        default:
            suggestionCard(
                title: "통합 검색",
                description: "원하는 영역을 선택한 뒤 검색을 시작하세요.",
                icon: "magnifyingglass"
            )
        }
    }

    // - 추천 블록 타이틀 복수화를 피하기 위해 별도 함수로 분리
    private func suggestionTitle(_ scope: SearchCoordinator.Scope) -> String {
        switch scope {
        case .purchaseOrder: return "발주서에서 찾고 계신가요?"
        case .accountReceivable: return "매출 전표 조회"
        case .quote: return "견적서를 바로 검색하세요"
        case .accountPayable: return "매입 전표 내역"
        default: return "검색할 영역을 선택하세요"
        }
    }

    // - 추천 블록 설명 문구
    private func suggestionDescription(_ scope: SearchCoordinator.Scope) -> String {
        switch scope {
        case .purchaseOrder: return "최근 승인 상태, 공급사명, 발주 번호로 즉시 찾아보세요."
        case .accountReceivable: return "발행일, 고객사, 금액 기준으로 매출 전표를 필터링합니다."
        case .quote: return "견적 번호나 고객 사명으로 검색하면 곧바로 상세로 이동할 수 있습니다."
        case .accountPayable: return "발행일자·납기일에 맞춰 매입 전표를 정리했습니다."
        default: return "원하는 업무 영역을 선택하면 맞춤 추천과 검색이 열립니다."
        }
    }

    // - 단일 카드 컴포넌트로 재사용
    private func suggestionCard(title: String, description: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .renderingMode(.template)
                .foregroundStyle(.blue)
                .font(.title3)
                .frame(width: 20, height: 20)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
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
