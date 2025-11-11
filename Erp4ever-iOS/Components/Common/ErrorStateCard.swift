//
//  ErrorStateCard.swift
//  Erp4ever-iOS
//
//  Reusable error message card with retry.
//

import SwiftUI

struct ErrorStateCard: View {
    let title: String
    let message: String?
    let retryTitle: String
    let onRetry: () -> Void

    init(title: String,
         message: String? = nil,
         retryTitle: String = "다시 시도",
         onRetry: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    var body: some View {
        Card {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let message, !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button(retryTitle, action: onRetry)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview("ErrorStateCard") {
    VStack(spacing: 12) {
        ErrorStateCard(title: "견적 목록을 불러오지 못했습니다.", message: "네트워크 오류가 발생했습니다.") {}
        ErrorStateCard(title: "오류", message: nil) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

