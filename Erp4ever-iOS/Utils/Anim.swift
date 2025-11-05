//
//  Anim.swift
//  Erp4ever-iOS
//
//  공통 애니메이션 프리셋 및 타이밍 상수 정의
//

import SwiftUI

enum Anim {
    // UI 전환용 스프링 애니메이션 프리셋
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.9)

    // 검색 프롬프트 표시/숨김 지연 시간 (초 단위)
    static let searchPromptInDelay: Double = 0.12
    static let searchPromptOutDelay: Double = 0.08
}
