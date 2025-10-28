//
//  OrderDetailView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/28/25.
//

import SwiftUI

struct OrderDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let id: String
    
    private var order: OrderDetailModel {
        OrderDetailModel(
            id: id,
            customerName: "현대자동차",
            manager: "김철수",
            email: "kim@hyundai.com",
            orderDate: "2024-01-20",
            deliveryDate: "2024-02-15",
            amount: 15_000_000,
            statusCode: "배송중",
            items: [
                .init(productName: "프론트 범퍼", specification: "ABS 플라스틱, 블랙", quantity: 10, unitPrice: 500_000, amount: 5_000_000),
                .init(productName: "리어 범퍼", specification: "ABS 플라스틱, 블랙", quantity: 10, unitPrice: 450_000, amount: 4_500_000),
                .init(productName: "사이드 미러", specification: "전동 접이식, 열선 내장", quantity: 20, unitPrice: 275_000, amount: 5_500_000)
            ],
            deliveryAddress: "서울시 강남구 테헤란로 123 현대자동차 본사",
            trackingNumber: "HD2024012001"
        )
    }
    
    private func formatAmount(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return "\(f.string(from: NSNumber(value: value)) ?? "0")원"
    }
    
    private enum OrderStatus: String, CaseIterable {
        case 생산중, 출고준비완료, 배송중, 배송완료, 구매확정
    }
    
    
    private var statusSteps: [(OrderStatus, Bool, Bool)] {
        let steps = OrderStatus.allCases
        let current = steps.firstIndex(of: OrderStatus(rawValue: order.statusCode) ?? .생산중) ?? 0
        return steps.enumerated().map { (index, step) in
            (step, index <= current, index == current)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                
                // 주문 기본 정보
                Card {
                    HStack {
                        Text(order.id)
                            .font(.title3.weight(.semibold))
                        Spacer()
                        StatusLabel(statusCode: order.statusCode)
                    }
                    .padding(.bottom, 6)
                    
                    KeyValueRow(key: "주문일자", value: order.orderDate)
                    KeyValueRow(key: "납기일", value: order.deliveryDate)
                    KeyValueRow(key: "주문금액", value: formatAmount(order.amount), valueStyle: .emphasis)
                    
                    if let tracking = order.trackingNumber {
                        KeyValueRow(key: "운송장번호", value: tracking)
                    }
                }
                
                // 주문 진행 상태
                Card {
                    CardTitle("주문 진행 상태")
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(statusSteps, id: \.0.rawValue) { step, completed, current in
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(completed ? Color.blue : Color.gray.opacity(0.3))
                                        .frame(width: 16, height: 16)
                                    if completed {
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                                Text(step.rawValue)
                                    .font(.footnote)
                                    .foregroundColor(
                                        current ? .blue :
                                            completed ? .primary : .gray
                                    )
                                    .fontWeight(current ? .semibold : .regular)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                       
                    
                }
                
                // 고객 정보
                Card {
                    CardTitle("고객 정보")
                    KeyValueRow(key: "고객명", value: order.customerName)
                    KeyValueRow(key: "담당자", value: order.manager)
                    KeyValueRow(key: "이메일", value: order.email)
                }
                
                // 배송 정보
                Card {
                    CardTitle("배송 정보")
                    VStack(alignment: .leading, spacing: 6) {
                        Text("배송지")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text(order.deliveryAddress)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth:.infinity, alignment: .leading)
                }
                
                // 주문 품목
                Card {
                    CardTitle("주문 품목")
                    ForEach(order.items) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.productName)
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Text(formatAmount(item.amount))
                                    .font(.subheadline.bold())
                                    .foregroundColor(.blue)
                            }
                            Text(item.specification)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            HStack {
                                Text("수량: \(item.quantity)개")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("단가: \(formatAmount(item.unitPrice))")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2))
                        )
                    }
                    Divider().padding(.vertical, 4)
                    HStack {
                        Text("총 금액")
                            .font(.body.bold())
                        Spacer()
                        Text(formatAmount(order.amount))
                            .font(.title3.bold())
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("주문 상세")
        
    }
}



#Preview {
    NavigationStack {
        OrderDetailView(id: "O2024-001")
    }
}
//
//#Preview {
//    OrderDetailView()
//}

