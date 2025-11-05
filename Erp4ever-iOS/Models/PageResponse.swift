//
//  PageResponse.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/5/25.
//

import Foundation

struct PageResponse<T: Decodable>: Decodable {
    let total: Int
    let content: [T]
    let pageInfo: PageInfo
}
