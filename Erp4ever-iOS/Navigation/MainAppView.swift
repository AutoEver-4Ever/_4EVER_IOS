//
//  MainAppView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("홈", systemImage: "house") }

            NavigationStack { QuoteListView() }
                .tabItem { Label("견적", systemImage: "doc.text") }

            NavigationStack { PurchaseOrderListView() }
                .tabItem { Label("발주서", systemImage: "doc.plaintext") }

            NavigationStack { PurchaseInvoiceListView() }
                .tabItem { Label("매입 전표", systemImage: "list.bullet.rectangle") }

            // 공급사용 매출 전표 탭 추가
            NavigationStack { SupplierInvoiceListView() }
                .tabItem { Label("매출 전표", systemImage: "doc.richtext") }
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject(SessionManager())
}
