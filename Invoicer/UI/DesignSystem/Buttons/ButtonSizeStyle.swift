//
//  SecondaryDefaultButtonStyle.swift
//  EvelityUI
//
//  Created by Léa Dukaez on 05/06/2025.
//
import Foundation

public enum ButtonSizeStyle {
    case large
    case medium
    case small
    case xLarge(shouldFitFrameToLabel: Bool = false)
    
    var isXLarge: Bool {
        switch self {
        case .xLarge: return true
        default: return false
        }
    }
    
    var iconSize: CGFloat {
        switch self {
        case .large: return 24
        case .medium: return 20
        case .small: return 16
        case .xLarge: return 32
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .large, .xLarge: return 20
        case .medium: return 16
        case .small: return 10
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .large, .xLarge: return 16
        case .medium: return 12
        case .small: return 6
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .large, .xLarge: return 16
        case .medium: return 12
        case .small: return 8
        }
    }
    
    var spacing: CGFloat {
        switch self {
        case .large, .medium: return 8
        case .small: return 6
        case .xLarge: return 10
        }
    }

    var maxWidthFrame: CGFloat? {
        switch self {
        case .large: return .infinity
        case .xLarge(let shouldFitFrameToLabel): return shouldFitFrameToLabel ? nil : .infinity
        case .medium, .small: return nil
        }
    }
}
