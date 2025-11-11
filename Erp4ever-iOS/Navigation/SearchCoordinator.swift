//
//  SearchCoordinator.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/10/25.
//

import SwiftUI

// 전역 검색 화면을 관리하는 코디네이터
// 검색 쿼리, 스코프, 로딩 상태, 결과 등을 보유함.

final class SearchCoordinator: ObservableObject {
    
    // MARK: 화면 단위
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
    
    // @Published: 값이 바뀌면 view가 리렌더링 됨.
    @Published var query: String = ""
    @Published var isSearching: Bool = false
    @Published var scope: Scope = .all
    
    @Published var resultsPO: [PurchaseOrder] = [PurchaseOrderListItem]
    @Published var resultsQuote: [Quote] = []
    @Published var resultsAR: [SalesInvoice] = []
    
    // 탭 문맥 연결
    func preselectScope(from tab: Main)
    
    
    
}
