//
//  QuoteListQuery.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/5/25.
//

import Foundation
// 견적 목록 조회 파라미터

struct QuoteListQuery {
    var startDate: String?      // YYYY-MM-DD
    var endDate: String?        // YYYY-MM-DD
    var status: String?         // PENDING | REVIEW | APPROVAL | REJECTED | ALL
    var type: String?           // quotationNumber | customerName | managerName
    var search: String?
    var sort: String?           // asc | desc
    var page: Int = 0
    var size: Int = 20
    
    
    func asQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let startDate { items.append(URLQueryItem(name: "startDate", value: startDate)) }
        if let endDate { items.append(URLQueryItem(name: "endDate", value: endDate)) }
        if let status, !status.isEmpty { items.append(URLQueryItem(name: "status", value: status))}
        if let type { items.append(URLQueryItem(name: "type", value: type)) }
        if let search { items.append(URLQueryItem(name: "search", value: search)) }
        if let sort { items.append(URLQueryItem(name: "sort", value: sort)) }
        items.append(URLQueryItem(name: "page", value: "\(page)"))
        items.append(URLQueryItem(name: "size", value: "\(size)"))
        return items
    }
}
