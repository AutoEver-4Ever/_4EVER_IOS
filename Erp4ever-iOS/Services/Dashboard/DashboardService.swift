import Foundation
import os

@available(iOS 14.0, *)
private let dashboardLog = Logger(subsystem: "org.everp.ios.dashboard", category: "DashboardService")

enum DashboardServiceError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case http(status: Int, body: String)
    case decode

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 대시보드 워크플로우 URL"
        case .unauthorized: return "인증이 필요합니다."
        case .http(let status, _): return "대시보드 워크플로우 조회 실패: \(status)"
        case .decode: return "대시보드 워크플로우 응답 파싱 실패"
        }
    }
}

final class DashboardService {
    static let shared = DashboardService()
    private init() {}

    func fetchWorkflows(accessToken: String) async throws -> DashboardWorkflowResponse {
        guard let url = URL(string: APIEndpoints.Gateway.dashboardWorkflows) else {
            throw DashboardServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) {
            dashboardLog.info("[INFO] 워크플로우 조회 요청 -> \(url.absoluteString, privacy: .public)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw DashboardServiceError.invalidURL }

        if http.statusCode == 401 { throw DashboardServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                dashboardLog.error("[ERROR] 워크플로우 조회 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw DashboardServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(ApiResponse<DashboardWorkflowResponse>.self, from: data)
            guard let workflows = decoded.data else { throw DashboardServiceError.decode }
            if #available(iOS 14.0, *) {
                dashboardLog.info("[INFO] 워크플로우 조회 성공 - 탭 수: \(workflows.tabs.count, privacy: .public)")
            }
            return workflows
        } catch {
            throw DashboardServiceError.decode
        }
    }
}
