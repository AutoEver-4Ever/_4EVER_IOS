//
//  StatusLabel.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct StatusLabel: View {
    let text: String

    private var colors: (bg: Color, fg: Color) {
        switch text {
        case "검토중": return (Color.yellow.opacity(0.2), .yellow)
        case "배송중": return (Color.blue.opacity(0.15), .blue)
        default:       return (Color.green.opacity(0.18), .green)
        }
    }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(RoundedRectangle(cornerRadius: 8).fill(colors.bg))
            .foregroundStyle(colors.fg)
    }
}
