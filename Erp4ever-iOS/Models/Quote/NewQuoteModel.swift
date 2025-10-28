//
//  NewQuoteModel.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
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
