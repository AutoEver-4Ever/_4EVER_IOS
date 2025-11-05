//
//  PurchaseOrderListViewModel.swift
//  Erp4ever-iOS
//
//  공급사용 발주서 목록 로딩/검색/페이징.
//

import Foundation
import Combine

final class PurchaseOrderListViewModel: ObservableObject {
    @Published var items: [PurchaseOrderListItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var hasNext: Bool = false

    @Published var query = PurchaseOrderQuery()

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

    // 상태 필터 적용
    func applyStatus(_ statusCode: String) {
        query.statusCode = statusCode
        loadInitial()
    }

    // 검색 타입/키워드 적용 (디바운스)
    func applySearch(type: String?, keyword: String?) {
        query.type = (type?.isEmpty == true) ? nil : type
        query.keyword = (keyword?.isEmpty == true) ? nil : keyword
        debounceTask?.cancel()
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { self?.loadInitial() }
        }
    }

    // 기간 필터 적용
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
                await MainActor.run { self.isLoading = false; self.error = "인증 토큰이 없습니다." }
                return
            }

            do {
                let page = try await PurchaseOrderService.shared.fetchList(accessToken: token, query: query)
                await MainActor.run {
                    if replace { self.items = page.content } else { self.items.append(contentsOf: page.content) }
                    self.hasNext = page.pageInfo.hasNext
                    self.isLoading = false
                }
            } catch PurchaseOrderServiceError.unauthorized {
                await MainActor.run { self.isLoading = false; self.error = "세션이 만료되었습니다." }
            } catch let PurchaseOrderServiceError.http(status, _) {
                await MainActor.run { self.isLoading = false; self.error = "발주서 목록 조회 실패 (\(status))" }
            } catch {
                await MainActor.run { self.isLoading = false; self.error = "알 수 없는 오류가 발생했습니다." }
            }
        }
    }
}

