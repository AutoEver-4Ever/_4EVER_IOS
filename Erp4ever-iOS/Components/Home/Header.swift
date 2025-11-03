//
//  Header.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI


struct Header: View {
    var body: some View {
        HStack {
            // 좌측 상단 로고
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(height: 32)
                .accessibilityLabel("EVERP 로고")
            Spacer()
        }
        .padding(12)
        .background(.clear)
    }
}

#Preview {
    Header()
}
