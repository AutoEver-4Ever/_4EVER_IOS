//
//  MainAppView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var selectedTab: MyTab = .home

    enum MyTab: Hashable {
        case home
        case quote
        case purchaseOrder
        case purchaseInvoice
        case supplierInvoice
        case search
    }

    var body: some View {
        let userType = session.currentUser?.userType

        TabView(selection: $selectedTab) {
            Tab("홈", systemImage: "house", value: MyTab.home) {
                NavigationStack {
                    HomeView()
                }
            }

            if userType == "CUSTOMER" {
                Tab("견적", systemImage: "doc.text", value: MyTab.quote) {
                    NavigationStack { QuoteListView() }
                }
                Tab("매입 전표", systemImage: "list.bullet.rectangle", value: MyTab.purchaseInvoice) {
                    NavigationStack { PurchaseInvoiceListView() }
                }
            } else {
                Tab("발주서", systemImage: "doc.plaintext", value: MyTab.purchaseOrder) {
                    NavigationStack { PurchaseOrderListView() }
                }
                Tab("매출 전표", systemImage: "list.bullet.rectangle", value: MyTab.supplierInvoice) {
                    NavigationStack { SupplierInvoiceListView() }
                }
            }

            // 검색 탭은 홈일 때는 숨기고, 홈이 아닐 때만 보이도록
            if selectedTab != .home {
                Tab(value: MyTab.search, role: .search) {
                    NavigationStack {
                        SearchView()
                    }
                } label: {
                    Label("검색", systemImage: "magnifyingglass")
                }
            }
        }
        // iOS 26에서 탭바 스크롤 시 축소되게 적용
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}



#Preview {
    MainAppView()
        .environmentObject(SessionManager())
}
