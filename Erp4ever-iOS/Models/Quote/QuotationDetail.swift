//
//  QuotationDetail.swift
//  Erp4ever-iOS
//
//  견적서 상세보기
//

import Foundation

struct QuotationDetailItem: Decodable, Identifiable {
    var id: String { itemId }
    let itemId: String
    let itemName: String
    let quantity: Int?
    let uomName: String?
    let unitPrice: Decimal?
    let amount: Decimal?
}

struct QuotationDetail: Decodable {
    let quotationId: String
    let quotationNumber: String
    let quotationDate: String
    let dueDate: String
    let statusCode: String
    let customerName: String
    let ceoName: String?
    let items: [QuotationDetailItem]
    let totalAmount: Decimal
}

