//
//  HomeModel.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import Foundation
import SwiftUI

struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let color: Color
    let destination: AnyView
}

struct RecentActivity: Identifiable {
    let id = UUID()
    let type: String   // 견적 or 주문
    let title: String
    let date: String
    let status: String // 검토중 or 배송중 ir 승인됨
}
