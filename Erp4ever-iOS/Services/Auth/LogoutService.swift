//
//  LogoutService.swift
//  Erp4ever-iOS
//
//  Calls auth server logout endpoint to invalidate tokens.
//

import Foundation
import os

@available(iOS 14.0, *)
private let logoutLog = Logger(subsystem: "org.everp.ios", category: "LogoutService")

enum LogoutServiceError: Error {
    case invalidURL
}

final class LogoutService {
    static let shared = LogoutService()
    private init() {}

    func logout(accessToken: String?) async {
        guard let accessToken, let url = URL(string: APIEndpoints.Auth.logout) else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            if #available(iOS 14.0, *) {
                logoutLog.info("로그아웃 호출 -> \(APIEndpoints.Auth.logout, privacy: .public)")
            }
            _ = try await URLSession.shared.data(for: req)
        } catch {
            // Best-effort: 서버 실패여도 로컬 세션은 정리
            if #available(iOS 14.0, *) {
                logoutLog.error("로그아웃 호출 실패: \(String(describing: error), privacy: .public)")
            }
        }
    }
}

