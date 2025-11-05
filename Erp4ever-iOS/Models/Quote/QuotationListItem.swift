//
//  QuotationListItem.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/5/25.
//

import Foundation

// 견적서 목록 아이템 (BE QuotationListItemDto 매핑)
struct QuotationListItem: Decodable {
    let quotationId: String
    let quotationNumber: String
    let customerName: String
    let productId: String?
    let dueDate: String
    let quantity: Int?
    let uomName: String?
    let statusCode: String
}
