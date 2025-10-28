//
//  OrderListView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/28/25.
//

import SwiftUI

struct OrderListView: View {
    @State private var searchTerm: String = ""
    
    private let orders: [Orders] = [
        .init(id: "O2024-001", deliveryDate: "2024-02-15", amount: 15_000_000, statusCode: "생산중"),
        .init(id: "O2024-002", deliveryDate: "2024-02-10", amount: 8_500_000, statusCode: "배송중"),
        .init(id: "O2024-003", deliveryDate: "2024-02-05", amount: 12_000_000, statusCode: "배송완료"),
        .init(id: "O2024-004", deliveryDate: "2024-01-30", amount: 6_800_000, statusCode: "구매확정"),
        .init(id: "O2024-005", deliveryDate: "2024-02-20", amount: 9_200_000, statusCode: "출고준비완료")
    ]
    
    // 검색 필터
    private var filteredOrders: [Orders] {
        if searchTerm.isEmpty { return orders }
        return orders.filter { $0.id.localizedCaseInsensitiveContains(searchTerm) }
    }
    
    
    private func formatAmount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: value)) ?? "0")원"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Text("주문 관리")
                        .font(.title3.bold())
                    Spacer()
                }
                .padding()
                
                // 검색창
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("주문번호로 검색", text: $searchTerm)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // 주문 리스트
                ScrollView {
                    if filteredOrders.isEmpty {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "cart")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                )
                            Text("검색 결과가 없습니다.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredOrders) { order in
                                NavigationLink(destination: OrderDetailView(id: "1")) {
                                    OrderCard(order: order,
                                              formatAmount: formatAmount)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top,20)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }
}




#Preview {
    OrderListView()
}
