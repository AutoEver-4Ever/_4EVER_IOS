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
        case profile
    }
    
    // 직전 탭을 기억하기 위한 state
    @State private var selectedTap: MyTab = .home
    
    // 검색 상태
    @State private var isSearchPresented: Bool = false
    
    // 마지막 View를 기억하는 상태
    @State private var lastContentTab: MyTab = .home
    
    //
    @StateObject private var searchCoordinator = SearchCoordinator()
    

    var body: some View {
        let userType = session.currentUser?.userType
        let queryBinding = Binding(
            get: { searchCoordinator.query },
            set: { searchCoordinator.updateQuery($0) }
        )

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
            
            Tab("프로필", systemImage: "person.crop.circle", value: MyTab.profile) {
                NavigationStack {
                    ProfileView()
                        .navigationTitle("내 프로필")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            
        
            Tab(value: MyTab.search, role: .search) {
                NavigationStack {
                    SearchView()
                        .environmentObject(searchCoordinator)
                        .searchable(text: queryBinding,
                                    isPresented: $isSearchPresented,
                                    prompt: Text("무엇이든 검색하세요"))
                }
            } label: {
                Label("검색", systemImage: "magnifyingglass")
            }
        }
        .onChange(of: selectedTap) { newValue in
            if newValue == .search {
                searchCoordinator.preselectScope(from: lastContentTab)
                isSearchPresented = true
            } else {
                lastContentTab = newValue
                isSearchPresented = false
            }
        }
        .onChange(of: isSearchPresented) { presented in
            searchCoordinator.isSearching = presented
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject(SessionManager())
}
