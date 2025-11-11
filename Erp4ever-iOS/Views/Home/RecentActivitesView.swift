//
//  RecentActivitesView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/4/25.
//

import SwiftUI

struct RecentActivitesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("최근 활동")
                .font(.headline)
                .foregroundStyle(.primary)

            Card {
                VStack(spacing: 0) {
                    ForEach(Array(recentActivities.enumerated()), id: \.0) { index, activity in
                        ActivityRow(activity: activity)

                        if index != recentActivities.count - 1 {
                            Divider().padding(.leading, 12)
                        }
                    }
                }
            }
        }
    }
    
    // 최근 작업 목업 데이터
    private let recentActivities: [RecentActivity] = [
        .init(type: "견적", title: "Q2024-001 - 범퍼 견적서", date: "2024-01-15", status: "검토중"),
        .init(type: "주문", title: "O2024-005 - 사이드미러 주문", date: "2024-01-14", status: "배송중"),
        .init(type: "견적", title: "Q2024-002 - 헤드라이트 견적서", date: "2024-01-13", status: "승인됨"),
        .init(type: "주문", title: "O2024-005 - 사이드미러 주문", date: "2024-01-14", status: "배송중"),
        .init(type: "주문", title: "O2024-005 - 사이드미러 주문", date: "2024-01-14", status: "배송중")
    ]
}

#Preview {
    RecentActivitesView()
}
