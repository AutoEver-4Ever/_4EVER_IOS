//
//  MainAppView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject private var session: SessionManager
    

    enum MyTab: Hashable {
        case home
        case quote
        case purchaseOrder
        case purchaseInvoice
        case supplierInvoice
        case search
    }
    
    // 직전 탭을 기억하기 위한 state
    @State private var selectedTap: MyTab = .home
    
    // 검색 상태
    @State private var query: String = ""
    @State private var isSearchPresented: Bool = false

    var body: some View {
        let userType = session.currentUser?.userType

        TabView(selection: $selectedTap) {
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

        
            Tab(value: MyTab.search, role: .search) {
                NavigationStack {
                    SearchView()
                }
            } label: {
                Label("검색", systemImage: "magnifyingglass")
            }
            
        }
        // 검색 창
        .searchable(text: $query,
                    isPresented: $isSearchPresented,
                    prompt: Text("무엇이든 검색하세요")
        )
        .onSubmit(of: .search) {
            // 검색 실행 로직
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}



#Preview {
    MainAppView()
        .environmentObject(SessionManager())
}
