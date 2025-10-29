//
//  PurchaseModel.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/29/25.
//

import Foundation

struct Purchase: Identifiable {
    let id: String
    let content: String
    let supplier: String
    let amount: Int
    let issueDate: String
    let dueDate: String
    let status: Status
    let referenceNumber: String
    
    enum Status: String {
        case 미수, 완료
    }
}
