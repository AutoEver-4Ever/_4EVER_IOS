//
//  ActivityRow.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI


struct ActivityRow: View {
    let activity: RecentActivity

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    TypeLabel(text: activity.type)
                    StatusLabel(text: activity.status)
                }
                Text(activity.title)
                    .font(.subheadline.weight(.medium))
                Text(activity.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding(12)
    }
}


