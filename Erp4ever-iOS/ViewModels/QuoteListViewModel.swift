//
//  QuoteListViewModel.swift
//  Erp4ever-iOS
//
//  Handles loading and pagination for quotation list.
//

import Foundation
import Combine

final class QuoteListViewModel: ObservableObject {
    @Published var items: [QuotationListItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var hasNext: Bool = false

    // External filters and paging
    @Published var query: QuoteListQuery = QuoteListQuery(
        startDate: nil,
        endDate: nil,
        status: nil,
        type: nil,
        search: nil,
        sort: nil,
        page: 0,
        size: 20
    )

    private var loadingTask: Task<Void, Never>? = nil
    private var searchDebounceTask: Task<Void, Never>? = nil

    deinit {
        loadingTask?.cancel()
    }

    func loadInitial() {
        // Reset paging to first page
        query.page = 0
        fetchAndReplace()
    }

    func loadNextPage() {
        guard hasNext, !isLoading else { return }
        query.page += 1
        fetchAndAppend()
    }

    func applyStatus(_ status: String?) {
        // Reset filters and reload
        query.status = status
        loadInitial()
    }

    func applySearch(_ text: String?, type: String?) {
        query.search = (text?.isEmpty == true) ? nil : text
        query.type = (type?.isEmpty == true) ? nil : type

        // Debounce: cancel previous and schedule after 300ms
        searchDebounceTask?.cancel()
        searchDebounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled, let self else { return }
            await MainActor.run { self.loadInitial() }
        }
    }

    // MARK: - Private

    private func fetchAndReplace() {
        fetch(replace: true)
    }

    private func fetchAndAppend() {
        fetch(replace: false)
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
                let page = try await QuoteService.shared.fetchQuotationList(accessToken: token, query: self.query)
                await MainActor.run {
                    if replace {
                        self.items = page.content
                    } else {
                        self.items.append(contentsOf: page.content)
                    }
                    self.hasNext = page.pageInfo.hasNext
                    self.isLoading = false
                }
            } catch QuoteServiceError.unauthorized {
                await MainActor.run {
                    self.isLoading = false
                    self.error = "세션이 만료되었습니다. 다시 로그인 해주세요."
                }
            } catch let QuoteServiceError.http(status, body) {
                await MainActor.run {
                    self.isLoading = false
                    self.error = "견적 목록 조회 실패 (\(status))"
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.error = "알 수 없는 오류가 발생했습니다."
                }
            }
        }
    }
}
