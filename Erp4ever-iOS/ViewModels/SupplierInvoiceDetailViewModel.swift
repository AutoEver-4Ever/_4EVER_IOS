//
//  SupplierInvoiceDetailViewModel.swift
//  Erp4ever-iOS
//
//  공급사용 매출 전표 상세 뷰모델.
//

import Foundation
import Combine

final class SupplierInvoiceDetailViewModel: ObservableObject {
    @Published var detail: SupplierInvoiceDetail?
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
                let d = try await SupplierInvoiceService.shared.fetchDetail(accessToken: token, id: id)
                await MainActor.run { self.detail = d; self.isLoading = false }
            } catch SupplierInvoiceServiceError.unauthorized {
                await MainActor.run { self.isLoading = false; self.error = "세션이 만료되었습니다." }
            } catch let SupplierInvoiceServiceError.http(status, _) {
                await MainActor.run { self.isLoading = false; self.error = "매출 전표 상세 조회 실패 (\(status))" }
            } catch {
                await MainActor.run { self.isLoading = false; self.error = "알 수 없는 오류가 발생했습니다." }
            }
        }
    }
}
