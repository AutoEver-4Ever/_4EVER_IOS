//
//  APIEndpoints.swift
//  Erp4ever-iOS
//
//

import Foundation

enum APIEndpoints {
    private static var authBase: String {
        return "https://auth.everp.co.kr"
    }

    private static var gwBase: String {
        return "https://api.everp.co.kr"
    }

    enum Auth {
        static var base: String { APIEndpoints.authBase }
        static var authorizationEndpoint: String { base + "/oauth2/authorize" }
        static var tokenEndpoint: String { base + "/oauth2/token" }
        static var logout: String { base + "/logout" }
    }

    enum Gateway {
        static var base: String { APIEndpoints.gwBase }
        // 사용자 정보 조회
        static var userInfo: String { base + "/api/user/info" }
        
        // 매출 전표
        // 목록 조회
        static var accountReceivable: String { base + "/api/business/fcm/invoice/ar" }
        
        // 상세 조회
        static var accountReceivableDetail: String { base + "/api/business/fcm/invoice/ar/{invoiceId}" }
        
        // 미수 처리 완료
        static var accountReceivableComplete: String { base + "/api/business/fcm/invoice/ar/{invoiceId}/receivable/complete"}
        
        // 매입 전표
        // 목록 조회
        static var accountPayable: String { base + "/api/business/fcm/invoice/ap" }
        // 상세 조회
        static var accountPayableDetail: String { base + "/api/business/fcm/invoice/ap/{invoiceId}" }
        
        // 미수 처리 요청
        static var accountPayableRequest: String { base + "/api/business/fcm/invoice/ap/{invoiceId}/receivable/request"}
    }
}
