//
//  QuoteDetailView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI


struct QuoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    let id: String
    
    private func formatAmount(_ amount: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return "\(f.string(from: NSNumber(value: amount)) ?? "0")원"
    }
    
    private var quote: QuoteDetailModel {
        QuoteDetailModel(
            id: id,
            customerName: "현대자동차",
            manager: "김철수",
            email: "kim@hyundai.com",
            quoteDate: "2024-01-15",
            validityPeriod: "2024-02-15",
            paymentTerms: "외상 30일",
            deliveryTerms: "배송",
            warrantyPeriod: "1년",
            items: [
                .init(productName: "프론트 범퍼", specification: "ABS 플라스틱, 블랙", quantity: 10, unitPrice: 500_000, amount: 5_000_000),
                .init(productName: "리어 범퍼", specification: "ABS 플라스틱, 블랙", quantity: 10, unitPrice: 450_000, amount: 4_500_000),
                .init(productName: "사이드 미러", specification: "전동 접이식, 열선 내장", quantity: 20, unitPrice: 275_000, amount: 5_500_000)
            ],
            remarks: "긴급 주문으로 빠른 납기 요청드립니다.",
            status: "검토중",
            totalAmount: 15_000_000
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // 기본 정보 카드
                Card {
                    HStack {
                        Text(quote.id)
                            .font(.title3.weight(.semibold))
                        Spacer()
                        StatusLabel(statusCode: quote.status)
                    }
                    .padding(.bottom, 6)
                    
                    KeyValueRow(key: "견적일자", value: quote.quoteDate)
                    KeyValueRow(key: "유효기간", value: quote.validityPeriod)
                    KeyValueRow(
                        key: "총 금액",
                        value: formatAmount(quote.totalAmount),
                        valueStyle: .emphasis
                    )
                }
                
                // 고객 정보 카드
                Card {
                    CardTitle("고객 정보")
                    KeyValueRow(key: "고객명", value: quote.customerName)
                    KeyValueRow(key: "담당자", value: quote.manager)
                    KeyValueRow(key: "이메일", value: quote.email)
                }
                
                // 견적 조건 카드
                Card {
                    CardTitle("견적 조건")
                    KeyValueRow(key: "결제조건", value: quote.paymentTerms)
                    KeyValueRow(key: "납품조건", value: quote.deliveryTerms)
                    KeyValueRow(key: "보증기간", value: quote.warrantyPeriod)
                }
                
                // 품목 카드
                Card {
                    CardTitle("견적 품목")
                    VStack(spacing: 10) {
                        ForEach(quote.items) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(item.productName)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text(formatAmount(item.amount))
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(.blue)
                                }
                                Text(item.specification)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Text("수량: \(item.quantity)개")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("단가: \(formatAmount(item.unitPrice))")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2))
                            )
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        HStack {
                            Text("총 금액")
                                .font(.body.weight(.semibold))
                            Spacer()
                            Text(formatAmount(quote.totalAmount))
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                // 비고
                if !quote.remarks.isEmpty {
                    Card {
                        CardTitle("비고")
                        Text(quote.remarks)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding()
        }
        .background(Color.white)
        
        
    }
}

#Preview {
    NavigationStack {
        QuoteDetailView(id: "Q2024-001")
    }
}

