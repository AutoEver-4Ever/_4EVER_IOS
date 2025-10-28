//
//  QuoteCard.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct QuoteCard: View {
    let quote: Quotes
    let statusCode: String
    let formatAmount: (Int) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(quote.id)
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
                Spacer()
                StatusLabel(statusCode: statusCode)
            }
            
            Group {
                HStack { Text("고객명").foregroundColor(.secondary); Spacer(); Text(quote.customerName) }
                HStack { Text("담당자").foregroundColor(.secondary); Spacer(); Text(quote.manager) }
                HStack { Text("견적일자").foregroundColor(.secondary); Spacer(); Text(quote.quoteDate) }
                HStack { Text("납기일").foregroundColor(.secondary); Spacer(); Text(quote.deliveryDate) }
                HStack {
                    Text("견적금액").foregroundColor(.secondary)
                    Spacer()
                    Text(formatAmount(quote.amount))
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .font(.footnote)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
    }
}

