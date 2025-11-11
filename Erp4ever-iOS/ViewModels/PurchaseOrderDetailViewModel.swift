//
//  PurchaseOrderDetailViewModel.swift
//  Erp4ever-iOS
//
//  공급사용 발주서 상세 로딩.
//

import Foundation
import Combine

final class PurchaseOrderDetailViewModel: ObservableObject {
    @Published var detail: PurchaseOrderDetail?
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private var task: Task<Void, Never>? = nil
    deinit { task?.cancel() }

    func load(id: String) {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            await MainActor.run { self.isLoading = true; self.error = nil }

            guard let token = TokenStore.shared.loadAccessToken() else {
                await MainActor.run { self.isLoading = false; self.error = "인증 토큰이 없습니다." }
                return
            }

            do {
                let d = try await PurchaseOrderService.shared.fetchDetail(accessToken: token, id: id)
                await MainActor.run { self.detail = d; self.isLoading = false }
            } catch PurchaseOrderServiceError.unauthorized {
                await MainActor.run { self.isLoading = false; self.error = "세션이 만료되었습니다." }
            } catch let PurchaseOrderServiceError.http(status, _) {
                await MainActor.run { self.isLoading = false; self.error = "발주서 상세 조회 실패 (\(status))" }
            } catch {
                await MainActor.run { self.isLoading = false; self.error = "알 수 없는 오류가 발생했습니다." }
            }
        }
    }
}

