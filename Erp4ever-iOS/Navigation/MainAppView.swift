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

            NavigationStack { PurchaseListView() }
                .tabItem { Label("매입", systemImage: "list.bullet.rectangle") }
        }
    }
}

#Preview {
    MainAppView()
}
