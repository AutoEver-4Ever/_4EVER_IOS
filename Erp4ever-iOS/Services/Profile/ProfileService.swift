//
//  ProfileService.swift
//  Erp4ever-iOS
//
//  게이트웨이 프로필 조회 연동: GET /api/business/profile
//  - 토큰 필수, Authorization: Bearer <token>
//  - 로깅 포맷: [INFO]/[ERROR]
//

import Foundation
import os

@available(iOS 14.0, *)
private let profileLog = Logger(subsystem: "org.everp.ios", category: "ProfileService")

enum ProfileServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 프로필 API URL"
        case .http(let s, let body): return "프로필 API 호출 실패: \(s) \(body)"
        case .decode: return "프로필 응답 디코딩 실패"
        case .unauthorized: return "인증이 필요합니다"
        }
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    func fetchProfile(accessToken: String) async throws -> BusinessProfilePayload {
        guard let url = URL(string: APIEndpoints.Gateway.businessProfile) else {
            throw ProfileServiceError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) { profileLog.info("프로필 조회 요청 -> \(url.absoluteString, privacy: .public)") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw ProfileServiceError.invalidURL }

        if http.statusCode == 401 {
            if #available(iOS 14.0, *) { profileLog.error("[ERROR][401] 프로필을 조회하는데 실패했습니다.") }
            print("[ERROR][401] 프로필을 조회하는데 실패했습니다.")
            throw ProfileServiceError.unauthorized
        }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                profileLog.error("프로필 조회 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            if #available(iOS 14.0, *) { profileLog.error("[ERROR][\(http.statusCode)] 프로필을 조회하는데 실패했습니다.") }
            print("[ERROR][\(http.statusCode)] 프로필을 조회하는데 실패했습니다.")
            throw ProfileServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(ApiResponse<BusinessProfilePayload>.self, from: data)
            guard let profile = decoded.data else { throw ProfileServiceError.decode }
            if #available(iOS 14.0, *) { profileLog.info("[INFO][\(http.statusCode)] 프로필을 성공적으로 조회했습니다.") }
            print("[INFO][\(http.statusCode)] 프로필을 성공적으로 조회했습니다.")
            return profile
        } catch {
            if #available(iOS 14.0, *) { profileLog.error("[ERROR][500] 프로필을 조회하는데 실패했습니다.") }
            print("[ERROR][500] 프로필을 조회하는데 실패했습니다.")
            throw ProfileServiceError.decode
        }
    }
}
