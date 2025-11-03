//
//  SalesInvoiceListModels.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/3/25.
//

import Foundation

// 매출 목록 조회 응답
struct SalesInvoiceListResponse: Decodable {
    let content: [SalesInvoiceSummary]
    let page: SalesInvoicePageInfo
}

// 목룍용 전표 요약 한 건
struct SalesInvoiceSummary: Decodable, Identifiable {
    let invoiceId: String
    let invoiceNumber: String
    let supply: SalesInvoiceSupply
    let totalAmount: Decimal
    let issueDate: String?
    let dueDate: String?
    let statusCode: String
    let referenceNumber: String?
    let reference: SalesInvoiceReference?
    
    var id: String { invoiceId }
}

// 공급사 요약 정보
struct SalesInvoiceSupply: Decodable {
    let supplierId: String
    let supplierNumber: String?
    let supplierName: String?
}

// 참조 원천(주문/견적 등)
struct SalesInvoiceReference: Decodable {
    let referenceId: String
    let referenceNumber: String?
}

// 페이지네이션
struct SalesInvoicePageInfo: Decodable {
    let number: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasNext: Bool
}
