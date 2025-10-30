//
//  CustomInput.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/30/25.
//

import SwiftUI

struct CustomInput: View {
    let label: String
    @Binding var text: String
    var editable: Bool
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            TextField(label, text: $text)
                .keyboardType(keyboard)
                .disabled(!editable)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 8).stroke(editable ? Color.blue : Color.gray.opacity(0.3)))
                .opacity(editable ? 1 : 0.7)
        }
    }
}
