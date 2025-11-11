//
//  PageInfo.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/5/25.
//

import Foundation

// 페이지 정보
struct PageInfo: Decodable {
    let number: Int
    let size: Int
    let totalElements: Int
    let totalPages: Int
    let hasNext: Bool
}
