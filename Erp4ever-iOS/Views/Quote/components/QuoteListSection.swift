//
//  QuoteListSection.swift
//  Erp4ever-iOS
//
//  Renders quotation list with loading/error/empty states.
//

import SwiftUI

struct QuoteListSection: View {
    let items: [QuotationListItem]
    let isLoading: Bool
    let error: String?
    let onRetry: () -> Void
    let onReachEnd: () -> Void

    var body: some View {
        Group {
            if isLoading && items.isEmpty {
                ProgressView().padding(.top, 40)
            } else if let err = error, items.isEmpty {
                ErrorStateCard(title: "견적 목록을 불러오지 못했습니다.", message: err, onRetry: onRetry)
                    .padding(.horizontal)
                    .padding(.top, 40)
            } else if items.isEmpty {
                EmptyStateCard(message: "목록이 비어 있습니다.")
                    .padding(.top, 60)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                        NavigationLink(destination: QuoteDetailView(id: item.quotationId)) {
                            QuotationListItemCard(item: item)
                        }
                        .onAppear {
                            if idx == items.count - 1 { onReachEnd() }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 16)
                if isLoading { ProgressView().padding(.bottom, 16) }
            }
        }
    }
}

