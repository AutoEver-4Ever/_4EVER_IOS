//
//  QuoteListView.swift
//  Erp4ever-iOS
//
//  Created by 오윤 on 10/28/25.
//

import SwiftUI

struct QuoteListView: View {
    @State private var searchTerm: String = ""
    @State private var quotes: [Quotes] = [
        Quotes(id: "Q2024-001", customerName: "현대자동차", manager: "김철수", quoteDate: "2024-01-15", deliveryDate: "2024-02-15", amount: 15000000, status: "검토중"),
        Quotes(id: "Q2024-002", customerName: "기아자동차", manager: "이영희", quoteDate: "2024-01-13", deliveryDate: "2024-02-10", amount: 8500000, status: "승인됨"),
        Quotes(id: "Q2024-003", customerName: "쌍용자동차", manager: "박민수", quoteDate: "2024-01-10", deliveryDate: "2024-02-05", amount: 12000000, status: "거절됨")
    ]
    
    // 필터링
    private var filteredQuotes: [Quotes] {
        if searchTerm.isEmpty {
            return quotes
        }
        return quotes.filter { quote in
            quote.customerName.localizedCaseInsensitiveContains(searchTerm) ||
            quote.manager.localizedCaseInsensitiveContains(searchTerm) ||
            quote.id.localizedCaseInsensitiveContains(searchTerm)
        }
    }
    
    
    // 금액 포맷
    private func formatAmount(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: amount)) ?? "0")원"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 헤더
                HStack {
                    Text("견적 관리")
                        .font(.title3.bold())
                    Spacer()
                    NavigationLink(destination: NewQuoteView()) {
                        Text("견적 요청")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // 검색창
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("견적번호, 고객명, 담당자로 검색", text: $searchTerm)
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
                .padding(.bottom, 8)
                
                // 리스트
                ScrollView {
                    if filteredQuotes.isEmpty {
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 64, height: 64)
                                .overlay(
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                )
                            Text("검색 결과가 없습니다.")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredQuotes) { quote in
                                NavigationLink(destination: QuoteDetailView(id: quote.id)) {
                                    QuoteCard(quote: quote,
                                              statusCode: quote.status,
                                              formatAmount: formatAmount)
                                }
                            }
                        }
                        
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    QuoteListView()
}

