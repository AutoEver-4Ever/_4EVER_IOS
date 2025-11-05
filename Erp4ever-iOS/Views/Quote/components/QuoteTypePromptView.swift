//
//  QuoteTypePromptView.swift
//  Erp4ever-iOS
//
//  Type selection prompt that slides from bottom with opacity.
//

import SwiftUI

struct QuoteTypePromptView: View {
    @Binding var selectedType: String // "quotationNumber" | "customerName" | "managerName"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("견적번호, 고객사, 담당자로 찾아보세요.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                let options: [(String, String)] = [("견적번호", "quotationNumber"), ("고객명", "customerName"), ("담당자", "managerName")]
                ForEach(options, id: \.1) { label, value in
                    Button(action: { selectedType = value }) {
                        Text(label)
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

private struct _QuoteTypePromptPreviewHost: View {
    @State var sel: String = "quotationNumber"
    var body: some View {
        QuoteTypePromptView(selectedType: $sel)
            .padding(.vertical)
            .background(Color(.systemGroupedBackground))
    }
}

#Preview("QuoteTypePromptView") {
    _QuoteTypePromptPreviewHost()
}
