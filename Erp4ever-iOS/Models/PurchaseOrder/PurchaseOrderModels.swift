//
//  PurchaseOrderModels.swift
//  Erp4ever-iOS
//
//  공급사용 발주서(PO) 목록/상세 모델. 게이트웨이(SCM-MM) 응답을 디코딩.
//

import Foundation

// MARK: - 목록 아이템

struct PurchaseOrderListItem: Decodable, Identifiable {
    // 고유 ID는 발주서 ID 사용
    var id: String { purchaseOrderId }

    // 발주서 기본 정보
    let purchaseOrderId: String
    let purchaseOrderNumber: String
    let supplierCompanyName: String
    let totalAmount: Decimal
    let issueDate: String      // YYYY-MM-DD
    let dueDate: String        // YYYY-MM-DD
    let statusCode: String
}

// MARK: - 상세 품목

struct PurchaseOrderItem: Decodable, Identifiable {
    var id: String { itemId }

    let itemId: String
    let itemName: String
    let quantity: Int?
    let uomName: String?       // 단위명(서버에서 unitOfMaterialName 등으로 내려올 수 있어 Optional)
    let unitPrice: Decimal
    let totalPrice: Decimal
}

// MARK: - 상세

struct PurchaseOrderDetail: Decodable {
    let purchaseOrderId: String
    let purchaseOrderNumber: String
    let statusCode: String
    let issueDate: String
    let dueDate: String
    let supplierCompanyName: String
    let referenceNumber: String?
    let totalAmount: Decimal
    let note: String?
    let items: [PurchaseOrderItem]
}

// MARK: - 조회 파라미터

struct PurchaseOrderQuery {
    // 상태코드 (ALL, APPROVAL, PENDING, REJECTED, DELIVERING, DELIVERED)
    var statusCode: String = "ALL"
    // 검색 타입 (SupplierCompanyName, PurchaseOrderNumber)
    var type: String? = nil
    // 검색어
    var keyword: String? = nil
    // 기간(YYYY-MM-DD)
    var startDate: String? = nil
    var endDate: String? = nil
    // 페이징
    var page: Int = 0
    var size: Int = 20

    func asQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        items.append(URLQueryItem(name: "statusCode", value: statusCode))
        if let type, !type.isEmpty { items.append(URLQueryItem(name: "type", value: type)) }
        if let keyword, !keyword.isEmpty { items.append(URLQueryItem(name: "keyword", value: keyword)) }
        if let startDate { items.append(URLQueryItem(name: "startDate", value: startDate)) }
        if let endDate { items.append(URLQueryItem(name: "endDate", value: endDate)) }
        items.append(URLQueryItem(name: "page", value: String(max(0, page))))
        items.append(URLQueryItem(name: "size", value: String(max(1, size))))
        return items
    }
}

