//
//  OrderCard.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/28/25.
//

import SwiftUI

struct OrderCard: View {
    let order: Orders
    let formatAmount: (Int) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.id)
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                Spacer()
                StatusLabel(statusCode: order.statusCode)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("납기일")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(order.deliveryDate)
                        .font(.caption.weight(.medium))
                }
                HStack {
                    Text("주문금액")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatAmount(order.amount))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Spacer()
                Text("상세보기")
                    .font(.caption2.weight(.medium))
                    .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
    }
}

