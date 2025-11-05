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

func invoiceStatusLabel(from code: String) -> String {
    switch code.uppercased() {
    case "ISSUED": return "발행"
    case "PAID": return "완료"
    case "OVERDUE": return "연체"
    case "REQUESTED": return "요청"
    case "CONFIRMED": return "확정"
    case "PENDING": return "대기"
    case "PARTIAL": return "부분"
    case "APPROVAL": return "승인"
    case "REJECTED": return "반려"
    case "DELIVERING": return "배송중"
    case "DELIVERED": return "배송완료"
    case "CANCELED", "CANCELLED": return "취소"
    default: return "대기"
    }
}
