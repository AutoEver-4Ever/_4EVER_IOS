//
//  Header.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI


struct Header: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(12)
        .background(.clear)
    }
}
#Preview {
    Header(title: "차량 외장재 관리")
}
