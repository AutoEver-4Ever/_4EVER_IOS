//
//  PurchaseOrderTypePromptView.swift
//  Erp4ever-iOS
//
//  검색 타입을 빠르게 전환할 수 있는 프롬프트.
//

import SwiftUI

struct PurchaseOrderTypePromptView: View {
    @Binding var selectedType: String // "SupplierCompanyName" | "PurchaseOrderNumber"

    private var options: [(label: String, value: String)] {
        [
            ("공급사명", "SupplierCompanyName"),
            ("발주서번호", "PurchaseOrderNumber")
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("공급사명 또는 발주서번호로 검색해보세요.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(options, id: \.value) { option in
                    Button(action: { selectedType = option.value }) {
                        Text(option.label)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.2))
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

private struct _PurchaseOrderTypePromptPreviewHost: View {
    @State private var sel: String = "SupplierCompanyName"

    var body: some View {
        PurchaseOrderTypePromptView(selectedType: $sel)
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
    }
}

#Preview("PurchaseOrderTypePromptView") {
    _PurchaseOrderTypePromptPreviewHost()
}
