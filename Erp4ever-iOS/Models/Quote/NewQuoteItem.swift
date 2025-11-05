//
//  NewQuoteItem.swift
//  Erp4ever-iOS
//
//  Item model used by NewQuoteView for composing a new quotation.
//

import Foundation

struct NewQuoteItem: Identifiable {
    let id: String
    var productName: String
    var specification: String
    var quantity: Int
    var unitPrice: Int
    var amount: Int
}

