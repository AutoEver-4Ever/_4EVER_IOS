//
//  KeyValueRow.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct KeyValueRow: View {
    enum ValueStyle { case normal, emphasis }

    let key: String
    let value: String
    var valueStyle: ValueStyle = .normal
    var body: some View {
        HStack {
            Text(key).font(.footnote).foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(valueStyle == .emphasis ? .body.weight(.bold) : .footnote.weight(.medium))
                .foregroundStyle(valueStyle == .emphasis ? .blue : .primary)
        }
    }
}

