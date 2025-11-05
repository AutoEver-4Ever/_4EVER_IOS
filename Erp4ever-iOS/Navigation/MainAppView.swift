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

            NavigationStack { OrderListView() }
                .tabItem { Label("주문", systemImage: "cart") }

            NavigationStack { PurchaseInvoiceListView() }
                .tabItem { Label("매입 전표", systemImage: "list.bullet.rectangle") }

            NavigationStack { ProfileView() }
                .tabItem { Label("프로필", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    MainAppView()
        .environmentObject(SessionManager())
}
