//
//  QuoteService.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/5/25.
//

import Foundation
import os

@available(iOS 14.0, *)
private let quoteLog = Logger(subsystem: "org.everp.ios.quote", category: "QuoteService")

enum QuoteServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 견적 목록 URL"
        case .http(let s, let body): return "견적 목록 조회 실패: \(s) \(body)"
        case .decode: return "견적 목록을 파싱하는 데 실패했습니다."
        case .unauthorized: return "권한이 없습니다."
        }
    }
}

final class QuoteService {
    static let shared = QuoteService()
    private init() {}

    // GET /api/business/sd/quotations
    func fetchQuotationList(accessToken: String, query: QuoteListQuery) async throws -> PageResponse<QuotationListItem> {
        guard var components = URLComponents(string: APIEndpoints.Gateway.quotations) else {
            throw QuoteServiceError.invalidURL
        }
        components.queryItems = query.asQueryItems()
        guard let url = components.url else { throw QuoteServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) {
            quoteLog.info("[INFO] 견적 목록 요청 -> \(url.absoluteString, privacy: .public)")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw QuoteServiceError.invalidURL }
        if http.statusCode == 401 { throw QuoteServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                quoteLog.error("[ERROR] 견적 목록 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw QuoteServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<PageResponse<QuotationListItem>>.self, from: data)
            guard let page = decoded.data else { throw QuoteServiceError.decode }
            if #available(iOS 14.0, *) {
                quoteLog.info("[INFO] 견적 목록 조회 성공: total=\(page.total, privacy: .public), page=\(page.pageInfo.number, privacy: .public)")
            }
            return page
        } catch {
            throw QuoteServiceError.decode
        }
    }

    // GET /api/business/sd/quotations/{quotationId}
    func fetchQuotationDetail(accessToken: String, quotationId: String) async throws -> QuotationDetail {
        let endpoint = APIEndpoints.Gateway.quotationDetail.replacingOccurrences(of: "{quotationId}", with: quotationId)
        guard let url = URL(string: endpoint) else { throw QuoteServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) {
            quoteLog.info("견적 상세 요청 -> \(url.absoluteString, privacy: .public)")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw QuoteServiceError.invalidURL }
        if http.statusCode == 401 { throw QuoteServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                quoteLog.error("견적 상세 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw QuoteServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<QuotationDetail>.self, from: data)
            guard let detail = decoded.data else { throw QuoteServiceError.decode }
            return detail
        } catch {
            throw QuoteServiceError.decode
        }
    }
}
