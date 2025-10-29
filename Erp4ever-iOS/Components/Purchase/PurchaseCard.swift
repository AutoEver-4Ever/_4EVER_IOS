//
//  PurchaseCard.swift
//  Erp4ever-iOS
//
//  Created by oyun on 2025-10-29.
//

import SwiftUI

struct PurchaseCard: View {
    let purchase: Purchase
    let selected: Bool
    let onToggle: (String) -> Void
    let formatAmount: (Int) -> String
    let statusColor: (Purchase.Status) -> (bg: Color, fg: Color)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                if purchase.status == .미수 {
                    Button(action: { onToggle(purchase.id) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                                .frame(width: 22, height: 22)
                                .background(selected ? Color.blue : Color.clear)
                                .cornerRadius(4)
                            if selected {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.trailing, 6)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(purchase.id)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.blue)
                        Spacer()
                        Text(purchase.status.rawValue)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(statusColor(purchase.status).bg))
                            .foregroundColor(statusColor(purchase.status).fg)
                    }
                    KeyValueRow(key: "내용", value: purchase.content)
                    KeyValueRow(key: "거래처", value: purchase.supplier)
                    KeyValueRow(key: "금액", value: formatAmount(purchase.amount))
                    KeyValueRow(key: "전표 발생일", value: purchase.issueDate)
                    KeyValueRow(key: "만기일", value: purchase.dueDate)
                    KeyValueRow(key: "참조번호", value: purchase.referenceNumber)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
}
