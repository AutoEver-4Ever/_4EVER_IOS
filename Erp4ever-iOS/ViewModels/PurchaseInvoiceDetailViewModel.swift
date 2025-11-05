//
//  PurchaseInvoiceDetailViewModel.swift
//  Erp4ever-iOS
//
//  Loads AR invoice detail (shown as Purchase/AP in UI).
//

import Foundation
import Combine

final class PurchaseInvoiceDetailViewModel: ObservableObject {
    @Published var detail: PurchaseInvoiceDetail?
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
                let d = try await PurchaseInvoiceService.shared.fetchDetail(accessToken: token, invoiceId: id)
                await MainActor.run { self.detail = d; self.isLoading = false }
            } catch PurchaseInvoiceServiceError.unauthorized {
                await MainActor.run { self.isLoading = false; self.error = "세션이 만료되었습니다." }
            } catch let PurchaseInvoiceServiceError.http(status, _) {
                await MainActor.run { self.isLoading = false; self.error = "상세 조회 실패 (\(status))" }
            } catch {
                await MainActor.run { self.isLoading = false; self.error = "알 수 없는 오류가 발생했습니다." }
            }
        }
    }
}

