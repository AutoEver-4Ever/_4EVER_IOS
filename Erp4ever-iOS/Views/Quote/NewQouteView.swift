//
//  NewQouteView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI



struct NewQuoteView: View {
    @Environment(\.dismiss) var dismiss
    
    // 고객 정보
    @State private var customerName = ""
    @State private var manager = ""
    @State private var email = ""
    
    // 견적 정보
    @State private var quoteDate = Date()
    @State private var validityPeriod = Date()
    @State private var paymentTerms = ""
    @State private var deliveryTerms = ""
    @State private var warrantyPeriod = ""
    
    // 품목
    @State private var items: [NewQuoteItem] = []
    @State private var remarks = ""
    
    // 옵션
    private let paymentOptions = ["현금", "외상 30일", "외상 60일", "외상 90일"]
    private let deliveryOptions = ["공장도", "배송", "직접수령"]
    private let warrantyOptions = ["6개월", "1년", "2년", "3년"]
    
    // 총합
    private var totalAmount: Int {
        items.reduce(0) { $0 + $1.amount }
    }
    
    private func formatAmount(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return "\(f.string(from: NSNumber(value: value)) ?? "0")원"
    }
    
    private func addItem() {
        let newItem = NewQuoteItem(id: UUID().uuidString, productName: "", specification: "", quantity: 1, unitPrice: 0, amount: 0)
        items.append(newItem)
    }
    
    private func updateItem(_ id: String, field: WritableKeyPath<NewQuoteItem, Int>, value: Int) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index][keyPath: field] = value
            items[index].amount = items[index].quantity * items[index].unitPrice
        }
    }
    
    private func removeItem(_ id: String) {
        items.removeAll { $0.id == id }
    }
    
    private func handleSubmit() {
        guard !customerName.isEmpty, !manager.isEmpty, !email.isEmpty else {
            alert("고객 정보를 모두 입력해주세요.")
            return
        }
        guard !paymentTerms.isEmpty, !deliveryTerms.isEmpty, !warrantyPeriod.isEmpty else {
            alert("견적 정보를 모두 선택해주세요.")
            return
        }
        guard !items.isEmpty else {
            alert("견적 품목을 추가해주세요.")
            return
        }
        alert("견적 검토 요청이 완료되었습니다.")
        dismiss()
    }
    
    private func alert(_ message: String) {
        print(" \(message)")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Section(title: "고객 정보") {
                    InputField(title: "고객명", text: $customerName)
                    InputField(title: "담당자", text: $manager)
                    InputField(title: "이메일", text: $email, keyboardType: .emailAddress)
                }
                
                Section(title: "견적 정보") {
                    DatePicker("견적 일자", selection: $quoteDate, displayedComponents: .date)
                    DatePicker("견적 유효기간", selection: $validityPeriod, displayedComponents: .date)
                    
                    Picker("결제조건", selection: $paymentTerms) {
                        Text("선택").tag("")
                        ForEach(paymentOptions, id: \.self) { Text($0) }
                    }
                    
                    Picker("납품 조건", selection: $deliveryTerms) {
                        Text("선택").tag("")
                        ForEach(deliveryOptions, id: \.self) { Text($0) }
                    }
                    
                    Picker("보증기간", selection: $warrantyPeriod) {
                        Text("선택").tag("")
                        ForEach(warrantyOptions, id: \.self) { Text($0) }
                    }
                }
    
                Section(title: "견적 품목") {
                    Button(action: addItem) {
                        Label("품목 추가", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if items.isEmpty {
                        Text("품목 추가 버튼을 눌러 견적 품목을 추가하세요.")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(items.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                let item = items[index]
                                HStack {
                                    Text("품목 \(index + 1)").bold()
                                    Spacer()
                                    Button(role: .destructive) { removeItem(item.id) } label: {
                                        Image(systemName: "trash")
                                    }
                                }
                                InputField(title: "제품명", text: Binding(
                                    get: { item.productName },
                                    set: { items[index].productName = $0 }
                                ))
                                InputField(title: "사양", text: Binding(
                                    get: { item.specification },
                                    set: { items[index].specification = $0 }
                                ))
                                
                                HStack {
                                    InputField(title: "수량", text: Binding(
                                        get: { String(item.quantity) },
                                        set: { updateItem(item.id, field: \.quantity, value: Int($0) ?? 0) }
                                    ), keyboardType: .numberPad)
                                    
                                    InputField(title: "단가", text: Binding(
                                        get: { String(item.unitPrice) },
                                        set: { updateItem(item.id, field: \.unitPrice, value: Int($0) ?? 0) }
                                    ), keyboardType: .numberPad)
                                    
                                    VStack(alignment: .leading) {
                                        Text("금액").font(.caption)
                                        Text(formatAmount(item.amount))
                                            .font(.subheadline.bold())
                                            .frame(maxWidth: .infinity)
                                            .padding(6)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                        }
                        
                        Divider()
                        HStack {
                            Text("총 금액").bold()
                            Spacer()
                            Text(formatAmount(totalAmount))
                                .font(.title3.bold())
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 8)
                    }
                }
        
                Section(title: "비고") {
                    TextEditor(text: $remarks)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    HStack {
                        Spacer()
                        Text("\(remarks.count)/500")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: handleSubmit) {
                    Text("견적 검토 요청")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.vertical, 10)
            }
            .padding()
        }
        .navigationTitle("견적 요청")
    }
}


#Preview {
    NavigationStack {
        NewQuoteView()
    }
}
