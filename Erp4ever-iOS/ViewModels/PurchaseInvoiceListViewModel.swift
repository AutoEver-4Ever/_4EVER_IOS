//
//  PurchaseInvoiceListViewModel.swift
//  Erp4ever-iOS
//
//  Loads AR invoice list (shown as Purchase/AP in UI).
//

import Foundation
import Combine

final class PurchaseInvoiceListViewModel: ObservableObject {
    @Published var items: [PurchaseInvoiceListItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var hasNext: Bool = false

    @Published var query: PurchaseInvoiceQuery = PurchaseInvoiceQuery(
        company: nil, startDate: nil, endDate: nil, page: 0, size: 20
    )

    private var loadingTask: Task<Void, Never>? = nil
    private var debounceTask: Task<Void, Never>? = nil

    deinit { loadingTask?.cancel(); debounceTask?.cancel() }

    func loadInitial() {
        query.page = 0
        fetch(replace: true)
    }

    func loadNextPage() {
        guard hasNext, !isLoading else { return }
        query.page += 1
        fetch(replace: false)
    }

    func applyCompany(_ company: String?) {
        query.company = (company?.isEmpty == true) ? nil : company
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.loadInitial() }
        }
    }

    func applyDateRange(start: String?, end: String?) {
        query.startDate = start
        query.endDate = end
        loadInitial()
    }

    private func fetch(replace: Bool) {
        loadingTask?.cancel()
        loadingTask = Task { [weak self] in
            guard let self else { return }
            await MainActor.run { self.isLoading = true; self.error = nil }

            guard let token = TokenStore.shared.loadAccessToken() else {
                await MainActor.run {
                    self.isLoading = false
                    self.error = "인증 토큰이 없습니다. 다시 로그인 해주세요."
                }
                return
            }

            do {
                let page = try await PurchaseInvoiceService.shared.fetchList(accessToken: token, query: query)
                await MainActor.run {
                    if replace { self.items = page.content } else { self.items.append(contentsOf: page.content) }
                    self.hasNext = page.pageInfo.hasNext
                    self.isLoading = false
                }
            } catch PurchaseInvoiceServiceError.unauthorized {
                await MainActor.run { self.isLoading = false; self.error = "세션이 만료되었습니다. 다시 로그인 해주세요." }
            } catch let PurchaseInvoiceServiceError.http(status, _) {
                await MainActor.run { self.isLoading = false; self.error = "전표 목록 조회 실패 (\(status))" }
            } catch {
                await MainActor.run { self.isLoading = false; self.error = "알 수 없는 오류가 발생했습니다." }
            }
        }
    }
}
