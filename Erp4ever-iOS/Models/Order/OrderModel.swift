//
//  OrderModel.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/28/25.
//

import Foundation

struct Orders: Identifiable {
    let id: String
    let deliveryDate: String
    let amount: Int
    let statusCode: String
}
