//
//  QuoteListModel.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import Foundation

struct Quote: Identifiable {
    let id: String
    let customerName: String
    let manager: String
    let quoteDate: String
    let deliveryDate: String
    let amount: Int
    let status: String

}
