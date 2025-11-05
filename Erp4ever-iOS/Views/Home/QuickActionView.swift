//
//  QuickActionView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/4/25.
//

import SwiftUI

struct QuickActionView: View {
    let userType: String?

    var body: some View {
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading, spacing: 8) {
                Text("빠른 작업")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            if actions.isEmpty {
                Card {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("사용자 정보를 확인할 수 없습니다.")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("로그인이 만료되었을 수 있어요. 다시 로그인해주세요.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
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
    }
    // 사용자 타입별 빠른 작업 구성
    private var actions: [QuickAction] {
        let key = (userType ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        switch key {
        case "CUSTOMER":
            return [
                QuickAction(title: "견적 관리", systemImage: "doc.text.magnifyingglass", color: .green, destination: AnyView(QuoteListView())),
                QuickAction(title: "전표 관리", systemImage: "receipt", color: .orange, destination: AnyView(PurchaseInvoiceListView()))
            ]
            
        case "SUPPLIER":
            return [
                QuickAction(title: "발주서 관리", systemImage: "doc.plaintext", color: .green, destination: AnyView(PurchaseOrderListView())),
                QuickAction(title: "전표 관리", systemImage: "receipt", color: .orange, destination: AnyView(PurchaseInvoiceListView()))
            ]
            
        default:
            // 알 수 없는 사용자 타입(또는 nil)일 경우 안전하게 빈 배열 반환
            return []
        }
    }
}

#Preview {
    QuickActionView(userType: "CUSTOMER")
}
#Preview {
    QuickActionView(userType: "SUPPLIER")
}
