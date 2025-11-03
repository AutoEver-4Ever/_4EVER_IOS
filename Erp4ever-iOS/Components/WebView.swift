//
//  WebView.swift
//  Erp4ever-iOS
//
//  Created by Admin on 11/3/25.
//

import SwiftUI
import WebKit

// UIViewRepresentable를 사용하면 SwiftUI에서 UIKit 뷰를 사용할 수 있음.
struct WebView: UIViewRepresentable {
    let request: URLRequest             // 초기 로드할 웹 요청
    let redirectUrl: URL                // 인터셉트 대상으로 감시할 콜백
    let onRedirect: (URL) -> Void       // 리다이렉트 목표 URL을 포착 시 호출할 콜백
    
    func makeUIView(context: Context) -> WKWebView {
        
        let webConfiguration = WKWebViewConfiguration()
        // 비영속 데이터 저장소로 쿠키,캐시 등을 세션 동안만 유지하고 앱 종료 시 날림.
        webConfiguration.websiteDataStore = .nonPersistent()
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.load(request)
        return webView
    }
    
    func updateUIView(
        _ uiView: WKWebView,
        context: Context
    ) {
        // 필요 시 요청 갱신 로직 추가 가능
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    final class Coordinator: NSObject, WKNavigationDelegate {
        private let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            // 리다이엑트 uri 일치 여부 검사
            let target = parent.redirectUrl
            let schemeMatch = (url.scheme == target.scheme)
            let hostMatch: Bool = {
                if let th = target.host {
                    return url.host == th
                }
                return true
            } ()
            
            let pathMatch = (url.path == target.path)
            
            if schemeMatch && hostMatch && pathMatch {
                parent.onRedirect(url)
                decisionHandler(.cancel) // WebView 내 이동 중단
                return
            }
            
            decisionHandler(.allow)
        }
    }
}
