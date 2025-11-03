//
//  AuthConfig.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import Foundation
import os

@available(iOS 14.0, *)
private let authLog = Logger(
    subsystem: "org.everp.ios",
    category: "AuthConfig"
)

// 인증 객체만 담고 있는 불변 값 객체임.
struct AuthConfig {
    // 엔드포인트/ 클라이언트/ 리다이렉트/ 스코프
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let clientID: String
    let redirectUri: String
    let scopes: [String]
    
    // WKWebView 리다이렉트 인터셉트를 위한 컴포넌트
    // 리다이렉트 Uri 문자열을 URL 객체로 변환함.
    var redirectURL: URL {
        guard let url = URL(string: redirectUri) else {
            if #available(iOS 14.0, *) {
                authLog.error("[ERROR] 검증되지 않은 Redirect URI: \(self.redirectUri, privacy: .public)")
            }
            preconditionFailure("검증되지 않은 URI 형식입니다.")
        }
        return url
    }
    // 리다이렉트 url의 스킴(ex: everp)를 추출함. 없으면 빈 문자열을 반환
    var redirectScheme: String { redirectURL.scheme ?? "" }
    // 리다이렉트 URL의 호스트와 경로를 반환함.
    var redirectHost: String? { redirectURL.host }
    var redirectPath: String { redirectURL.path }
    
    // 인가 요청 URL 생성
    func makeAuthorizationRequestURL(
        codeChallenge: String,
        state: String
    ) -> URL? {
        
        // authorization endpoint 문자열로 URLCompoenets를 생성함.
        var comps = URLComponents(string: authorizationEndpoint)
        
        if comps == nil {
            authLog.error("검증되지 않은 Authorization 엔드포인트: \(authorizationEndpoint)")
            return nil
        }
        
        let items: [URLQueryItem] = [
            .init(name: "response_type", value: "code"),
            .init(name: "client_id", value: clientID),
            .init(name: "redirect_uri", value: redirectUri),
            .init(name: "scope", value: scopes.joined(separator: " ")),
            .init(name: "code_challenge", value: codeChallenge),
            .init(name: "state", value: state),
            .init(name: "code_challenge_method", value: "S256")
        ]
        comps?.queryItems = items
        
        guard let url = comps?.url else {
            authLog.error("[ERROR] Authorization URL 생성에 실패했습니다. from: \(authorizationEndpoint, privacy: .public)")
            return nil
        }
        
        authLog.info("[INFO] Authorization URL이 성공적으로 생성되었습니다.")
        authLog.debug("[INFO] Authorization URL: \(url.absoluteString, privacy: .public)")
        return comps?.url
    }
}

