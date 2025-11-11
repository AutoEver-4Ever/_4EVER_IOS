//
//  SearchCoordinator.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/10/25.
//

import SwiftUI
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

    // MARK: Published state
    @Published var query: String = ""
    @Published var isSearching: Bool = false
    @Published var scope: Scope = .all
    @Published var isLoading: Bool = false

    @Published var resultsPO: [PurchaseOrderListItem] = []
    @Published var resultsQuote: [QuotationListItem] = []
    @Published var resultsAR: [SalesInvoiceSummary] = []
    @Published var resultsAP: [PurchaseInvoiceListItem] = []

    @Published private(set) var lastOriginTab: MainAppView.MyTab?
    @Published private(set) var lastUpdatedAt: Date?

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
    }

    /// 검색 호출이 성공적으로 끝났을 때 갱신 시간 기록.
    func markUpdated() {
        lastUpdatedAt = Date()
        isLoading = false
    }

    func beginLoading() {
        isLoading = true
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
}
