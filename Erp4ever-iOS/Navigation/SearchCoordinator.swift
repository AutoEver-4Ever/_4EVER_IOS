//
//  SearchCoordinator.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/10/25.
//

import SwiftUI
import Foundation
import Combine

/// 전역 검색 화면에서 사용하는 상태 코디네이터.
/// 탭에서 검색으로 전환될 때의 컨텍스트와 검색 결과 캐시를 보관한다.
final class SearchCoordinator: ObservableObject {
    // MARK: Scope
    enum Scope: Hashable, CaseIterable {
        case all
        case home
        case profile            // 프로필
        case purchaseOrder      // 발주서
        case quote              // 견적
        case accountReceivable  // 매출
        case accountPayable     // 매입

        var title: String {
            switch self {
            case .all: return "전체"
            case .home: return "홈"
            case .profile: return "프로필"
            case .purchaseOrder: return "발주서"
            case .quote: return "견적서"
            case .accountReceivable: return "매출"
            case .accountPayable: return "매입"
            }
        }
    }

    enum PurchaseOrderSearchType: String, CaseIterable, Hashable {
        case supplierCompanyName = "SupplierCompanyName"
        case purchaseOrderNumber = "PurchaseOrderNumber"

        var title: String {
            switch self {
            case .supplierCompanyName: return "공급사명"
            case .purchaseOrderNumber: return "발주번호"
            }
        }
    }

    enum QuoteSearchType: String, CaseIterable {
        case quotationNumber = "quotationNumber"
        case customerName = "customerName"
        case managerName = "managerName"

        var title: String {
            switch self {
            case .quotationNumber: return "견적번호"
            case .customerName: return "고객사명"
            case .managerName: return "담당자"
            }
        }
    }

    enum SalesInvoiceDateFilter: Hashable, CaseIterable {
        case all
        case last30Days

        var title: String {
            switch self {
            case .all: return "전체"
            case .last30Days: return "최근 30일"
            }
        }
    }

    // MARK: Published state
    @Published var query: String = ""
    @Published var isSearching: Bool = false
    @Published var scope: Scope = .all
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var purchaseOrderSearchType: PurchaseOrderSearchType = .supplierCompanyName
    @Published var quoteSearchType: QuoteSearchType = .quotationNumber
    @Published var salesInvoiceDateFilter: SalesInvoiceDateFilter = .all

    @Published var resultsPO: [PurchaseOrderListItem] = []
    @Published var resultsQuote: [QuotationListItem] = []
    @Published var resultsAR: [SalesInvoiceSummary] = []
    @Published var resultsAP: [PurchaseInvoiceListItem] = []

    @Published private(set) var lastOriginTab: MainAppView.MyTab?
    @Published private(set) var lastUpdatedAt: Date?

    private var searchTask: Task<Void, Never>?

    deinit { searchTask?.cancel() }

    // MARK: Intent

    /// 검색 화면을 열기 직전 사용자가 보고 있던 탭을 기반으로 기본 스코프를 결정한다.
    func preselectScope(from tab: MainAppView.MyTab) {
        guard tab != .search else {
            // 검색 탭에서 다시 호출된 경우 이전 맵핑을 유지
            return
        }
        lastOriginTab = tab
        scope = scope(for: tab)
    }

    /// 새 검색어를 적용하고 로딩 상태를 초기화한다.
    func updateQuery(_ text: String) {
        guard query != text else { return }
        query = text
        resetResults()
    }

    /// 검색 결과를 한 번에 초기화할 때 사용.
    func resetResults() {
        resultsPO = []
        resultsQuote = []
        resultsAR = []
        resultsAP = []
        lastUpdatedAt = nil
        errorMessage = nil
        isLoading = false
    }

    /// 검색 호출이 성공적으로 끝났을 때 갱신 시간 기록.
    func markUpdated() {
        lastUpdatedAt = Date()
        isLoading = false
    }

    func beginLoading() {
        isLoading = true
    }

    /// - 사용자가 입력한 검색어로 현재 스코프를 검색
    func performSearch() {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            searchTask?.cancel()
            resetResults()
            return
        }

        beginLoading()
        errorMessage = nil

        let targetScope = scope
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            await self?.search(scope: targetScope, keyword: keyword)
        }
    }

    // MARK: Helpers

    private func scope(for tab: MainAppView.MyTab) -> Scope {
        switch tab {
        case .home: return .home
        case .quote: return .quote
        case .purchaseOrder: return .purchaseOrder
        case .purchaseInvoice: return .accountPayable
        case .supplierInvoice: return .accountReceivable
        case .profile: return .profile
        case .search: return .all
        }
    }

    private func search(scope: Scope, keyword: String) async {
        switch scope {
        case .purchaseOrder:
            await searchPurchaseOrders(keyword: keyword)
        case .quote:
            await searchQuotes(keyword: keyword)
        case .accountReceivable:
            await searchSalesInvoices(keyword: keyword)
        default:
            await MainActor.run {
                self.errorMessage = "아직 \(scope.title) 검색은 준비 중입니다."
                self.isLoading = false
            }
        }
    }

    private func searchPurchaseOrders(keyword: String) async {
        guard let token = TokenStore.shared.loadAccessToken() else {
            await MainActor.run {
                self.errorMessage = "인증 토큰이 없습니다. 다시 로그인해주세요."
                self.isLoading = false
            }
            return
        }

        var query = PurchaseOrderQuery()
        query.keyword = keyword
        query.type = purchaseOrderSearchType.rawValue
        query.page = 0
        query.size = 20

        do {
            let page = try await PurchaseOrderService.shared.fetchList(accessToken: token, query: query)
            await MainActor.run {
                self.resultsPO = page.content
                self.errorMessage = nil
                self.markUpdated()
            }
        } catch PurchaseOrderServiceError.unauthorized {
            await MainActor.run {
                self.errorMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
                self.isLoading = false
            }
        } catch let PurchaseOrderServiceError.http(status, _) {
            await MainActor.run {
                self.errorMessage = "발주서 검색 실패 (\(status))"
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "발주서 검색 중 알 수 없는 오류가 발생했습니다."
                self.isLoading = false
            }
        }
    }

    private func searchQuotes(keyword: String) async {
        guard let token = TokenStore.shared.loadAccessToken() else {
            await MainActor.run {
                self.errorMessage = "인증 토큰이 없습니다. 다시 로그인해주세요."
                self.isLoading = false
            }
            return
        }

        var query = QuoteListQuery(
            startDate: nil,
            endDate: nil,
            status: nil,
            type: quoteSearchType.rawValue,
            search: keyword,
            sort: nil,
            page: 0,
            size: 20
        )

        do {
            let page = try await QuoteService.shared.fetchQuotationList(accessToken: token, query: query)
            await MainActor.run {
                self.resultsQuote = page.content
                self.errorMessage = nil
                self.markUpdated()
            }
        } catch QuoteServiceError.unauthorized {
            await MainActor.run {
                self.errorMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
                self.isLoading = false
            }
        } catch let QuoteServiceError.http(status, _) {
            await MainActor.run {
                self.errorMessage = "견적 검색 실패 (\(status))"
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "견적 검색 중 알 수 없는 오류가 발생했습니다."
                self.isLoading = false
            }
        }
    }

    private func searchSalesInvoices(keyword: String) async {
        guard let token = TokenStore.shared.loadAccessToken() else {
            await MainActor.run {
                self.errorMessage = "인증 토큰이 없습니다. 다시 로그인해주세요."
                self.isLoading = false
            }
            return
        }

        var query = SupplierInvoiceQuery()
        query.company = keyword
        applySalesInvoiceDateFilter(to: &query)
        query.page = 0
        query.size = 20

        do {
            let page = try await SupplierInvoiceService.shared.fetchList(accessToken: token, query: query)
            await MainActor.run {
                self.resultsAR = page.content.map { summary in
                    SalesInvoiceSummary(
                        invoiceId: summary.invoiceId,
                        invoiceNumber: summary.invoiceNumber,
                        supply: SalesInvoiceSupply(
                            supplierId: "",
                            supplierNumber: nil,
                            supplierName: summary.customerName
                        ),
                        totalAmount: summary.totalAmount,
                        issueDate: summary.issueDate,
                        dueDate: summary.dueDate,
                        statusCode: summary.statusCode,
                        referenceNumber: summary.referenceNumber,
                        reference: nil
                    )
                }
                self.errorMessage = nil
                self.markUpdated()
            }
        } catch SupplierInvoiceServiceError.unauthorized {
            await MainActor.run {
                self.errorMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
                self.isLoading = false
            }
        } catch let SupplierInvoiceServiceError.http(status, _) {
            await MainActor.run {
                self.errorMessage = "매출 전표 검색 실패 (\(status))"
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "매출 전표 검색 중 알 수 없는 오류가 발생했습니다."
                self.isLoading = false
            }
        }
    }

    private func applySalesInvoiceDateFilter(to query: inout SupplierInvoiceQuery) {
        switch salesInvoiceDateFilter {
        case .all:
            query.startDate = nil
            query.endDate = nil
        case .last30Days:
            let formatter = SearchCoordinator.dateFormatter
            let end = Date()
            if let start = Calendar.current.date(byAdding: .day, value: -30, to: end) {
                query.startDate = formatter.string(from: start)
            }
            query.endDate = formatter.string(from: end)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
