//
//  GlassBackground.swift
//  Erp4ever-iOS
//
//  A reusable liquid-glass style background modifier.
//

import SwiftUI

enum GlassShape {
    case rounded(CGFloat)
    case circle
}

struct GlassBackground: ViewModifier {
    let shape: GlassShape

    @ViewBuilder
    private func backgroundShape() -> some View {
        Group {
            if #available(iOS 15.0, *) {
                switch shape {
                case .rounded(let radius):
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.ultraThinMaterial)
                case .circle:
                    Circle().fill(.ultraThinMaterial)
                }
            } else {
                switch shape {
                case .rounded(let radius):
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color.white.opacity(0.6))
                case .circle:
                    Circle().fill(Color.white.opacity(0.6))
                }
            }
        }
    }

    @ViewBuilder
    private func strokeShape() -> some View {
        switch shape {
        case .rounded(let radius):
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
        case .circle:
            Circle().stroke(Color.white.opacity(0.3), lineWidth: 0.8)
        }
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundShape())
            .overlay(strokeShape())
            .shadow(color: Color.black.opacity(0.08), radius: 8, y: 3)
    }
}

extension View {
    func glassBackground(shape: GlassShape) -> some View {
        self.modifier(GlassBackground(shape: shape))
    }
}

