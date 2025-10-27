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

            NavigationStack { QuotesListView() }
                .tabItem { Label("견적", systemImage: "doc.text") }

            NavigationStack { OrdersListView() }
                .tabItem { Label("주문", systemImage: "cart") }

            NavigationStack { PurchasesListView() }
                .tabItem { Label("매입", systemImage: "list.bullet.rectangle") }
        }
    }
}

#Preview {
    MainAppView()
}
