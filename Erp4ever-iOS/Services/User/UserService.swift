//
//  UserService.swift
//  Erp4ever-iOS
//
//  Fetches user info from Gateway after login.
//

import Foundation
import os

@available(iOS 14.0, *)
private let userNetLog = Logger(subsystem: "org.everp.ios", category: "UserService")

enum UserServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    case unauthorized
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 사용자 정보 URL"
        case .http(let s, let body): return "사용자 정보 조회 실패: \(s) \(body)"
        case .decode: return "사용자 정보 응답 디코딩 실패"
        case .unauthorized: return "인증이 필요합니다"
        }
    }
}

final class UserService {
    static let shared = UserService()
    private init() {}

    // Gateway: GET /api/user/info
    func fetchUserInfo(accessToken: String) async throws -> GWUserInfoResponse {
        guard let url = URL(string: APIEndpoints.Gateway.userInfo) else { throw UserServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) {
            userNetLog.info("사용자 정보 요청 -> \(APIEndpoints.Gateway.userInfo, privacy: .public)")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw UserServiceError.invalidURL }
        if http.statusCode == 401 { throw UserServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                userNetLog.error("사용자 정보 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw UserServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<GWUserInfoResponse>.self, from: data)
            guard let info = decoded.data else { throw UserServiceError.decode }
            return info
        } catch {
            throw UserServiceError.decode
        }
    }
}

// MARK: - Decoding models
struct APIResponse<T: Decodable>: Decodable {
    let status: Int?
    let success: Bool
    let message: String?
    let data: T?
}

struct GWUserInfoResponse: Decodable {
    let userId: String
    let userName: String
    let loginEmail: String
    let userRole: String
    let userType: String
}

