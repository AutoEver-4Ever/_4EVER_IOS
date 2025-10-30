//
//  MenuInfo.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/30/25.
//

import SwiftUI

struct MenuRow: View {
    let title: String
    var isDestructive = false
    
    var body: some View {
        Button {
            print("\(title) tapped")
        } label: {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isDestructive ? .red : .primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        }
    }
}
