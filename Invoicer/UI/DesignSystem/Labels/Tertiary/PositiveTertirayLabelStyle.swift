////
////  EvelityUI
////
////  Created by Léa Dukaez on 12/06/2025.
////
//
//import SwiftUI
//
//public struct LeftIconTextPositiveTertiaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == LeftIconTextPositiveTertiaryLabelStyle {
//    public static func leftIconPositiveTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//public struct RightIconTextPositiveTertiaryLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == RightIconTextPositiveTertiaryLabelStyle {
//    public static func rightIconPositiveTertiary(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
//
//struct TextOnlyPositiveTertiaryLabelStyle: ViewModifier {
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
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension View {
//    public func textOnlyPositiveTertiary(size: ButtonSizeStyle) -> some View {
//        return self.modifier(TextOnlyPositiveTertiaryLabelStyle(size: size))
//    }
//}
//
//public struct IconOnlyTertiaryPositiveLabelStyle: LabelStyle {
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
//        isEnabled ? NewEvelityColors.Colors.sentimentPositive : NewEvelityColors.Colors.interactiveTertiary
//    }
//}
//
//extension LabelStyle where Self == IconOnlyTertiaryPositiveLabelStyle {
//    public static func iconOnlyTertiaryPositive(size: ButtonSizeStyle) -> Self {
//        .init(size: size)
//    }
//}
