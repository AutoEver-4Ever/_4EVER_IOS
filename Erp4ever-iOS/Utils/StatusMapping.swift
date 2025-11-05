//
//  StatusMapping.swift
//  Erp4ever-iOS
//
//  Utility to map BE status codes to display labels.
//

import Foundation

func quoteStatusLabel(from code: String) -> String {
    switch code.uppercased() {
    case "REVIEW": return "검토중"
    case "APPROVAL": return "승인됨"
    case "REJECTED": return "거절됨"
    case "PENDING": return "대기"
    default: return "대기"
    }
}

