//
//  PurchaseInvoiceModels.swift
//  Erp4ever-iOS
//
//  Models for AR invoice APIs (shown as Purchase/AP in UI).
//

import Foundation

// MARK: - List

struct ARSupply: Decodable {
    let supplierId: String
    let supplierNumber: String
    let supplierName: String
}

struct PurchaseInvoiceListItem: Decodable, Identifiable {
    var id: String { invoiceId }

    let invoiceId: String
    let invoiceNumber: String
    let supply: ARSupply
    let totalAmount: Decimal
    let issueDate: String
    let dueDate: String
    let statusCode: String
    let referenceNumber: String?
}

// MARK: - Detail

struct PurchaseInvoiceDetailItem: Decodable, Identifiable {
    var id: String { itemId }

    let itemId: String
    let itemName: String
    let quantity: Int?
    let unitOfMaterialName: String?
    let unitPrice: Decimal
    let totalPrice: Decimal

    var uomName: String { unitOfMaterialName ?? "" }
}

struct PurchaseInvoiceDetail: Decodable {
    let invoiceId: String
    let invoiceNumber: String
    let invoiceType: String
    let statusCode: String
    let issueDate: String
    let dueDate: String
    let name: String
    let referenceNumber: String?
    let totalAmount: Decimal
    let note: String?
    let items: [PurchaseInvoiceDetailItem]
}

// MARK: - Query

struct PurchaseInvoiceQuery {
    var company: String?
    var startDate: String?
    var endDate: String?
    var page: Int = 0
    var size: Int = 20

    func asQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let company, !company.isEmpty { items.append(URLQueryItem(name: "company", value: company)) }
        if let startDate { items.append(URLQueryItem(name: "startDate", value: startDate)) }
        if let endDate { items.append(URLQueryItem(name: "endDate", value: endDate)) }
        items.append(URLQueryItem(name: "page", value: String(max(0, page))))
        items.append(URLQueryItem(name: "size", value: String(max(1, size))))
        return items
    }
}

