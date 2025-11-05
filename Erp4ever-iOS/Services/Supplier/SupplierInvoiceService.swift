//
//  SupplierInvoiceService.swift
//  Erp4ever-iOS
//
//  공급사용 매출 전표(AR) 조회 서비스.
//  - 목록/상세 조회를 AR 엔드포인트로 호출함(GW가 SUPPLIER 토큰이면 내부적으로 AP로 스위칭)
//  - 토큰은 Authorization 헤더로 전송
//  - 로깅 포맷: [INFO]/[ERROR]
//

import Foundation
import os

@available(iOS 14.0, *)
private let supplierInvoiceLog = Logger(subsystem: "org.everp.ios", category: "SupplierInvoiceService")

enum SupplierInvoiceServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 매출 전표 API URL"
        case .http(let s, let body): return "매출 전표 API 호출 실패: \(s) \(body)"
        case .decode: return "매출 전표 응답 디코딩 실패"
        case .unauthorized: return "인증이 필요합니다"
        }
    }
}

final class SupplierInvoiceService {
    static let shared = SupplierInvoiceService()
    private init() {}

    // GET /api/business/fcm/invoice/ar
    func fetchList(accessToken: String, query: SupplierInvoiceQuery) async throws -> PageResponse<SupplierInvoiceListItem> {
        guard var components = URLComponents(string: APIEndpoints.Gateway.accountReceivable) else {
            throw SupplierInvoiceServiceError.invalidURL
        }
        components.queryItems = query.asQueryItems()
        guard let url = components.url else { throw SupplierInvoiceServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) { supplierInvoiceLog.info("매출 전표 목록 요청 -> \(url.absoluteString, privacy: .public)") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw SupplierInvoiceServiceError.invalidURL }

        if http.statusCode == 401 {
            if #available(iOS 14.0, *) { supplierInvoiceLog.error("[ERROR][401] 매출 전표 목록을 조회하는데 실패했습니다.") }
            print("[ERROR][401] 매출 전표 목록을 조회하는데 실패했습니다.")
            throw SupplierInvoiceServiceError.unauthorized
        }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                supplierInvoiceLog.error("매출 전표 목록 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            if #available(iOS 14.0, *) { supplierInvoiceLog.error("[ERROR][\(http.statusCode)] 매출 전표 목록을 조회하는데 실패했습니다.") }
            print("[ERROR][\(http.statusCode)] 매출 전표 목록을 조회하는데 실패했습니다.")
            throw SupplierInvoiceServiceError.http(status: http.statusCode, body: body)
        }

        do {
            // 최초 도입 시 구조 확인을 위해 raw body도 출력 가능
            // let raw = String(data: data, encoding: .utf8) ?? ""; print("[DEBUG] BODY: \(raw)")
            let decoded = try JSONDecoder().decode(APIResponse<PageResponse<SupplierInvoiceListItem>>.self, from: data)
            guard let page = decoded.data else { throw SupplierInvoiceServiceError.decode }
            if #available(iOS 14.0, *) { supplierInvoiceLog.info("[INFO][\(http.statusCode)] 매출 전표 목록을 성공적으로 조회했습니다.") }
            print("[INFO][\(http.statusCode)] 매출 전표 목록을 성공적으로 조회했습니다.")
            return page
        } catch {
            if #available(iOS 14.0, *) { supplierInvoiceLog.error("[ERROR][500] 매출 전표 목록을 조회하는데 실패했습니다.") }
            print("[ERROR][500] 매출 전표 목록을 조회하는데 실패했습니다.")
            throw SupplierInvoiceServiceError.decode
        }
    }

    // GET /api/business/fcm/invoice/ar/{invoiceId}
    func fetchDetail(accessToken: String, id invoiceId: String) async throws -> SupplierInvoiceDetail {
        let endpoint = APIEndpoints.Gateway.accountReceivableDetail.replacingOccurrences(of: "{invoiceId}", with: invoiceId)
        guard let url = URL(string: endpoint) else { throw SupplierInvoiceServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) { supplierInvoiceLog.info("매출 전표 상세 요청 -> \(url.absoluteString, privacy: .public)") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw SupplierInvoiceServiceError.invalidURL }

        if http.statusCode == 401 {
            if #available(iOS 14.0, *) { supplierInvoiceLog.error("[ERROR][401] 매출 전표 상세를 조회하는데 실패했습니다.") }
            print("[ERROR][401] 매출 전표 상세를 조회하는데 실패했습니다.")
            throw SupplierInvoiceServiceError.unauthorized
        }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) {
                supplierInvoiceLog.error("매출 전표 상세 실패 (상태 코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))")
            }
            if #available(iOS 14.0, *) { supplierInvoiceLog.error("[ERROR][\(http.statusCode)] 매출 전표 상세를 조회하는데 실패했습니다.") }
            print("[ERROR][\(http.statusCode)] 매출 전표 상세를 조회하는데 실패했습니다.")
            throw SupplierInvoiceServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<SupplierInvoiceDetail>.self, from: data)
            guard let detail = decoded.data else { throw SupplierInvoiceServiceError.decode }
            if #available(iOS 14.0, *) { supplierInvoiceLog.info("[INFO][\(http.statusCode)] 매출 전표 상세를 성공적으로 조회했습니다.") }
            print("[INFO][\(http.statusCode)] 매출 전표 상세를 성공적으로 조회했습니다.")
            return detail
        } catch {
            if #available(iOS 14.0, *) { supplierInvoiceLog.error("[ERROR][500] 매출 전표 상세를 조회하는데 실패했습니다.") }
            print("[ERROR][500] 매출 전표 상세를 조회하는데 실패했습니다.")
            throw SupplierInvoiceServiceError.decode
        }
    }
}
