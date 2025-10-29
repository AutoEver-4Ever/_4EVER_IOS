//
//  PurchaseView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 10/29/25.
//

import SwiftUI



struct PurchaseListView: View {
    @State private var searchTerm: String = ""
    @State private var selectedItems: [String] = []
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let purchases: [Purchase] = [
        .init(id: "P2024-001", content: "범퍼 원자재 구매", supplier: "(주)플라스틱코리아", amount: 5_000_000, issueDate: "2024-01-15", dueDate: "2024-02-15", status: .미수, referenceNumber: "REF-001"),
        .init(id: "P2024-002", content: "미러 부품 구매", supplier: "(주)자동차부품", amount: 3_200_000, issueDate: "2024-01-12", dueDate: "2024-02-12", status: .미수, referenceNumber: "REF-002"),
        .init(id: "P2024-003", content: "도료 구매", supplier: "(주)케미칼", amount: 1_800_000, issueDate: "2024-01-10", dueDate: "2024-02-10", status: .완료, referenceNumber: "REF-003"),
        .init(id: "P2024-004", content: "포장재 구매", supplier: "(주)패키징", amount: 800_000, issueDate: "2024-01-08", dueDate: "2024-02-08", status: .미수, referenceNumber: "REF-004")
    ]
    
    // 검색 필터
    private var filteredPurchases: [Purchase] {
        if searchTerm.isEmpty { return purchases }
        return purchases.filter {
            $0.content.localizedCaseInsensitiveContains(searchTerm)
            || $0.supplier.localizedCaseInsensitiveContains(searchTerm)
            || $0.id.localizedCaseInsensitiveContains(searchTerm)
            || $0.referenceNumber.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    
    private var unpaidPurchases: [Purchase] {
        filteredPurchases.filter { $0.status == .미수 }
    }
    
    // MARK: - Helper
    private func formatAmount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: value)) ?? "0")원"
    }
    
    private func statusColor(_ status: Purchase.Status) -> (bg: Color, fg: Color) {
        switch status {
        case .미수: return (Color.red.opacity(0.15), .red)
        case .완료: return (Color.green.opacity(0.15), .green)
        }
    }
    
    private func handleSelectAll() {
        if selectedItems.count == unpaidPurchases.count {
            selectedItems.removeAll()
        } else {
            selectedItems = unpaidPurchases.map { $0.id }
        }
    }
    
    private func handleSelectItem(_ id: String) {
        if selectedItems.contains(id) {
            selectedItems.removeAll { $0 == id }
        } else {
            selectedItems.append(id)
        }
    }
    
    private func handlePayment() {
        guard !selectedItems.isEmpty else {
            alertMessage = "처리할 항목을 선택해주세요."
            showAlert = true
            return
        }
        let selectedCount = selectedItems.count
        let totalAmount = purchases
            .filter { selectedItems.contains($0.id) }
            .reduce(0) { $0 + $1.amount }
        
        alertMessage = "선택한 \(selectedCount)건의 매입전표를 수금처리 하시겠습니까?\n총 금액: \(formatAmount(totalAmount))"
        showAlert = true
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Text("매입전표 관리")
                        .font(.title3.bold())
                    Spacer()
                }
                .padding()
                
                // 검색창
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("전표번호, 내용, 거래처, 참조번호로 검색", text: $searchTerm)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3))
                        )
                )
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 12) {
                        
                        // 선택 영역
                        if !unpaidPurchases.isEmpty {
                            VStack(spacing: 8) {
                                HStack {
                                    Button(action: handleSelectAll) {
                                        HStack(spacing: 6) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                                                    .frame(width: 22, height: 22)
                                                    .background(selectedItems.count == unpaidPurchases.count ? Color.blue : Color.clear)
                                                    .cornerRadius(4)
                                                if selectedItems.count == unpaidPurchases.count {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            Text("전체 선택")
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                        }
                                        
                                        
                                    }
                                    Spacer()
                                    if !selectedItems.isEmpty {
                                        Text("\(selectedItems.count)건 선택됨")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        Button("수금처리", action: handlePayment)
                                            .buttonStyle(.borderedProminent)
                                    }
                                }
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
//                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // 매입전표 카드 목록
                        ForEach(filteredPurchases) { purchase in
                            PurchaseCard(
                                purchase: purchase,
                                selected: selectedItems.contains(purchase.id),
                                onToggle: handleSelectItem,
                                formatAmount: formatAmount,
                                statusColor: statusColor
                            )
                        }
                        
                        if filteredPurchases.isEmpty {
                            VStack(spacing: 10) {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 64, height: 64)
                                    .overlay(Image(systemName: "doc.text").font(.system(size: 24)).foregroundColor(.gray))
                                Text("검색 결과가 없습니다.")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .alert(alertMessage, isPresented: $showAlert) {
                Button("확인") { selectedItems.removeAll() }
            }
        }
    }
}


// MARK: - Preview
#Preview {
    PurchaseListView()
}

