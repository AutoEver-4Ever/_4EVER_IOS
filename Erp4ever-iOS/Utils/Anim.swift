//
//  Anim.swift
//  Erp4ever-iOS
//
//  Common animation presets and timing constants.
//

import SwiftUI

enum Anim {
    // Spring preset for UI transitions
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.9)

    // Search prompt show/hide delays (seconds)
    static let searchPromptInDelay: Double = 0.12
    static let searchPromptOutDelay: Double = 0.08
}

