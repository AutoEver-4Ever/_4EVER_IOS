//
//  QuotationListItemCard.swift
//  Erp4ever-iOS
//
//  Displays a single quotation list row in a reusable card.
//

import SwiftUI

struct QuotationListItemCard: View {
    let item: QuotationListItem

    private func mapStatusLabel(_ code: String) -> String {
        switch code.uppercased() {
        case "REVIEW": return "검토중"
        case "APPROVAL": return "승인됨"
        case "REJECTED": return "거절됨"
        case "PENDING": return "대기"
        default: return "대기"
        }
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(item.quotationNumber)
                        .font(.subheadline.bold())
                        .foregroundColor(.blue)
                    Spacer()
                    StatusLabel(statusCode: mapStatusLabel(item.statusCode))
                }
                Group {
                    HStack { Text("고객명").foregroundColor(.secondary); Spacer(); Text(item.customerName) }
                    HStack { Text("납기일").foregroundColor(.secondary); Spacer(); Text(item.dueDate) }
                    if let qty = item.quantity, let uom = item.uomName {
                        HStack { Text("수량").foregroundColor(.secondary); Spacer(); Text("\(qty) \(uom)") }
                    }
                }
                .font(.footnote)
            }
        }
    }
}

#Preview("QuotationListItemCard") {
    VStack(spacing: 12) {
        QuotationListItemCard(item: QuotationListItem(
            quotationId: "QID-1",
            quotationNumber: "Q2024-001",
            customerName: "현대자동차",
            productId: "PROD-001",
            dueDate: "2024-02-15",
            quantity: 10,
            uomName: "EA",
            statusCode: "REVIEW"
        ))
        QuotationListItemCard(item: QuotationListItem(
            quotationId: "QID-2",
            quotationNumber: "Q2024-002",
            customerName: "기아자동차",
            productId: "PROD-002",
            dueDate: "2024-03-01",
            quantity: nil,
            uomName: nil,
            statusCode: "APPROVAL"
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

