//
//  EmptyStateCard.swift
//  Erp4ever-iOS
//
//  Reusable empty state view.
//

import SwiftUI

struct EmptyStateCard: View {
    let icon: String
    let message: String

    init(icon: String = "doc.text", message: String) {
        self.icon = icon
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                )
            Text(message)
                .foregroundColor(.gray)
        }
    }
}

#Preview("EmptyStateCard") {
    EmptyStateCard(message: "목록이 비어 있습니다.")
        .padding()
        .background(Color(.systemGroupedBackground))
}

