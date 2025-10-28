//
//  OrderDetailModel.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/28/25.
//

import Foundation

struct OrderDetailItemModel: Identifiable {
    let id = UUID()
    var productName: String
    var specification: String
    var quantity: Int
    var unitPrice: Int
    var amount: Int
}

struct OrderDetailModel {
    var id: String
    var customerName: String
    var manager: String
    var email: String
    var orderDate: String
    var deliveryDate: String
    var amount: Int
    var statusCode: String
    var items: [OrderDetailItemModel]
    var deliveryAddress: String
    var trackingNumber: String?
}
