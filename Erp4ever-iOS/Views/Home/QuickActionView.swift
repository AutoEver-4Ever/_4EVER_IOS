//
//  QuickActionView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/4/25.
//

import SwiftUI

struct QuickActionView: View {
    let userType: String?

    // 사용자 타입별 빠른 작업 구성
    private var actions: [QuickAction] {
        let key = (userType ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch key {
        case "CUSTOMER":
            return [
                QuickAction(title: "견적 관리", systemImage: "doc.text.magnifyingglass", color: .green, destination: AnyView(QuoteListView())),
                QuickAction(title: "전표 관리", systemImage: "receipt", color: .orange, destination: AnyView(OrderListView()))
            ]
            
        case "SUPPLIER":
            return [
                QuickAction(title: "주문 관리", systemImage: "cart", color: .green, destination: AnyView(OrderListView())),
                QuickAction(title: "전표 관리", systemImage: "receipt", color: .orange, destination: AnyView(PurchaseListView()))
            ]
            
        default:
            fatalError("지원하지 않는 사용자 타입: userType: \(userType ?? "nil") — allowed: CUSTOMER, SUPPLIER")
        }
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(actions) { action in
                NavigationLink(destination: action.destination) {
                    Card {
                        VStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(action.color)
                                    .frame(width: 48, height: 48)
                                Image(systemName: action.systemImage)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, weight: .semibold))
                            }
                            Text(action.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
}

#Preview {
    QuickActionView(userType: "CUSTOMER")
}
#Preview {
    QuickActionView(userType: "SUPPLIER")
}
