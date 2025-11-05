//
//  PurchaseInvoiceService.swift
//  Erp4ever-iOS
//
//  Calls AR invoice APIs (shown as Purchase/AP in UI).
//

import Foundation
import os

@available(iOS 14.0, *)
private let invoiceLog = Logger(subsystem: "org.everp.ios", category: "PurchaseInvoiceService")

enum PurchaseInvoiceServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 전표 API URL"
        case .http(let s, let body): return "전표 API 호출 실패: \(s) \(body)"
        case .decode: return "전표 응답 디코딩 실패"
        case .unauthorized: return "인증이 필요합니다"
        }
    }
}

final class PurchaseInvoiceService {
    static let shared = PurchaseInvoiceService()
    private init() {}

    // GET /api/business/fcm/invoice/ar
    func fetchList(accessToken: String, query: PurchaseInvoiceQuery) async throws -> PageResponse<PurchaseInvoiceListItem> {
        guard var components = URLComponents(string: APIEndpoints.Gateway.accountReceivable) else {
            throw PurchaseInvoiceServiceError.invalidURL
        }
        components.queryItems = query.asQueryItems()
        guard let url = components.url else { throw PurchaseInvoiceServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) {
            invoiceLog.info("전표 목록 요청 -> \(url.absoluteString, privacy: .public)")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw PurchaseInvoiceServiceError.invalidURL }
        if http.statusCode == 401 { throw PurchaseInvoiceServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                invoiceLog.error("전표 목록 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw PurchaseInvoiceServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<PageResponse<PurchaseInvoiceListItem>>.self, from: data)
            guard let page = decoded.data else { throw PurchaseInvoiceServiceError.decode }
            return page
        } catch {
            throw PurchaseInvoiceServiceError.decode
        }
    }

    // GET /api/business/fcm/invoice/ar/{invoiceId}
    func fetchDetail(accessToken: String, invoiceId: String) async throws -> PurchaseInvoiceDetail {
        let endpoint = APIEndpoints.Gateway.accountReceivableDetail.replacingOccurrences(of: "{invoiceId}", with: invoiceId)
        guard let url = URL(string: endpoint) else { throw PurchaseInvoiceServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) {
            invoiceLog.info("전표 상세 요청 -> \(url.absoluteString, privacy: .public)")
        }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw PurchaseInvoiceServiceError.invalidURL }
        if http.statusCode == 401 { throw PurchaseInvoiceServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                invoiceLog.error("전표 상세 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            throw PurchaseInvoiceServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<PurchaseInvoiceDetail>.self, from: data)
            guard let detail = decoded.data else { throw PurchaseInvoiceServiceError.decode }
            return detail
        } catch {
            throw PurchaseInvoiceServiceError.decode
        }
    }
}

