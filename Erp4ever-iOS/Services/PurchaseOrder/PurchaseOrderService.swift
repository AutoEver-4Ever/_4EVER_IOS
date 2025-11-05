//
//  PurchaseOrderService.swift
//  Erp4ever-iOS
//
//  공급사용 발주서(PO) 목록/상세 API 호출.
//

import Foundation
import os

@available(iOS 14.0, *)
private let poLog = Logger(subsystem: "org.everp.ios", category: "PurchaseOrderService")

enum PurchaseOrderServiceError: Error, LocalizedError {
    case invalidURL
    case http(status: Int, body: String)
    case decode
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "유효하지 않은 발주서 API URL"
        case .http(let s, let body): return "발주서 API 호출 실패: \(s) \(body)"
        case .decode: return "발주서 응답 디코딩 실패"
        case .unauthorized: return "인증이 필요합니다"
        }
    }
}

final class PurchaseOrderService {
    static let shared = PurchaseOrderService()
    private init() {}

    // 발주서 목록 조회
    func fetchList(accessToken: String, query: PurchaseOrderQuery) async throws -> PageResponse<PurchaseOrderListItem> {
        guard var components = URLComponents(string: APIEndpoints.Gateway.purchaseOrders) else {
            throw PurchaseOrderServiceError.invalidURL
        }
        components.queryItems = query.asQueryItems()
        guard let url = components.url else { throw PurchaseOrderServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) { poLog.info("발주서 목록 요청 -> \(url.absoluteString, privacy: .public)") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw PurchaseOrderServiceError.invalidURL }
        if http.statusCode == 401 {
            // [ERROR] 401 인증 오류
            if #available(iOS 14.0, *) { poLog.error("[ERROR][401] 발주서 목록을 조회하는데 실패했습니다.") }
            print("[ERROR][401] 발주서 목록을 조회하는데 실패했습니다.")
            throw PurchaseOrderServiceError.unauthorized
        }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) { poLog.error("발주서 목록 실패 (코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))") }
            // [ERROR] 비정상 상태 코드
            if #available(iOS 14.0, *) { poLog.error("[ERROR][\(http.statusCode)] 발주서 목록을 조회하는데 실패했습니다.") }
            print("[ERROR][\(http.statusCode)] 발주서 목록을 조회하는데 실패했습니다.")
            throw PurchaseOrderServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<POPaged<PurchaseOrderListItem>>.self, from: data)
            guard let po = decoded.data else { throw PurchaseOrderServiceError.decode }
            let pageInfo = PageInfo(number: po.page.number, size: po.page.size, totalElements: po.page.totalElements, totalPages: po.page.totalPages, hasNext: po.page.hasNext)
            let page = PageResponse(total: po.page.totalElements, content: po.content, pageInfo: pageInfo)
            if #available(iOS 14.0, *) { poLog.info("[INFO][\(http.statusCode)] 발주서 목록을 성공적으로 조회했습니다.") }
            print("[INFO][\(http.statusCode)] 발주서 목록을 성공적으로 조회했습니다.")
            return page
        } catch {
            // [ERROR] 디코딩 실패는 500으로 처리
            if #available(iOS 14.0, *) { poLog.error("[ERROR][500] 발주서 목록을 조회하는데 실패했습니다.") }
            print("[ERROR][500] 발주서 목록을 조회하는데 실패했습니다.")
            throw PurchaseOrderServiceError.decode
        }
    }

    // 발주서 상세 조회
    func fetchDetail(accessToken: String, id: String) async throws -> PurchaseOrderDetail {
        let endpoint = APIEndpoints.Gateway.purchaseOrderDetail.replacingOccurrences(of: "{purchaseOrderId}", with: id)
        guard let url = URL(string: endpoint) else { throw PurchaseOrderServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        if #available(iOS 14.0, *) { poLog.info("발주서 상세 요청 -> \(url.absoluteString, privacy: .public)") }

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw PurchaseOrderServiceError.invalidURL }
        if http.statusCode == 401 { throw PurchaseOrderServiceError.unauthorized }
        if !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? ""
            if #available(iOS 14.0, *) { poLog.error("발주서 상세 실패 (코드: \(http.statusCode, privacy: .public))\n\(body, privacy: .private(mask: .hash))") }
            throw PurchaseOrderServiceError.http(status: http.statusCode, body: body)
        }

        do {
            let decoded = try JSONDecoder().decode(APIResponse<PurchaseOrderDetail>.self, from: data)
            guard let detail = decoded.data else { throw PurchaseOrderServiceError.decode }
            return detail
        } catch {
            throw PurchaseOrderServiceError.decode
        }
    }
}
