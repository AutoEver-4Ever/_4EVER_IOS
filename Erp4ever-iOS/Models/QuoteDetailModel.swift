//
//  QuoteDetailModal.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import Foundation

struct QuoteItemModel: Identifiable {
    let id = UUID()
    var productName: String
    var specification: String
    var quantity: Int
    var unitPrice: Int
    var amount: Int
}

enum QuoteStatus: String {
    case 검토중, 승인됨, 거절됨, 만료됨
}

struct QuoteDetailModel {
    var id: String
    var customerName: String
    var manager: String
    var email: String
    var quoteDate: String
    var validityPeriod: String
    var paymentTerms: String
    var deliveryTerms: String
    var warrantyPeriod: String
    var items: [QuoteItemModel]
    var remarks: String
    var status: String
    var totalAmount: Int
}
