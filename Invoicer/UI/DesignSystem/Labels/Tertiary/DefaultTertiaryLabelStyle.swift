////
////  DefaultTertiaryLabelStyle.swift
////  EvelityUI
////
////  Created by Léa Dukaez on 12/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextTertiaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(color())
//                .accessibilityHidden(true)
//            
//            switch size {
//            case .large, .medium:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelLarge()
//            case .small:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelMedium()
//            case .xLarge:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelXLarge()
//            }
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextTertiaryLabelStyle {
//    public static func leftIconTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextTertiaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            switch size {
//            case .large, .medium:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelLarge()
//            case .small:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelMedium()
//            case .xLarge:
//                configuration.title
//                    .foregroundStyle(color())
//                    .labelXLarge()
//            }
//            
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(color())
//                .accessibilityHidden(true)
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == RightIconTextTertiaryLabelStyle {
//    public static func rightIconTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyTertiaryLabelStyle: ViewModifier {
//    
//    @Environment(\.isEnabled) var isEnabled
//    private(set) var size: ButtonSizeStyle
//    
//    func body(content: Content) -> some View {
//        HStack(spacing: size.spacing) {
//            switch size {
//            case .large, .medium:
//                content
//                    .foregroundStyle(color())
//                    .labelLarge()
//            case .small:
//                content
//                    .foregroundStyle(color())
//                    .labelMedium()
//            case .xLarge:
//                content
//                    .foregroundStyle(color())
//                    .labelXLarge()
//            }
//        }
//        .padding(.horizontal, size.horizontalPadding)
//        .padding(.vertical, size.verticalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension View {
//    public func textOnlyTertiary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyTertiaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlyTertiaryLabelStyle: LabelStyle {
//    
//    @Environment(\.isEnabled) var isEnabled
//    var size: ButtonSizeStyle
//    
//    public func makeBody(configuration: Configuration) -> some View {
//        HStack(spacing: size.spacing) {
//            configuration.icon
//                .accessibleFrame(size: size.iconSize)
//                .foregroundColor(color())
//                .accessibilityHidden(true)
//        }
//        .padding(size.horizontalPadding)
//        .frame(maxWidth: size.maxWidthFrame)
//    }
//    
//    private func color() -> Color {
//        isEnabled ? NewEvelityColors.Colors.interactivePrimary : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == IconOnlyTertiaryLabelStyle {
//    public static func iconOnlyTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
