//
//  SalesInvoiceDetailModels.swift
//  Erp4ever-iOS
//
//  Created by 김대환 on 11/3/25.
//

import Foundation

// 매출 전표 한 건
struct SalesInvoiceDetail: Decodable {
    let invoiceId: String
    let invoiceNumber: String?
    let invoiceType: String?
    let statusCode: String
    let issueDate: String?
    let dueDate: String?
    let name: String?
    let referenceNumber: String?
    let totalAmount: Decimal
    let note: String?
    let items: [SalesInvoiceLineItem]
}

// 품목
struct SalesInvoiceLineItem: Decodable {
    let itemId: String
    let itemName: String?
    let quantity: Int?
    let unitOfMaterialName: String?
    let unitPrice: Decimal
    let totalPrice: Decimal
}
