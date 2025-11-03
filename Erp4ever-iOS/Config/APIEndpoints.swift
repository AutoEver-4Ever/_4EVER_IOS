//
//  APIEndpoints.swift
//  Erp4ever-iOS
//
//  Centralized API base URLs and paths per environment.
//

import Foundation

enum APIEndpoints {
    // Environment-specific bases
    private static var authBase: String {
        #if DEBUG
        return "http://localhost:8081"
        #else
        return "https://auth.everp.co.kr"
        #endif
    }

    private static var gwBase: String {
        #if DEBUG
        return "http://localhost:8080"
        #else
        return "https://api.everp.co.kr"
        #endif
    }

    enum Auth {
        static var base: String { APIEndpoints.authBase }
        static var authorizationEndpoint: String { base + "/oauth2/authorize" }
        static var tokenEndpoint: String { base + "/oauth2/token" }
        static var logout: String { base + "/logout" }
    }

    enum GW {
        static var base: String { APIEndpoints.gwBase }
        static var userInfo: String { base + "/api/user/info" }
    }
}

