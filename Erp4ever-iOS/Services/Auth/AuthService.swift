//
//  AuthService.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import Foundation
import os

struct TokenResponse: Decodable {
    let access_token: String
    let refresh_token: String?
    let token_type: String?
    let expires_in: Int?
    let id_token: String?
}

enum AuthServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "토큰 엔드포인트 URL이 유효히지 않습니다."
        case .http(let s, let body): return "토큰 교환 실패:\(s) \(body)"
        case .decode: return "토큰 응답 디코딩 실패"
        }
    }
}

@available(iOS 14.0, *)
private let authNetLog = Logger(subsystem: "org.everp.ios",
                                category: "AuthService")

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // Authorization Code + PKCE 토큰 교환
    func exchangeCodeForToken(config: AuthConfig, code: String, verifier: String) async throws -> TokenResponse {
        guard let url = URL(string: config.tokenEndpoint) else { throw AuthServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // 퍼블릭 클라이언트: client_secret 없음
        let form: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": config.redirectUri,
            "client_id": config.clientID,
            "code_verifier": verifier
        ]
        req.httpBody = urlEncode(form).data(using: .utf8)

        if #available(iOS 14.0, *) {
            authNetLog.info("토큰 교환 요청 -> \(config.tokenEndpoint, privacy: .public)")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AuthServiceError.invalidURL }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                authNetLog.error("토큰 교환 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw AuthServiceError.http(status: http.statusCode, body: body)
        }
        do {
            let token = try JSONDecoder().decode(TokenResponse.self, from: data)
            // 민감 정보는 로그로 출력하지 않음
            if #available(iOS 14.0, *) {
                authNetLog.info("토큰 교환 성공\n(상태 코드: \(http.statusCode, privacy: .public))")
            }
            return token
        } catch {
            throw AuthServiceError.decode
        }
    }

    // 선택 사항: 리프레시 토큰으로 액세스 토큰 갱신
    func refreshAccessToken(config: AuthConfig, refreshToken: String) async throws -> TokenResponse {
        guard let url = URL(string: config.tokenEndpoint) else { throw AuthServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let form: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
            "client_id": config.clientID
        ]
        req.httpBody = urlEncode(form).data(using: .utf8)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw AuthServiceError.invalidURL }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw AuthServiceError.http(status: http.statusCode, body: body)
        }
        do {
            return try JSONDecoder().decode(TokenResponse.self, from: data)
        } catch {
            throw AuthServiceError.decode
        }
    }

    // x-www-form-urlencoded 바디 인코딩 유틸리티
    private func urlEncode(_ dict: [String: String]) -> String {
        dict.map { key, value in
            let k = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
            let v = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
            return "\(k)=\(v)"
        }
        .joined(separator: "&")
    }
}

