//
//  SupplierInvoiceModels.swift
//  Erp4ever-iOS
//
//  공급사용 매출 전표(AR) 모델.
//  - 목록: supply.supplierName -> customerName 으로 평탄화
//  - 상세: name -> customerName, unitOfMaterialName -> uomName 매핑
//

import Foundation

// MARK: - 목록 모델

struct SupplierInvoiceListItem: Decodable, Identifiable {
    var id: String { invoiceId }

    let invoiceId: String
    let invoiceNumber: String
    let customerName: String // supply.supplierName 에서 매핑
    let totalAmount: Decimal
    let issueDate: String
    let dueDate: String
    let statusCode: String
    let referenceNumber: String?

    private enum CodingKeys: String, CodingKey {
        case invoiceId, invoiceNumber, totalAmount, issueDate, dueDate, statusCode, referenceNumber
        case supply
    }

    private struct Supply: Decodable { let supplierName: String? }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.invoiceId = try c.decode(String.self, forKey: .invoiceId)
        self.invoiceNumber = try c.decode(String.self, forKey: .invoiceNumber)
        self.totalAmount = try c.decode(Decimal.self, forKey: .totalAmount)
        self.issueDate = try c.decode(String.self, forKey: .issueDate)
        self.dueDate = try c.decode(String.self, forKey: .dueDate)
        self.statusCode = try c.decode(String.self, forKey: .statusCode)
        self.referenceNumber = try c.decodeIfPresent(String.self, forKey: .referenceNumber)

        let supply = try c.decodeIfPresent(Supply.self, forKey: .supply)
        self.customerName = supply?.supplierName ?? ""
    }
}

// MARK: - 상세 모델

struct SupplierInvoiceDetailItem: Decodable, Identifiable {
    var id: String { itemId }

    let itemId: String
    let itemName: String
    let quantity: Int
    let uomName: String // unitOfMaterialName 에서 매핑
    let unitPrice: Decimal
    let totalPrice: Decimal

    private enum CodingKeys: String, CodingKey {
        case itemId, itemName, quantity, unitPrice, totalPrice
        case unitOfMaterialName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.itemId = try c.decode(String.self, forKey: .itemId)
        self.itemName = try c.decode(String.self, forKey: .itemName)
        self.quantity = try c.decode(Int.self, forKey: .quantity)
        self.uomName = try c.decodeIfPresent(String.self, forKey: .unitOfMaterialName) ?? ""
        self.unitPrice = try c.decode(Decimal.self, forKey: .unitPrice)
        self.totalPrice = try c.decode(Decimal.self, forKey: .totalPrice)
    }

    // 미리보기 및 수동 생성을 위한 이니셜라이저
    init(itemId: String, itemName: String, quantity: Int, uomName: String, unitPrice: Decimal, totalPrice: Decimal) {
        self.itemId = itemId
        self.itemName = itemName
        self.quantity = quantity
        self.uomName = uomName
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
    }
}

struct SupplierInvoiceDetail: Decodable {
    let invoiceId: String
    let invoiceNumber: String
    let invoiceType: String
    let statusCode: String
    let issueDate: String
    let dueDate: String
    let customerName: String // from name
    let referenceNumber: String?
    let totalAmount: Decimal
    let note: String?
    let items: [SupplierInvoiceDetailItem]

    private enum CodingKeys: String, CodingKey {
        case invoiceId, invoiceNumber, invoiceType, statusCode, issueDate, dueDate, referenceNumber, totalAmount, note, items
        case name
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.invoiceId = try c.decode(String.self, forKey: .invoiceId)
        self.invoiceNumber = try c.decode(String.self, forKey: .invoiceNumber)
        self.invoiceType = try c.decode(String.self, forKey: .invoiceType)
        self.statusCode = try c.decode(String.self, forKey: .statusCode)
        self.issueDate = try c.decode(String.self, forKey: .issueDate)
        self.dueDate = try c.decode(String.self, forKey: .dueDate)
        self.customerName = try c.decode(String.self, forKey: .name)
        self.referenceNumber = try c.decodeIfPresent(String.self, forKey: .referenceNumber)
        self.totalAmount = try c.decode(Decimal.self, forKey: .totalAmount)
        self.note = try c.decodeIfPresent(String.self, forKey: .note)
        self.items = try c.decode([SupplierInvoiceDetailItem].self, forKey: .items)
    }

    // 미리보기 및 수동 생성을 위한 이니셜라이저
    init(
        invoiceId: String,
        invoiceNumber: String,
        invoiceType: String,
        statusCode: String,
        issueDate: String,
        dueDate: String,
        customerName: String,
        referenceNumber: String?,
        totalAmount: Decimal,
        note: String?,
        items: [SupplierInvoiceDetailItem]
    ) {
        self.invoiceId = invoiceId
        self.invoiceNumber = invoiceNumber
        self.invoiceType = invoiceType
        self.statusCode = statusCode
        self.issueDate = issueDate
        self.dueDate = dueDate
        self.customerName = customerName
        self.referenceNumber = referenceNumber
        self.totalAmount = totalAmount
        self.note = note
        self.items = items
    }
}

// MARK: - 조회 쿼리

struct SupplierInvoiceQuery {
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
